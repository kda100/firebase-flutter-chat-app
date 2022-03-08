import 'dart:io';
import 'package:firebase_chat_app/constants/sizes.dart';
import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/upload_chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/upload_chat_content_item_widgets/custom_linear_progress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chat_provider.dart';
import '../../placeholder_widgets.dart';

///Widget used to display images and videos that are being uploaded to Firestore.
///They contain a progress bar so user can see progress of upload
///and a cancel button so user can cancel the operation at any time.

class UploadChatContentItemWidget extends StatelessWidget {
  final UploadChatContentItemView uploadChatContentItemView;

  UploadChatContentItemWidget({required this.uploadChatContentItemView});

  @override
  Widget build(BuildContext context) {
    var imagePath = uploadChatContentItemView.content; //image file path
    if (uploadChatContentItemView.chatContentItemType ==
        ChatContentItemType.VIDEO) {
      imagePath = uploadChatContentItemView.content[1]; //thumbnail file path.
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: kMinChatContentItemHeight,
        maxWidth: kMaxChatContentItemWidth,
        minWidth: kMaxChatContentItemWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorPalette.secondaryBackgroundColor,
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Image(
              image: FileImage(File(imagePath)),
              errorBuilder: (context, exception, stackTrace) =>
                  BrokenImagePlaceHolderWidget(),
            ),
            if (uploadChatContentItemView.taskSnapshotEvents != null)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  //button to cancel upload.
                  onPressed: () => Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  ).cancelMediaUpload(id: uploadChatContentItemView.id),
                  icon: Icon(
                    Icons.cancel,
                  ),
                  color: Colors.red,
                ),
              ),
            if (uploadChatContentItemView.chatContentItemType ==
                ChatContentItemType.VIDEO)
              Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            if (uploadChatContentItemView.taskSnapshotEvents != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: CustomLinearProgress(
                  taskSnapshotsEvents:
                      uploadChatContentItemView.taskSnapshotEvents!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
