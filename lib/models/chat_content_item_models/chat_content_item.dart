import '../chat_content_item_type.dart';

///class to store information of text, image or video message sent by user.
abstract class ChatContentItem {
  final content; //for TEXT -> String, IMAGE -> filePath, VIDEO -> [videoFilePath,thumbnailFilePath]
  final ChatContentItemType chatContentItemType; //TEXT, IMAGE or VIDEO
  final bool
      isRecipient; //whether user is the one receiving the message or sending it.
  final DateTime createdAt;

  ChatContentItem({
    required this.content,
    required this.isRecipient,
    required this.chatContentItemType,
    required this.createdAt,
  });
}
