import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/models/file_response.dart';
import 'package:firebase_chat_app/repositories/chat_repository.dart';
import 'package:firebase_chat_app/models/chat_content_item_models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/chat_content_item_view.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/upload_chat_content_item_view.dart';
import '../helpers/datetime_helper.dart';
import '../models/chat_content_item_models/chat_content_item.dart';
import '../models/chat_content_item_models/upload_chat_content_item.dart';

///acts as a mediator between widgets and ChatRepository and Services classes.

class ChatProvider {
  final ChatRepository _chatRepository = ChatRepository();

  ///used in stream builder in chat screen
  Stream<Map<String, ChatContentItem>> get chatContentItemsMapStream =>
      _chatRepository.chatContentItemsMapStream;

  String get myName => _chatRepository.myName;

  String get recipientName => _chatRepository.recipientName;

  ///called at start of app.
  Future<void> setUpChatData() async {
    _chatRepository.setUpChatData();
  }

  ///communicates with repository to get video or image file for user to send as message.
  ///message may be returned to view, if error occurs.
  Future<String?> sendFile({required fileType}) async {
    final FileResponse? fileResponse =
        await _chatRepository.getFilePath(fileType: fileType);
    if (fileResponse != null) {
      if (fileResponse.filePath != null) {
        if (fileType == FileType.image) {
          _chatRepository.sendChatImageItem(imagePath: fileResponse.filePath!);
        } else {
          _chatRepository.sendChatVideoItem(videoPath: fileResponse.filePath!);
        }
      }
      return fileResponse.message;
    }
    return null;
  }

  ///for sending text messages ChatContentItemType.TEXT.
  void sendMessage({required message}) {
    _chatRepository.sendChatTextItem(message: message);
  }

  ///cancels media upload
  void cancelMediaUpload({required String id}) {
    _chatRepository.cancelMediaUpload(id: id);
  }

  ///updates read receipts.
  void updateReadReceipts() {
    _chatRepository.updateReadReceipts();
  }

  ///removes message from chat.
  void unSendChatContentItem({required String id}) {
    _chatRepository.unSendChatContentItem(id: id);
  }

  ///determines whether to display a date heading above a group of chat content items widgets,
  ///if series of chat content items widgets were sent on the same day then date will only be shown for
  ///the first chat content item.
  bool _showChatContentItemDate({
    required DateTime currCreatedAtDay,
    required DateTime prevCreatedAtDay,
  }) {
    if (currCreatedAtDay != prevCreatedAtDay) {
      return true;
    }
    return false;
  }

  ///determines whether to display a name heading above a group of chat content items,
  ///if series of chat content items were sent by the same user then name will only be shown for
  ///the first chat content item.
  bool _showChatContentItemName({
    required bool currIsRecipient,
    required bool prevIsRecipient,
    required DateTime currCreatedAtDay,
    required DateTime prevCreatedAtDay,
  }) {
    if (currIsRecipient != prevIsRecipient ||
        currCreatedAtDay != prevCreatedAtDay) {
      return true;
    }
    return false;
  }

  ///used to get view data for Chat Content Item Widgets.
  ///This function uses the chat content item map data the Chat Stream receives to process
  ///each ChatContentItem data and determined their ChatContentItemView data, then returns this info back to the view.
  ChatContentItemView getChatContentItemView(
      {required int index,
      required Map<String, ChatContentItem> chatContentItemsMap,
      required Iterable<String> chatContentItemsMapKeys,
      required int itemCount}) {
    index = itemCount - index - 1;
    final String currentId = (chatContentItemsMapKeys.elementAt(index));
    ChatContentItem currChatContentItem = chatContentItemsMap[currentId]!;
    bool showChatContentItemDate;
    bool showChatContentItemName;
    if (index == 0) {
      showChatContentItemDate = true;
      showChatContentItemName = true;
    } else {
      ChatContentItem prevChatContentItem =
          chatContentItemsMap[chatContentItemsMapKeys.elementAt(index - 1)]!;
      final DateTime currCreatedAtDDMMYY =
          DateTimeHelper.formatDateTimeToYearMonthDay(
              currChatContentItem.createdAt);
      final DateTime prevCreatedAtDDMMYY =
          DateTimeHelper.formatDateTimeToYearMonthDay(
              prevChatContentItem.createdAt);
      showChatContentItemDate = _showChatContentItemDate(
        currCreatedAtDay: currCreatedAtDDMMYY,
        prevCreatedAtDay: prevCreatedAtDDMMYY,
      );
      showChatContentItemName = _showChatContentItemName(
        currIsRecipient: currChatContentItem.isRecipient,
        prevIsRecipient: prevChatContentItem.isRecipient,
        currCreatedAtDay: currCreatedAtDDMMYY,
        prevCreatedAtDay: prevCreatedAtDDMMYY,
      );
    }
    if (currChatContentItem.runtimeType == CloudChatContentItem)
      return CloudChatContentItemView(
        id: currentId,
        showName: showChatContentItemName,
        showChatContentItemDate: showChatContentItemDate,
        cloudChatContentItem: currChatContentItem as CloudChatContentItem,
      );
    else // currChatContentItem is UploadChatContentItem.
      return UploadChatContentItemView(
        id: currentId,
        showName: showChatContentItemName,
        showDateHeading: showChatContentItemDate,
        uploadChatContentItem: currChatContentItem as UploadChatContentItem,
      );
  }
}
