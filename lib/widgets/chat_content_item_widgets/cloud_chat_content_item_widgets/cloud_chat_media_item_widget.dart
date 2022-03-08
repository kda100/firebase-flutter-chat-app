import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/constants/sizes.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/chat_content_item_event_handler.dart';
import 'package:flutter/material.dart';
import '../../placeholder_widgets.dart';

///Widget displayed when image and video messages have been uploaded to Firebase.
///Video messages have a 'play' icon at its centre to differentiate them from images.

class CloudChatMediaItemWidget extends StatelessWidget {
  final CloudChatContentItemView cloudChatContentItemView;

  CloudChatMediaItemWidget({required this.cloudChatContentItemView});

  @override
  Widget build(BuildContext context) {
    var imagePath = cloudChatContentItemView.content; //image URL
    if (cloudChatContentItemView.chatContentItemType ==
        ChatContentItemType.VIDEO) {
      imagePath = cloudChatContentItemView.content[1]; //thumbnail URL.
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: kMinChatContentItemHeight,
        maxWidth: kMaxChatContentItemWidth,
        minWidth: kMaxChatContentItemWidth,
      ),
      child: ChatContentItemEventHandler(
        //media can be watched on another screen and unsent.
        cloudChatContentItemView: cloudChatContentItemView,
        child: Image(
          image: NetworkImage(imagePath),
          errorBuilder: (context, exception, stackTrace) {
            return BrokenImagePlaceHolderWidget();
          },
          frameBuilder: (BuildContext context, Widget child, int? frame,
              bool wasSynchronouslyLoaded) {
            if (cloudChatContentItemView.chatContentItemType ==
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
            child = DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorPalette.secondaryBackgroundColor,
                ),
                child: child);
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              //smooth fade in
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
