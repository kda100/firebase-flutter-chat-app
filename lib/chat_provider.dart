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

///class that contains all the business logic needed for maintaining data and state of the chat app.
///It communicates with Cloud Firestore to read and write data and control state of the chat screen.

///This class listens to a Cloud Firestore collection containing messages then modifies a map containing
///chat content items that is sent into a stream to update the chat screen.
///By doing this the class is able to add images and videos being uploaded to the same map which can be sent to
///same stream so users can see the progress of their videos and images being uploaded.

class ChatProvider with ChangeNotifier {
  final CollectionReference _chatContentItemCollection = FirebaseFirestore
      .instance
      .collection("chatContentItems"); //col ref for all messages
  final Reference _chatsImageStorageRef = FirebaseStorage.instance
      .ref("chatsMedia/images"); //storage ref for images
  final Reference _chatsVideoStorageRef = FirebaseStorage.instance
      .ref("chatsMedia/videos"); //storage ref for videos.
  final String _myName = "John Doe"; //name of this user

  Map<String, dynamic> _chatContentItemMap =
      {}; //map where all chat content items are stored, these are displayed on chat screen, keys are the firebase id references.
  Queue<String> _uploadChatContentIdsQueue =
      Queue(); //control image and videos being upload so only one at time.
  List<String> _unreadChatContentItemIds =
      []; //list to store ids of chat content items that have not been read.
  StreamController<Map<String, dynamic>> _chatContentItemsMapStreamController =
      StreamController<
          Map<String, dynamic>>(); //controls when chat screen needs to update.
  StreamSubscription<QuerySnapshot>?
      _coachChatsChatContentCollectionStreamSubscription; //stores reference to Firebase Cloud collection stream subscription.

  @override
  void dispose() {
    _coachChatsChatContentCollectionStreamSubscription?.cancel();
    _chatContentItemsMapStreamController.close();
    super.dispose();
  }

  ///used in stream builder in chat screen
  Stream<Map<String, dynamic>> get getCoachChatContentItemMapStream =>
      _chatContentItemsMapStreamController.stream;

  String get myName => _myName;

  Map<String, dynamic> get getChatContentItemMap {
    return _chatContentItemMap;
  }

