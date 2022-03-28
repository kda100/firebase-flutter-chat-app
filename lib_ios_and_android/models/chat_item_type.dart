import 'enum_values.dart';

/// enum containing types of messages user can send
enum ChatItemType {
  TEXT,
  IMAGE,
  VIDEO,
}

///class to decode and encode messages to their ChatContentItemTypes.
class ChatItemTypeConverter {
  static final EnumValues<ChatItemType> _chatItemTypes =
      EnumValues<ChatItemType>({
    "text": ChatItemType.TEXT,
    "image": ChatItemType.IMAGE,
    "video": ChatItemType.VIDEO
  });

  static ChatItemType decode(String chatItemType) =>
      _chatItemTypes.getValueToTypeMap[chatItemType]!;

  static String encode(ChatItemType chatItemType) =>
      _chatItemTypes.getTypeToValueMap[chatItemType]!;
}
