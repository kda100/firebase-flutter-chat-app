import 'chat_content_item_type.dart';

///class for text, image or video message sent by user.
abstract class ChatContentItem {
  final content; //for text -> String, image -> filePath, video -> [videoFilePath,thumbnailFilePath]
  final ChatContentItemType chatContentItemType; //text, image or video
  final bool
      isRecipient; //whether user is the receiving the message or sending it.
  final String sentBy;
  DateTime createdAt;

  ChatContentItem({
    required this.content,
    required this.isRecipient,
    required this.chatContentItemType,
    required this.sentBy,
    required this.createdAt,
  });
}
