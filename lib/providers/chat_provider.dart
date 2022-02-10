import 'dart:async';
import 'dart:collection';
import 'package:firebase_chat_app/constants/firebase_field_names.dart';
import 'package:firebase_chat_app/helpers/chats_media_storage_bucket_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final CollectionReference _chatContentItemCollection =
      FirebaseFirestore.instance.collection("Your Collection");
  final Reference _chatsImageStorageRef =
      FirebaseStorage.instance.ref("Your Storage Reference");
  final Reference _chatsVideoStorageRef =
      FirebaseStorage.instance.ref("Your Storage Reference");
  final String _myName = "My Name";
  Map<String, dynamic> _mainChatContentItemMap = {};
  Map<String, dynamic> _uploadChatContentItemMap = {};
  Queue<String> _uploadChatContentIdsQueue = Queue();
  List<String> _readChatContentItemIds = [];
  StreamController<Map<String, dynamic>> _chatContentItemsMapStreamController =
      StreamController<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot>?
      _coachChatsChatContentCollectionStreamSubscription;

  @override
  void dispose() {
    _coachChatsChatContentCollectionStreamSubscription?.cancel();
    _chatContentItemsMapStreamController.close();
    super.dispose();
  }

  Stream<Map<String, dynamic>> get getCoachChatContentItemMapStream =>
      _chatContentItemsMapStreamController.stream;

  String get myName => _myName;

  Future<void> _deleteChatMediaItemCache({required String id}) async {
    final UploadChatContentItem uploadChatContentItem =
        _uploadChatContentItemMap[id];
    final ChatContentItemType chatContentItemType =
        uploadChatContentItem.chatContentItemType;
    final content = uploadChatContentItem.content;
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      if (content != null) {
        final File file = File(content);
        if (await file.exists()) await file.delete();
      }
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      content.forEach((filePath) async {
        if (filePath != null) {
          final File file = File(filePath);
          if (await file.exists()) await File(filePath).delete();
        }
      });
    }
  }

  void _removeChatContentItemFromMain({
    required String id,
  }) {
    if (_mainChatContentItemMap.containsKey(id)) {
      _mainChatContentItemMap.remove(id);
    }
  }

  void _removeChatMediaItemFromUpload({
    required String id,
  }) {
    if (_uploadChatContentItemMap.containsKey(id)) {
      _uploadChatContentItemMap.remove(id);
    }
  }

  void listenToCoachChatCloudFirebaseData() {
    _coachChatsChatContentCollectionStreamSubscription =
        _chatContentItemCollection
            .orderBy(
              FieldNames.createdAtField,
            )
            .limitToLast(100)
            .snapshots()
            .listen(
      (coachChatContentCloudFirebaseDataSnapshot) async {
        bool _updateStream = false;
        coachChatContentCloudFirebaseDataSnapshot.docChanges.forEach(
          (coachChatContentDocChange) {
            final DocumentSnapshot coachChatContentDoc =
                coachChatContentDocChange.doc;
            final String id = coachChatContentDoc.id;
            if (coachChatContentDocChange.type == DocumentChangeType.added ||
                coachChatContentDocChange.type == DocumentChangeType.modified) {
              final Map<String, dynamic>? coachChatContentData =
                  coachChatContentDoc.data();
              if (coachChatContentData != null) {
                final String sentBy =
                    coachChatContentData[FieldNames.sentByField];
                final bool isRecipient = sentBy != _myName;
                final bool onCloud =
                    coachChatContentData[FieldNames.onCloudField];
                final bool read = coachChatContentData[FieldNames.readField];
                if (_uploadChatContentItemMap.containsKey(id) &&
                    _mainChatContentItemMap.containsKey(id)) {
                  _onUploadChatContentItemUploaded(id: id);
                }
                if (!isRecipient ||
                    (isRecipient &&
                        onCloud &&
                        !_mainChatContentItemMap.containsKey(id))) {
                  _updateStream = true;
                  CloudChatContentItem chatContentItem = CloudChatContentItem(
                    read: isRecipient ? null : read,
                    onCloud: isRecipient ? null : onCloud,
                    isRecipient: isRecipient,
                    content: coachChatContentData[FieldNames.contentField],
                    sentBy: sentBy,
                    chatContentItemType: ChatContentItemTypeConverter.decode(
                        coachChatContentData[
                            FieldNames.chatContentItemTypeField]),
                    createdAt: coachChatContentData[FieldNames.createdAtField]
                        .toDate(),
                  );
                  if (_mainChatContentItemMap.containsKey(id)) {
                    _mainChatContentItemMap[id] = chatContentItem;
                  } else if (_isAfterFirstChatContentItem(
                      createdAt: chatContentItem.createdAt)) {
                    _mainChatContentItemMap[id] = chatContentItem;
                    if (isRecipient && !read) {
                      _readChatContentItemIds.add(id);
                      notifyListeners();
                    }
                  } else {
                    _insertChatContentItemAtStart(
                        id: id, chatContentItem: chatContentItem);
                  }
                }
              }
            } else if (coachChatContentDocChange.type ==
                DocumentChangeType.removed) {
              _updateStream = true;
              _removeChatContentItemFromMain(
                id: id,
              );
            }
          },
        );
        if (_updateStream)
          _chatContentItemsMapStreamController.sink
              .add(_mainChatContentItemMap);
      },
      onError: (error) {
        print(error);
      },
      cancelOnError: false,
    );
    _chatContentItemsMapStreamController.sink.add(_mainChatContentItemMap);
  }

  bool _isAfterFirstChatContentItem({required DateTime createdAt}) {
    if (_mainChatContentItemMap.isNotEmpty) {
      final DateTime firstCreatedAt =
          _mainChatContentItemMap[_mainChatContentItemMap.keys.first].createdAt;
      return createdAt.isAfter(firstCreatedAt);
    }
    return false;
  }

  void _insertChatContentItemAtStart({
    required CloudChatContentItem chatContentItem,
    required String id,
  }) {
    final Map<String, dynamic> newMainChatContentItemMap = {};
    newMainChatContentItemMap[id] = chatContentItem;
    newMainChatContentItemMap.addAll(_mainChatContentItemMap);
    _mainChatContentItemMap = newMainChatContentItemMap;
  }

  void _onUploadChatContentItemUploaded({required String id}) {
    _deleteChatMediaItemCache(id: id);
    _removeChatMediaItemFromUpload(
      id: id,
    );
    _removeChatContentItemFromMain(id: id);
    _uploadChatContentIdsQueue.remove(id);
    if (_uploadChatContentIdsQueue.isNotEmpty &&
        _uploadChatContentItemMap.isNotEmpty) {
      final UploadChatContentItem nextUploadChatContentItem =
          _mainChatContentItemMap[_uploadChatContentIdsQueue.first];
      if (nextUploadChatContentItem.isSending &&
          nextUploadChatContentItem.uploadTask != null)
        nextUploadChatContentItem.uploadTask?.resume();
    }
  }

  void updateReadReceipts() {
    if (_readChatContentItemIds.isNotEmpty) {
      _readChatContentItemIds.forEach((id) async {
        final DocumentReference? chatContentItemDoc =
            _getChatContentItemDocRef(id: id);
        await chatContentItemDoc?.update({FieldNames.readField: true});
        _readChatContentItemIds.remove(id);
        notifyListeners();
      });
    }
  }

  Map<String, dynamic> get getMainCoachChatContentItemMap {
    return _mainChatContentItemMap;
  }

  List<String> get getReadChatContentItemIds {
    return _readChatContentItemIds;
  }

  DocumentReference? _getChatContentItemDocRef({
    String? id,
  }) {
    return _chatContentItemCollection.doc(id);
  }

  Future<void> _setChatContentItemDocRef({
    required DocumentReference chatsChatContentDocRef,
    required var content,
    required Timestamp createdAtTimestamp,
    required String chatContentItemTypeString,
  }) async {
    chatsChatContentDocRef.set({
      FieldNames.contentField: content,
      FieldNames.createdAtField: createdAtTimestamp,
      FieldNames.chatContentItemTypeField: chatContentItemTypeString,
      FieldNames.sentByField: myName,
      FieldNames.onCloudField: false,
      FieldNames.readField: false,
    });
  }

  void cancelMediaUpload({required String id}) {
    UploadChatContentItem uploadChatContentItem = _mainChatContentItemMap[id];
    uploadChatContentItem.uploadTask?.cancel();
    uploadChatContentItem.isSending = false;
    _uploadChatContentIdsQueue.remove(id);
    _removeChatContentItemFromMain(id: id);
    _removeChatMediaItemFromUpload(id: id);
    _chatContentItemsMapStreamController.sink.add(_mainChatContentItemMap);
  }

  Future<String?> _uploadMedia({
    required File media,
    required String id,
    required UploadChatContentItem? uploadChatContentItem,
    required Reference? mediaStorageReference,
  }) async {
    try {
      uploadChatContentItem?.uploadTask = mediaStorageReference?.putFile(media);
      if (_uploadChatContentIdsQueue.first != id)
        await uploadChatContentItem?.uploadTask?.pause();
      _chatContentItemsMapStreamController.sink.add(_mainChatContentItemMap);
      final TaskSnapshot? taskSnapshot =
          await uploadChatContentItem?.uploadTask;
      if (taskSnapshot != null) {
        final TaskState taskState = taskSnapshot.state;
        if (taskState == TaskState.success)
          return mediaStorageReference?.getDownloadURL();
        else if (taskState == TaskState.error) {
          throw Error();
        }
      }
    } catch (e) {
      if ((_mainChatContentItemMap[id] as UploadChatContentItem).isSending)
        cancelMediaUpload(id: id);
      return null;
    }
  }

  void sendChatContentItem(
      {String? id,
      var content,
      required ChatContentItemType chatContentItemType}) async {
    final String chatContentItemTypeString =
        ChatContentItemTypeConverter.encode(chatContentItemType);
    final DocumentReference? chatContentItemDocRef =
        _getChatContentItemDocRef(id: id);
    if (chatContentItemDocRef != null) {
      if (chatContentItemType == ChatContentItemType.TEXT) {
        _setChatContentItemDocRef(
            chatsChatContentDocRef: chatContentItemDocRef,
            content: content,
            createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
            chatContentItemTypeString: chatContentItemTypeString);
      } else if (chatContentItemType == ChatContentItemType.IMAGE ||
          chatContentItemType == ChatContentItemType.VIDEO) {
        UploadChatContentItem? uploadChatContentItem;
        if (id != null) {
          uploadChatContentItem = _mainChatContentItemMap[id];
          uploadChatContentItem?.isSending = true;
        } else {
          uploadChatContentItem = UploadChatContentItem(
              sentBy: _myName,
              content: content,
              chatContentItemType: chatContentItemType,
              isSending: true);
          id = chatContentItemDocRef.id;
          _uploadChatContentItemMap[id] = uploadChatContentItem;
          _mainChatContentItemMap[id] = uploadChatContentItem;
        }
        _uploadChatContentIdsQueue.add(id);
        if (chatContentItemType == ChatContentItemType.IMAGE) {
          final String? chatImageDownloadURL = await _uploadMedia(
            media: File(content),
            id: id,
            uploadChatContentItem: uploadChatContentItem,
            mediaStorageReference: _chatsImageStorageRef.child(
              ChatsMediaStorageBucketHelper.chatImageItemFileName(
                chatContentId: id,
              ),
            ),
          );
          if (chatImageDownloadURL != null) {
            _setChatContentItemDocRef(
                chatsChatContentDocRef: chatContentItemDocRef,
                content: chatImageDownloadURL,
                createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
                chatContentItemTypeString: chatContentItemTypeString);
          }
        }
        if (chatContentItemType == ChatContentItemType.VIDEO) {
          final String? chatVideoDownloadURL = await _uploadMedia(
            media: File(content[0]),
            id: id,
            uploadChatContentItem: uploadChatContentItem,
            mediaStorageReference: _chatsVideoStorageRef.child(
              ChatsMediaStorageBucketHelper.chatVideoItemFolder(
                  chatVideoItemFolder: ChatVideoItemFolder.VideoFile,
                  chatContentId: id),
            ),
          );
          if (chatVideoDownloadURL != null) {
            final String? chatThumbnailDownloadURL = await _uploadMedia(
              media: File(content[1]),
              id: id,
              uploadChatContentItem: uploadChatContentItem,
              mediaStorageReference: _chatsVideoStorageRef.child(
                ChatsMediaStorageBucketHelper.chatVideoItemFolder(
                    chatVideoItemFolder: ChatVideoItemFolder.ThumbnailFile,
                    chatContentId: id),
              ),
            );
            if (chatThumbnailDownloadURL != null) {
              _setChatContentItemDocRef(
                  chatsChatContentDocRef: chatContentItemDocRef,
                  content: [chatVideoDownloadURL, chatThumbnailDownloadURL],
                  createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
                  chatContentItemTypeString: chatContentItemTypeString);
            }
          }
        }
      }
    }
  }
}
