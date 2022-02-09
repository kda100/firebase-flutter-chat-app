import 'dart:io';
import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          color: chatContentItem.sentBy
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: chatContentItem.sentBy
                ? Radius.circular(0)
                : Radius.circular(12),
            bottomRight: chatContentItem.sentBy
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
            style: chatContentItem.sentBy
                ? Theme.of(context).textTheme.bodyText1
                : Theme.of(context).textTheme.bodyText2),
      );
    } else if (chatContentItem.chatContentItemType ==
            ChatContentItemType.IMAGE ||
        chatContentItem.chatContentItemType == ChatContentItemType.VIDEO) {
      var imagePath = chatContentItem.content;
      if (chatContentItem.chatContentItemType == ChatContentItemType.VIDEO) {
        imagePath = chatContentItem.content[1];
      }
      //TODO Find a placeholder
      Widget child = SizedBox();
      if (chatContentItem.runtimeType == UploadChatContentItem) {
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
            if (chatContentItem.isSending && chatContentItem.uploadTask != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamBuilder<TaskSnapshot>(
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
        child = Image(
          image: NetworkImage(imagePath),
          errorBuilder: (context, exception, stackTrace) =>
              BrokenImagePlaceHolderWidget(),
          frameBuilder: (BuildContext context, Widget child, int? frame,
              bool wasSynchronouslyLoaded) {
            Widget widget = child;
            if (chatContentItem.chatContentItemType ==
                ChatContentItemType.VIDEO) {
              widget = Stack(
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
      return Container(
        width: 200,
        constraints: BoxConstraints(
          minHeight: 150,
        ),
        child: child,
      );
    }
    return SizedBox();
  }
}
