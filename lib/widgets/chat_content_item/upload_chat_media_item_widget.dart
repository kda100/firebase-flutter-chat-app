import 'dart:io';
import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/models/chat_content_item_models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/chat_content_item_models/upload_chat_content_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat_provider.dart';
import '../placeholder_widgets.dart';

///Widget when displayed when videos and images are in process of being uploaded to Firebase
///they are displayed with a icon for cancellation and a progress bar.
///Video message have a 'play' icon at its centre to differentiate them from images.

class UploadChatMediaItemWidget extends StatelessWidget {
  final String id;
  final UploadChatContentItem uploadChatContentItem;

  UploadChatMediaItemWidget({
    required this.id,
    required this.uploadChatContentItem,
  });

  @override
  Widget build(BuildContext context) {
    var imagePath = uploadChatContentItem.content; //image file path
    if (uploadChatContentItem.chatContentItemType ==
        ChatContentItemType.VIDEO) {
      imagePath = uploadChatContentItem.content[1]; //thumbnail file path.
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorPalette.secondaryBackgroundColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image(
            image: FileImage(File(imagePath)),
            errorBuilder: (context, exception, stackTrace) =>
                BrokenImagePlaceHolderWidget(),
          ),
          if (uploadChatContentItem.uploadTask != null)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                //button to cancel upload.
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
          if (uploadChatContentItem.chatContentItemType ==
              ChatContentItemType.VIDEO)
            Icon(
              Icons.play_arrow,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
          if (uploadChatContentItem.uploadTask != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StreamBuilder<TaskSnapshot>(
                //displays upload progress of file
                //updates upload progress bar
                stream: uploadChatContentItem.uploadTask?.snapshotEvents,
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
      ),
    );
  }
}
