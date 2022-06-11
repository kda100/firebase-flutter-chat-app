import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/models/chat_item_models/chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_models/cloud_chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_models/upload_chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/chat_item_view.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/upload_chat_item_view.dart';
import 'package:firebase_chat_app/models/responses/chat_response.dart';
import 'package:firebase_chat_app/models/responses/file_response.dart';
import 'package:firebase_chat_app/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import '../helpers/datetime_helper.dart';

///acts as a mediator between widgets and ChatRepository and Services classes.

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  ChatResponse _chatResponse =
      ChatResponse.loading(); //chat response object for chat screen.

  String get myName => _chatRepository.myName;

  String get recipientName => _chatRepository.recipientName;

  ChatResponse get chatResponse => _chatResponse;

  int get chatItemsCount => _chatRepository.chatItemMap.length;

  ///called at start of app.
  Future<void> setUpChatData() async {
    _chatRepository.setUpChatData();
    _chatRepository.chatResponseStream.listen((ChatResponse chatResponse) {
      _chatResponse = chatResponse;
      notifyListeners();
    });
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
  void unSendChatItem({required String id}) {
    _chatRepository.unSendChatContentItem(id: id);
  }

  ///determines whether to display a date heading above a group of chat content items widgets,
  ///if series of chat content items widgets were sent on the same day then date will only be shown for
  ///the first chat content item.
  bool _showChatItemDate({
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
  bool _showChatItemName({
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
  ChatItemView getChatItemView({required int index}) {
    final Map<String, ChatItem> chatItemMap = _chatRepository.chatItemMap;
    final List<String> chatItemKeys = _chatRepository.chatItemKeys;

    index = chatItemMap.length - index - 1;
    final String currentId = chatItemKeys[index];
    ChatItem currChatItem = chatItemMap[currentId]!;
    bool showDateHeading;
    bool showChatItemName;
    if (index == 0) {
      showDateHeading = true;
      showChatItemName = true;
    } else {
      ChatItem prevChatItem = chatItemMap[chatItemKeys[index - 1]]!;
      final DateTime currCreatedAtDDMMYY =
          DateTimeHelper.formatDateTimeToYearMonthDay(currChatItem.createdAt);
      final DateTime prevCreatedAtDDMMYY =
          DateTimeHelper.formatDateTimeToYearMonthDay(prevChatItem.createdAt);
      showDateHeading = _showChatItemDate(
        currCreatedAtDay: currCreatedAtDDMMYY,
        prevCreatedAtDay: prevCreatedAtDDMMYY,
      );
      showChatItemName = _showChatItemName(
        currIsRecipient: currChatItem.isRecipient,
        prevIsRecipient: prevChatItem.isRecipient,
        currCreatedAtDay: currCreatedAtDDMMYY,
        prevCreatedAtDay: prevCreatedAtDDMMYY,
      );
    }
    if (currChatItem.runtimeType == CloudChatItem)
      return CloudChatItemView(
        id: currentId,
        showName: showChatItemName,
        showChatItemDate: showDateHeading,
        cloudChatItem: currChatItem as CloudChatItem,
      );
    else // currChatItem is UploadChatContentItem.
      return UploadChatItemView(
        id: currentId,
        showName: showChatItemName,
        showDateHeading: showDateHeading,
        uploadChatContentItem: currChatItem as UploadChatItem,
      );
  }
}
