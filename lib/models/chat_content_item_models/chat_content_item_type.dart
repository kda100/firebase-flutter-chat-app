import '../enum_values.dart';

/// enum containing types of messages user can send
enum ChatContentItemType {
  TEXT,
  IMAGE,
  VIDEO,
}

///class to decode and encode messages to their ChatContentItemTypes.
class ChatContentItemTypeConverter {
  static final EnumValues<ChatContentItemType> _chatContentItemTypes =
      EnumValues<ChatContentItemType>({
    "text": ChatContentItemType.TEXT,
    "image": ChatContentItemType.IMAGE,
    "video": ChatContentItemType.VIDEO
  });

  static ChatContentItemType decode(String chatContentItemType) =>
      _chatContentItemTypes.getValueToTypeMap[chatContentItemType]!;

  static String encode(ChatContentItemType chatContentItemType) =>
      _chatContentItemTypes.getTypeToValueMap[chatContentItemType]!;
}
