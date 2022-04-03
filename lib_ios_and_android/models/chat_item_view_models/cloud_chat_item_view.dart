import 'package:firebase_chat_app/models/chat_item_models/cloud_chat_item.dart';
import 'chat_item_view.dart';

///view class for chat content items where the data has come from a CloudChatContentItem.
class CloudChatItemView extends ChatItemView {
  final CloudChatItem _cloudChatItem;

  CloudChatItemView({
    required String id,
    required bool showName,
    required bool showChatItemDate,
    required CloudChatItem cloudChatItem,
  })  : _cloudChatItem = cloudChatItem,
        super(
          id: id,
          showDateHeading: showChatItemDate,
          showName: showName,
          chatItem: cloudChatItem,
        );

  bool get onCloud => _cloudChatItem.onCloud;
  bool get read => _cloudChatItem.read;
}
