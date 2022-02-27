import 'chat_content_item_type.dart';

///class to store information of text, image or video message sent by user.
abstract class ChatContentItem {
  final _content; //for TEXT -> String, IMAGE -> filePath, VIDEO -> [videoFilePath,thumbnailFilePath]
  final ChatContentItemType _chatContentItemType; //TEXT, IMAGE or VIDEO
  final bool
      _isRecipient; //whether user is the one receiving the message or sending it.
  DateTime _createdAt;

  ChatContentItem({
    required content,
    required bool isRecipient,
    required ChatContentItemType chatContentItemType,
    required DateTime createdAt,
  })  : _content = content,
        _chatContentItemType = chatContentItemType,
        _isRecipient = isRecipient,
        _createdAt = createdAt;

  get content => _content;

  ChatContentItemType get chatContentItemType => _chatContentItemType;

  bool get isRecipient => _isRecipient;

  DateTime get createdAt => _createdAt;
}
