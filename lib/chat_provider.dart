import 'dart:async';
import 'dart:collection';
import 'package:firebase_chat_app/firebase_services.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/chat_video_item_folder.dart';
import 'models/user.dart';

///class that contains all the business logic needed for maintaining data and state of the chat app.
///It communicates with FirebaseServices to read and write data and control state of the chat screen.

///This class listens to a Cloud Firestore collection containing messages then modifies a map containing
///chat content items that is sent into a stream to update the chat screen.
///By doing this the class is able to add images and videos being uploaded to the same map
///so users can see the progress of their videos and images being uploaded.

class ChatProvider {
  final FirebaseServices _firebaseServices =
      FirebaseServices(); //class containing services to read and write to firebase
  User? me; //User object for user of chat
  User? recipient; //Usr object for recipient in chat

  Map<String, dynamic> _chatContentItemMap =
      {}; //map where all chat content items (messages) are stored, these are displayed on chat screen, keys are the firebase id references.
  Queue<String> _uploadChatContentIdsQueue =
      Queue(); //control image and videos being upload so only one at time.
  List<String> _unreadChatContentItemIds =
      []; //list to store ids of chat content items that have not been read.
  StreamController<Map<String, dynamic>> _chatContentItemsMapStreamController =
      StreamController<
          Map<String, dynamic>>(); //controls when chat screen needs to update.

  ///used in stream builder in chat screen
  Stream<Map<String, dynamic>> get getChatContentItemMapStream =>
      _chatContentItemsMapStreamController.stream;

  Map<String, dynamic> get getChatContentItemMap {
    return _chatContentItemMap;
  }

  String get getMyName => me!.name;

  String get getRecipientName => recipient!.name;

