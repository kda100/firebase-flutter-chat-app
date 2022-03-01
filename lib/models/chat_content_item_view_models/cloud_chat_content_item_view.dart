import 'package:firebase_chat_app/models/chat_content_item_models/cloud_chat_content_item.dart';
import 'chat_content_item_view.dart';

///view class for chat content items where the data has come from a CloudChatContentItem.
class CloudChatContentItemView extends ChatContentItemView {
  final CloudChatContentItem cloudChatContentItem;

  CloudChatContentItemView({
    required String id,
    required bool showName,
    required bool showChatContentItemDate,
    required this.cloudChatContentItem,
  }) : super(
          id: id,
          showDateHeading: showChatContentItemDate,
          showName: showName,
          chatContentItem: cloudChatContentItem,
        );

  bool get onCloud => cloudChatContentItem.onCloud;
  bool get read => cloudChatContentItem.read;
}
