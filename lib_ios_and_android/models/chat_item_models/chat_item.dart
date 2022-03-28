import '../chat_item_type.dart';

///class to store information of text, image or video message sent by user.
abstract class ChatItem {
  final content; //for TEXT -> String, IMAGE -> filePath, VIDEO -> [videoFilePath,thumbnailFilePath]
  final ChatItemType chatItemType; //TEXT, IMAGE or VIDEO
  final bool
      isRecipient; //whether user is the one receiving the message or sending it.
  final DateTime createdAt;

  ChatItem({
    required this.content,
    required this.isRecipient,
    required this.chatItemType,
    required this.createdAt,
  });
}