  ///this function removes cached files once they have been uploaded to storage.
  Future<void> _deleteChatMediaItemCache({required String id}) async {
    final UploadChatContentItem? uploadChatContentItem =
        _chatContentItemMap[id];
    final ChatContentItemType? chatContentItemType =
        uploadChatContentItem?.chatContentItemType;
    final content = uploadChatContentItem?.content;
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      // just image
      if (content != null) {
        final File file = File(content);
        if (await file.exists()) await file.delete();
      }
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      content.forEach((filePath) async {
        //thumbnail and video.
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
  /// removes media file from cache and ChatContentItem from map.
  /// then calls for next media item to be uploaded to cloud.
  void _onUploadChatContentItemUploaded({required String id}) {
    _deleteChatMediaItemCache(id: id);
    _removeChatContentItemFromMap(id: id);
    _uploadChatContentIdsQueue.remove(id);
    if (_uploadChatContentIdsQueue.isNotEmpty) {
      final UploadChatContentItem nextUploadChatContentItem =
          _chatContentItemMap[_uploadChatContentIdsQueue.first];
      if (nextUploadChatContentItem.uploadTask != null)
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

  /// called when timestamp/createdAt of ChatContentItem added is before the last chat content item in the ChatContentItemsMap.
  void _insertChatContentItemAtStart({
    required CloudChatContentItem chatContentItem,
    required String id,
  }) {
    final Map<String, dynamic> newMainChatContentItemMap = {};
    newMainChatContentItemMap[id] = chatContentItem;
    newMainChatContentItemMap.addAll(_chatContentItemMap);
    _chatContentItemMap = newMainChatContentItemMap;
  }

  ///function calls at start of app, it fetches data from firebase and sets up listener for chat content items (messages).
  ///listener modifies the chatContentItemMap accordingly.
  ///then updates the chatContentItemsMapStreamController and Chat Screen to reflect any changes in messages.
  Future<void> setUpChatData() async {
    me = await _firebaseServices.fetchMyData();
    recipient = await _firebaseServices.fetchRecipientData();
    _firebaseServices.setUpChatContentItemsCollectionSnapshotListener(
      limit: 100,
      onData: (chatContentFirestoreDataSnapshot) async {
        bool updateStream = false;
        chatContentFirestoreDataSnapshot.docChanges.forEach(
          //iterates over each doc change.
          (chatContentItemDocChange) {
            final DocumentSnapshot chatContentItemDoc =
                chatContentItemDocChange.doc;
            final String id = chatContentItemDoc.id;
            if (chatContentItemDocChange.type == DocumentChangeType.added ||
                chatContentItemDocChange.type == DocumentChangeType.modified) {
              final Map<String, dynamic>? chatContentItemData =
                  chatContentItemDoc.data();
              if (chatContentItemData != null) {
                final bool chatContentItemExists =
                    _chatContentItemMap.containsKey(id);
                if (chatContentItemExists &&
                    _chatContentItemMap[id].runtimeType ==
                        UploadChatContentItem) {
                  //image or video has been uploaded.
                  _onUploadChatContentItemUploaded(id: id);
                }
                final CloudChatContentItem cloudChatContentItem =
                    CloudChatContentItem(
                        chatContentItemData: chatContentItemData, myId: me!.id);
                if (!cloudChatContentItem
                        .isRecipient || //all chat content items sent by user.
                    (cloudChatContentItem
                            .isRecipient && //only chat content items with onCloud, that has been received and are not in ChatContentItemMap.
                        cloudChatContentItem.onCloud &&
                        !chatContentItemExists)) {
                  updateStream = true;
                  if (chatContentItemExists) {
                    //ChatContentItem sent by user, read = true or onCloud = true
                    _chatContentItemMap[id] = cloudChatContentItem;
                  } else if (_isAfterFirstChatContentItem(
                      createdAt: cloudChatContentItem.createdAt)) {
                    //if true add item at end of map
                    _chatContentItemMap[id] = cloudChatContentItem;
                    if (cloudChatContentItem.isRecipient &&
                        cloudChatContentItem.read) {
                      //messages received will go into unread list.
                      _unreadChatContentItemIds.add(id);
                    }
                  } else {
                    //add chat content item at start of map.
                    _insertChatContentItemAtStart(
                        id: id, chatContentItem: cloudChatContentItem);
                  }
                }
              }
            } else if (chatContentItemDocChange.type ==
                DocumentChangeType.removed) {
              updateStream = true;
              _removeChatContentItemFromMap(
                id: id,
              );
            }
          },
        );
        if (updateStream) //not every instance of new doc is chat screen updated.
          _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
      },
    );
    _chatContentItemsMapStreamController.sink
        .add(_chatContentItemMap); //called when function is first called.
  }

  ///this function converts all the read fields of the chat content items to true.
  void updateReadReceipts() async {
    if (_unreadChatContentItemIds.isNotEmpty) {
      _unreadChatContentItemIds.forEach((id) async {
        await _firebaseServices.updateReadReceipt(id: id);
        _unreadChatContentItemIds.remove(id);
      });
    }
  }

  ///Called when user cancels image or videos being uploaded to the database.
  ///or when an error occurs in the upload process.
  void cancelMediaUpload({required String id}) {
    UploadChatContentItem uploadChatContentItem = _chatContentItemMap[id];
    uploadChatContentItem.uploadTask?.cancel();
    _uploadChatContentIdsQueue.remove(id);
    _removeChatContentItemFromMap(id: id);
    _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
  }

  ///called when image or video needs to be uploaded to Cloud Firestore and Storage.
  Future<String?> _uploadMedia({
    required File media,
    required String id,
    required UploadChatContentItem? uploadChatContentItem,
    required Reference mediaStorageRef,
  }) async {
    try {
      uploadChatContentItem?.uploadTask = mediaStorageRef.putFile(media);
      if (_uploadChatContentIdsQueue.first !=
          id) // only allows one media upload at a time.
        await uploadChatContentItem?.uploadTask?.pause();
      _chatContentItemsMapStreamController.sink.add(_chatContentItemMap);
      final TaskSnapshot? taskSnapshot =
          await uploadChatContentItem?.uploadTask;
      if (taskSnapshot != null) {
        final TaskState taskState = taskSnapshot.state;
        if (taskState == TaskState.success)
          return mediaStorageRef.getDownloadURL();
        else if (taskState == TaskState.error) {
          throw Error();
        }
      }
    } catch (e) {
      if (_chatContentItemMap.containsKey(id)) {
        cancelMediaUpload(id: id); //cancels media upload when an error occurs.
      }
      return null;
    }
  }

  ///sends ChatContentItems (messages) to the Cloud Firestore database.
  void sendChatContentItem({
    var content,
    required ChatContentItemType chatContentItemType,
  }) async {
    final String chatContentItemId =
        _firebaseServices.getNewChatContentItemId();
    final String chatContentItemTypeString =
        ChatContentItemTypeConverter.encode(chatContentItemType);
    if (chatContentItemType == ChatContentItemType.TEXT) {
      _firebaseServices.setChatContentItem(
        chatContentItemId: chatContentItemId,
        sentById: me!.id,
        content: content,
        createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
        chatContentItemTypeString: chatContentItemTypeString,
      ); //for TEXT just set data to Cloud Firestore.
    } else {
      //ChatContentItemType == VIDEO || ChatContentItemType == IMAGE.
      UploadChatContentItem uploadChatContentItem = UploadChatContentItem(
        content: content,
        chatContentItemType: chatContentItemType,
      );
      _chatContentItemMap[chatContentItemId] = uploadChatContentItem;
      _uploadChatContentIdsQueue.add(chatContentItemId);
      if (chatContentItemType == ChatContentItemType.IMAGE) {
        final imageStorageRef = _firebaseServices.getImageStorageRef(
            chatContentItemId: chatContentItemId);
        //for image only upload image file.
        final String? chatImageDownloadURL = await _uploadMedia(
            media: File(content),
            id: chatContentItemId,
            uploadChatContentItem: uploadChatContentItem,
            mediaStorageRef: imageStorageRef);
        if (chatImageDownloadURL != null) {
          //set image downloadURL to Firestore
          _firebaseServices.setChatContentItem(
              chatContentItemId: chatContentItemId,
              sentById: me!.id,
              content: chatImageDownloadURL,
              createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
              chatContentItemTypeString: chatContentItemTypeString);
        }
      }
      if (chatContentItemType == ChatContentItemType.VIDEO) {
        //for video upload both thumbnail and video
        final videoStorageRef = _firebaseServices.getVideoStorageRef(
          chatContentItemId: chatContentItemId,
          chatVideoItemFolder: ChatVideoItemFolder.VideoFile,
        );
        final String? chatVideoDownloadURL = await _uploadMedia(
          id: chatContentItemId,
          media: File(content[0]),
          uploadChatContentItem: uploadChatContentItem,
          mediaStorageRef: videoStorageRef,
        );
        if (chatVideoDownloadURL != null) {
          final videoStorageRef = _firebaseServices.getVideoStorageRef(
            chatContentItemId: chatContentItemId,
            chatVideoItemFolder: ChatVideoItemFolder.ThumbnailFile,
          );
          final String? chatThumbnailDownloadURL = await _uploadMedia(
            media: File(content[1]),
            id: chatContentItemId,
            uploadChatContentItem: uploadChatContentItem,
            mediaStorageRef: videoStorageRef,
          );
          if (chatThumbnailDownloadURL != null) {
            //set video and thumbnail downloadURLs to Firestore
            _firebaseServices.setChatContentItem(
                chatContentItemId: chatContentItemId,
                sentById: me!.id,
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
    _firebaseServices.deleteChatContentItem(id: id);
  }
}
