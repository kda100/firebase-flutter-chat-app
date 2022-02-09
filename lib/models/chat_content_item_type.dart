import 'package:firebase_chat_app/helpers/enum_helper.dart';

enum ChatContentItemType {
  TEXT,
  IMAGE,
  VIDEO,
}

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
