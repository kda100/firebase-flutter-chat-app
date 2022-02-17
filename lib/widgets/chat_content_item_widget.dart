import 'dart:io';
import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_chat_app/chat_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Contains the main information of the message sent by the user.
///Messages sent by the user are displayed on the right hand
///messages sent by the recipient are displayed on the left.
///For text messages the widget shows the content of the message.
///text messages have different designs depending on if it was sent by the user or the recipient.
///Image and Video files that are in the process of being uploaded are displayed with a icon for cancellation
///and an progress bar.
///Video message have a 'play' icon at its centre whilst images do not.

class ChatContentItemWidget extends StatelessWidget {
  final String id;
  final chatContentItem;

  ChatContentItemWidget({
    required Key? key,
    required this.chatContentItem,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chatContentItem.chatContentItemType == ChatContentItemType.TEXT) {
      return Container(
        decoration: BoxDecoration(
          color: chatContentItem.isRecipient //different colours.
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: chatContentItem.isRecipient //different design
                ? Radius.circular(0)
                : Radius.circular(12),
            bottomRight: chatContentItem.isRecipient
                ? Radius.circular(12)
                : Radius.circular(0),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: 200,
        ),
        padding: EdgeInsets.all(10),
        child: Text(chatContentItem.content,
            softWrap: true,
            style: chatContentItem.isRecipient
                ? Theme.of(context).textTheme.bodyText1 //different text themes
                : Theme.of(context).textTheme.bodyText2),
      );
    } else if (chatContentItem.chatContentItemType ==
            ChatContentItemType.IMAGE ||
        chatContentItem.chatContentItemType == ChatContentItemType.VIDEO) {
      var imagePath = chatContentItem.content;
      if (chatContentItem.chatContentItemType == ChatContentItemType.VIDEO) {
        imagePath = chatContentItem.content[1]; //thumbnail displayed.
      }
      Widget child = SizedBox();
      if (chatContentItem.runtimeType == UploadChatContentItem) {
        //display image or video with progress bar and cancellation button.
        child = Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: FileImage(File(imagePath)),
              errorBuilder: (context, exception, stackTrace) =>
                  BrokenImagePlaceHolderWidget(),
            ),
            if (chatContentItem.isSending && chatContentItem.uploadTask != null)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  onPressed: () => Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  ).cancelMediaUpload(id: id),
                  icon: Icon(
                    Icons.cancel,
                  ),
                  color: Colors.red,
                ),
              ),
            if (chatContentItem.chatContentItemType ==
                ChatContentItemType.VIDEO)
              Icon(
                Icons.play_arrow,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            if (chatContentItem.isSending)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamBuilder<TaskSnapshot>(
                  //updates upload progress bar
                  stream: chatContentItem.uploadTask.snapshotEvents,
                  builder: (context, uploadFileTaskSnapshot) {
                    final TaskSnapshot? uploadFileTask =
                        uploadFileTaskSnapshot.data;
                    if (uploadFileTask != null) {
                      final double progress =
                          uploadFileTask.bytesTransferred.toDouble() /
                              uploadFileTask.totalBytes.toDouble();
                      return LinearProgressIndicator(
                        value: progress,
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),
          ],
        );
      } else if (chatContentItem.runtimeType == CloudChatContentItem) {
        //displays image or video thumbnail
        child = Image(
          image: NetworkImage(imagePath),
          errorBuilder: (context, exception, stackTrace) =>
              BrokenImagePlaceHolderWidget(),
          frameBuilder: (BuildContext context, Widget child, int? frame,
              bool wasSynchronouslyLoaded) {
            if (chatContentItem.chatContentItemType ==
                ChatContentItemType.VIDEO) {
              child = Stack(
                alignment: Alignment.center,
                children: [
                  child,
                  Icon(
                    Icons.play_arrow,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              );
            }
            Widget widget = DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: child);
            if (wasSynchronouslyLoaded) {
              return widget;
            }
            return AnimatedOpacity(
              child: widget,
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          },
        );
      }
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 150,
          maxWidth: 200,
          minWidth: 200,
        ),
        child: child,
      );
    }
    return SizedBox();
  }
}