  ///this function removes cached files once they have been uploaded to storage.
  Future<void> _deleteChatMediaItemCache({required String id}) async {
    final UploadChatContentItem? uploadChatContentItem =
        _chatContentItemMap[id];
    final ChatContentItemType? chatContentItemType =
        uploadChatContentItem?.chatContentItemType;
    final content = uploadChatContentItem?.content;
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      if (content != null) {
        final File file = File(content);
        if (await file.exists()) await file.delete();
      }
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      content.forEach((filePath) async {
        //thumbnail and file.
        if (filePath != null) {
          final File file = File(filePath);
          if (await file.exists()) await File(filePath).delete();
        }
      });
    }
  }

  void _removeChatContentItemFromMap({
    required String id,
  }) {
    if (_chatContentItemMap.containsKey(id)) {
      _chatContentItemMap.remove(id);
    }
  }

  /// function called when an image or video has been uploaded to cloud.
  /// removes media item from cache and chat content item map.
  /// then calls for next media item to be uploaded to cloud.
  void _onUploadChatContentItemUploaded({required String id}) {
    _deleteChatMediaItemCache(id: id);
    _removeChatContentItemFromMap(id: id);
    _uploadChatContentIdsQueue.remove(id);
    if (_uploadChatContentIdsQueue.isNotEmpty) {
      final UploadChatContentItem nextUploadChatContentItem =
          _chatContentItemMap[_uploadChatContentIdsQueue.first];
      if (nextUploadChatContentItem.isSending &&
          nextUploadChatContentItem.uploadTask != null)
        nextUploadChatContentItem.uploadTask?.resume();
    }
  }

  ///used to determine whether chat content item should be put at the start or the end of
  ///the chatContentItemsMap
  bool _isAfterFirstChatContentItem({required DateTime createdAt}) {
    if (_chatContentItemMap.isNotEmpty) {
      final DateTime firstCreatedAt =
          _chatContentItemMap[_chatContentItemMap.keys.first].createdAt;
      return createdAt.isAfter(firstCreatedAt);
    }
    return false;
  }

  /// called when timestamp/createdAt of chat content item added is before the last chat content item in the map.
  void _insertChatContentItemAtStart({
    required CloudChatContentItem chatContentItem,
    required String id,
  }) {
    final Map<String, dynamic> newMainChatContentItemMap = {};
    newMainChatContentItemMap[id] = chatContentItem;
    newMainChatContentItemMap.addAll(_chatContentItemMap);
    _chatContentItemMap = newMainChatContentItemMap;
  }

  ///function listens to firebase collection reference with chat content items
  ///then modifies the chatContentItemMap accordingly.
  ///then updates the chatContentItemsMapStreamController and Chat Screen to reflect any changes in messages.
  void listenToCoachChatCloudFirebaseData() {
    _coachChatsChatContentCollectionStreamSubscription =
        _chatContentItemCollection
            .orderBy(
              FieldNames.createdAtField,
            )
            .limitToLast(100) //limit to only 100 messages
            .snapshots()
            .listen(
      (coachChatContentCloudFirebaseDataSnapshot) async {
        bool _updateStream =
            false; // flag for whether chatContentItemsMapStreamController should be updated.
        coachChatContentCloudFirebaseDataSnapshot.docChanges.forEach(
          (coachChatContentDocChange) {
            //iterates over each doc change.
            final DocumentSnapshot coachChatContentDoc =
                coachChatContentDocChange.doc;
            final String id = coachChatContentDoc.id;
            if (coachChatContentDocChange.type == DocumentChangeType.added ||
                coachChatContentDocChange.type == DocumentChangeType.modified) {
              // when message has been sent or, read or on cloud is changed.
              final Map<String, dynamic>? coachChatContentData =
                  coachChatContentDoc.data();
              if (coachChatContentData != null) {
                final String sentBy =
                    coachChatContentData[FieldNames.sentByField];
                final bool isRecipient = sentBy != _myName;
                final bool onCloud =
                    coachChatContentData[FieldNames.onCloudField];
                final bool read = coachChatContentData[FieldNames.readField];
                if (_chatContentItemMap.containsKey(
                        id) && // when a image or video has been uploaded.
                    _chatContentItemMap[id].runtimeType ==
                        UploadChatContentItem) {
                  _onUploadChatContentItemUploaded(id: id);
                }
                if (!isRecipient || //all chat content items sent by user.
                    (isRecipient && //only chat content items with onCloud and that has been received and in current chat content items map.
                        onCloud &&
                        !_chatContentItemMap.containsKey(id))) {
                  _updateStream = true; //change flag
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
                  if (_chatContentItemMap.containsKey(id)) {
                    //chat content item sent by user, read = true or onCloud = true
                    _chatContentItemMap[id] = chatContentItem;
                  } else if (_isAfterFirstChatContentItem(
                      createdAt: chatContentItem.createdAt)) {
                    //if true add item at end of map else add at start
                    _chatContentItemMap[id] = chatContentItem;
                    if (isRecipient && !read) {
                      //messages received will go into unread list.
                      _unreadChatContentItemIds.add(id);
                      notifyListeners();
                    }
                  } else {
                    //add chat content item at start of map.
                    _insertChatContentItemAtStart(
                        id: id, chatContentItem: chatContentItem);
                  }
                }
              }
            } else if (coachChatContentDocChange.type ==
                DocumentChangeType.removed) {
              _updateStream = true; //change flag
              _removeChatContentItemFromMap(
                id: id,
              );
            }
          },
        );
        if (_updateStream) {
          _chatContentItemsMapStreamController.sink.add(
              _chatContentItemMap); //adds chat content item to map to update chat screen.
        }
      },
      onError: (error) {
        print(error);
      },
      cancelOnError: false,
    );
    _chatContentItemsMapStreamController.sink
        .add(_chatContentItemMap); //called when function is first called.
  }

  ///this function converts all the reads of the chat content items to true.
  void updateReadReceipts() {
    if (_unreadChatContentItemIds.isNotEmpty) {
      _unreadChatContentItemIds.forEach((id) async {
        final DocumentReference? chatContentItemDoc =
            _chatContentItemCollection.doc(id);
        await chatContentItemDoc?.update({FieldNames.readField: true});
        _unreadChatContentItemIds.remove(id);
        notifyListeners();
      });
    }
  }

  ///sets chat content item data to Cloud Firestore database.
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

  ///When cancelling image or videos upload to the database.
  void cancelMediaUpload({required String id}) {
    UploadChatContentItem uploadChatContentItem = _chatContentItemMap[id];
    uploadChatContentItem.uploadTask?.cancel();
    uploadChatContentItem.isSending = false;
    _uploadChatContentIdsQueue.remove(id);
    _removeChatContentItemFromMap(id: id);
    _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
  }

  ///called when image or video is being upload to Cloud Firestore and Storage.
  Future<String?> _uploadMedia({
    required File media,
    required String id,
    required UploadChatContentItem? uploadChatContentItem,
    required Reference? mediaStorageReference,
  }) async {
    try {
      uploadChatContentItem?.uploadTask = mediaStorageReference?.putFile(media);
      if (_uploadChatContentIdsQueue.first !=
          id) // only allows one media upload at a time.
        await uploadChatContentItem?.uploadTask?.pause();
      _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
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
      if (_chatContentItemMap.containsKey(id)) {
        cancelMediaUpload(id: id);
      }
      return null;
    }
  }

  ///send chat content items (messages) to the Cloud Firestore database.
  void sendChatContentItem(
      {var content, required ChatContentItemType chatContentItemType}) async {
    final String chatContentItemTypeString =
        ChatContentItemTypeConverter.encode(chatContentItemType);
    final DocumentReference chatContentItemDocRef =
        _chatContentItemCollection.doc();
    if (chatContentItemType == ChatContentItemType.TEXT) {
      _setChatContentItemDocRef(
          chatsChatContentDocRef: chatContentItemDocRef,
          content: content,
          createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
          chatContentItemTypeString:
              chatContentItemTypeString); //just set data to Cloud Firestore.
    } else if (chatContentItemType == ChatContentItemType.IMAGE ||
        chatContentItemType == ChatContentItemType.VIDEO) {
      UploadChatContentItem uploadChatContentItem = UploadChatContentItem(
          content: content,
          sentBy: _myName,
          chatContentItemType: chatContentItemType,
          isSending: true);
      final String id = chatContentItemDocRef.id;
      _chatContentItemMap[id] = uploadChatContentItem;
      _uploadChatContentIdsQueue.add(id);
      if (chatContentItemType == ChatContentItemType.IMAGE) {
        //for image only upload image file.
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
          //set downloadURL to Firestore
          _setChatContentItemDocRef(
              chatsChatContentDocRef: chatContentItemDocRef,
              content: chatImageDownloadURL,
              createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
              chatContentItemTypeString: chatContentItemTypeString);
        }
      }
      if (chatContentItemType == ChatContentItemType.VIDEO) {
        //for video upload both thumbnail and video
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
            //set downloadURLs to Firestore
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

  ///Function for user to remove chat content item from Cloud firestore.
  void unSendChatContentItem({
    required String id,
  }) async {
    try {
      final DocumentReference clientChatContentItemDocRef =
          _chatContentItemCollection.doc(id);
      await clientChatContentItemDocRef.delete();
      _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
    } catch (e) {
      print(e.toString());
    }
  }
}
