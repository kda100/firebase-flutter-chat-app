import 'dart:async';
import 'dart:collection';
import 'package:firebase_chat_app/models/chat_item_models/chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_models/cloud_chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_models/upload_chat_item.dart';
import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/responses/chat_response.dart';
import '../models/responses/file_response.dart';
import 'package:firebase_chat_app/services/file_services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/firebase_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_video_item_folder.dart';
import '../models/user.dart';

///class that contains all the business logic needed for maintaining data of the chat app.
///It communicates with FirebaseServices to read and write data to be fed to the chat provider of the chat screen.

///This class listens to a Cloud Firestore collection containing messages then modifies a map containing
///chat content items that is sent into a stream to update the chat screen.
///By doing this the class is able to add images and videos being uploaded to the same map
///so users can see the upload progress of their videos and images being uploaded.

class ChatRepository {
  final FirebaseServices _firebaseServices =
      FirebaseServices(); //class containing services to read and write to firebase
  final FileServices _fileServices = FileServices();
  User? _me; //User object for user of chat
  User? _recipient; //Usr object for recipient in chat

  Map<String, ChatItem> _chatItemMap =
      {}; //map where all chat content items (messages) are stored, these are displayed on chat screen, keys are the firebase id references.
  List<String> _chatItemKeys = [];
  Queue<String> _uploadChatItemsIdsQueue =
      Queue(); //control image and videos being upload so only one at time.
  List<String> _unreadChatItemIds =
      []; //list to store ids of chat content items that have not been read.
  StreamController<ChatResponse> chatResponseStreamController =
      StreamController<ChatResponse>();

  ///used in stream builder in chat screen
  Stream<ChatResponse> get chatResponseStream =>
      chatResponseStreamController.stream;

  String get myName => _me!.name;

  String get recipientName => _recipient!.name;

  Map<String, ChatItem> get chatItemMap => _chatItemMap;

  List<String> get chatItemKeys => _chatItemKeys;

  ///this function removes cached files once they have been uploaded to storage.
  Future<void> _deleteChatItemCache({required String id}) async {
    final UploadChatItem? uploadChatItem = (_chatItemMap[id] as UploadChatItem);
    if (uploadChatItem != null) {
      final ChatItemType chatItemType = uploadChatItem.chatItemType;
      final content = uploadChatItem.content;
      if (chatItemType == ChatItemType.IMAGE)
        _fileServices.deleteFile(filePath: content);
      else if (chatItemType == ChatItemType.VIDEO)
        _fileServices.deleteFiles(
          filePaths: content,
        );
    }
  }

  void _removeChatItemFromMap({
    required String id,
  }) {
    if (_chatItemMap.containsKey(id)) {
      _chatItemMap.remove(id);
    }
  }

  /// function called when an image or video has been uploaded to cloud.
  /// removes media file from cache and ChatContentItem from map.
  /// then calls for next media item to be uploaded to cloud.
  void _onUploadChatItemUploaded({required String id}) {
    _deleteChatItemCache(id: id);
    _removeChatItemFromMap(id: id);
    _uploadChatItemsIdsQueue.remove(id);
    if (_uploadChatItemsIdsQueue.isNotEmpty) {
      final UploadChatItem nextUploadChatItem =
          _chatItemMap[_uploadChatItemsIdsQueue.first] as UploadChatItem;
      if (nextUploadChatItem.uploadTask != null)
        nextUploadChatItem.uploadTask?.resume();
    }
  }

  ///used to determine whether chat content item should be put at the start or the end of
  ///the chatContentItemsMap
  bool _isAfterFirstChatItem({required DateTime createdAt}) {
    if (_chatItemMap.isNotEmpty) {
      final DateTime? firstCreatedAt =
          _chatItemMap[_chatItemMap.keys.first]?.createdAt;
      if (firstCreatedAt != null) return createdAt.isAfter(firstCreatedAt);
    }
    return false;
  }

  /// called when timestamp/createdAt of ChatContentItem added is before the last chat content item in the ChatContentItemsMap.
  void _insertChatItemAtStart({
    required CloudChatItem cloudChatItem,
    required String id,
  }) {
    final Map<String, ChatItem> newMainChatItemMap = {};
    newMainChatItemMap[id] = cloudChatItem;
    newMainChatItemMap.addAll(_chatItemMap);
    _chatItemMap = newMainChatItemMap;
  }

  ///function calls at start of app, it fetches data from firebase and sets up listener for chat content items (messages).
  ///listener modifies the chatContentItemMap accordingly.
  ///then updates the chatContentItemsMapStreamController and Chat Screen to reflect any changes in messages.
  Future<void> setUpChatData() async {
    _me = await _firebaseServices.fetchMyData();
    _recipient = await _firebaseServices.fetchRecipientData();
    _firebaseServices.setUpChatItemsCollectionSnapshotListener(
      limit: 100,
      onError: (_) {
        chatResponseStreamController.sink.add(ChatResponse.error());
      },
      onData: (chatItemFirestoreDataSnapshot) async {
        bool updateStream = false;
        chatItemFirestoreDataSnapshot.docChanges.forEach(
          //iterates over each doc change.
          (chatItemDocChange) {
            final DocumentSnapshot chatContentItemDoc = chatItemDocChange.doc;
            final String id = chatContentItemDoc.id;
            if (chatItemDocChange.type == DocumentChangeType.added ||
                chatItemDocChange.type == DocumentChangeType.modified) {
              final Map<String, dynamic>? chatItemData =
                  chatContentItemDoc.data();
              if (chatItemData != null) {
                final bool chatItemExists = _chatItemMap.containsKey(id);
                if (chatItemExists &&
                    _chatItemMap[id].runtimeType == UploadChatItem) {
                  //image or video has been uploaded.
                  _onUploadChatItemUploaded(id: id);
                }
                final CloudChatItem cloudChatItem = CloudChatItem.fromFirestore(
                    cloudChatItemData: chatItemData, myId: _me!.id);
                if (!cloudChatItem
                        .isRecipient || //all chat content items sent by user.
                    (cloudChatItem
                            .isRecipient && //only chat content items with onCloud, that has been received and are not in ChatContentItemMap.
                        cloudChatItem.onCloud &&
                        !chatItemExists)) {
                  updateStream = true;
                  if (cloudChatItem.isRecipient && !cloudChatItem.read) {
                    //messages received will go into unread list.
                    _unreadChatItemIds.add(id);
                  }
                  if (chatItemExists) {
                    //ChatContentItem sent by user, read = true or onCloud = true
                    _chatItemMap[id] = cloudChatItem;
                  } else if (_isAfterFirstChatItem(
                      createdAt: cloudChatItem.createdAt)) {
                    //if true add item at end of map
                    _chatItemMap[id] = cloudChatItem;
                  } else {
                    //add chat content item at start of map.
                    _insertChatItemAtStart(
                        id: id, cloudChatItem: cloudChatItem);
                  }
                }
              }
            } else if (chatItemDocChange.type == DocumentChangeType.removed) {
              updateStream = true;
              _removeChatItemFromMap(
                id: id,
              );
            }
          },
        );
        if (updateStream) //not every instance of new doc is chat screen updated.
          _chatItemKeys = _chatItemMap.keys.toList();
        chatResponseStreamController.sink.add(ChatResponse.update());
      },
    );
    chatResponseStreamController.sink
        .add(ChatResponse.update()); //called when function is first called.
  }

  ///this function converts all the read fields of the chat content items to true.
  void updateReadReceipts() async {
    if (_unreadChatItemIds.isNotEmpty) {
      _unreadChatItemIds.forEach((id) async {
        await _firebaseServices.updateReadReceipt(id: id);
        _unreadChatItemIds.remove(id);
      });
    }
  }

  ///function to get file from devices storage
  Future<FileResponse?> getFilePath({required fileType}) async {
    final bool storagePermission = await _fileServices.storagePermissionRequest(
        permission: Permission.storage); //check apps storage permission
    if (storagePermission) {
      final String? filePath =
          await _fileServices.getFilePath(fileType: fileType);
      if (filePath != null) {
        final bool isValid = await _fileServices.checkFileSize(
          //file size must not exceed a limit
          File(filePath),
        );
        if (isValid) {
          return FileResponse.success(
            filePath: filePath,
            fileType: fileType,
          );
        } else {
          return FileResponse.sizeExceeded();
        }
      }
      return null;
    }
    return FileResponse.accessDenied();
  }

  ///Called when user cancels image or videos being uploaded to the database.
  ///or when an error occurs in the upload process.
  void cancelMediaUpload({required String id}) {
    UploadChatItem uploadChatItem = _chatItemMap[id] as UploadChatItem;
    uploadChatItem.uploadTask?.cancel();
    _deleteChatItemCache(id: id);
    _uploadChatItemsIdsQueue.remove(id);
    _removeChatItemFromMap(id: id);
    chatResponseStreamController.sink.add(ChatResponse.update());
  }

  ///called when image or video needs to be uploaded to Cloud Firestore and Storage.
  Future<String?> _uploadMedia({
    required File media,
    required String id,
    required UploadChatItem? uploadChatItem,
    required Reference mediaStorageRef,
  }) async {
    try {
      uploadChatItem?.uploadTask = mediaStorageRef.putFile(media);
      if (_uploadChatItemsIdsQueue.first !=
          id) // only allows one media upload at a time.
        await uploadChatItem?.uploadTask?.pause();
      chatResponseStreamController.sink.add(ChatResponse.update());
      final TaskSnapshot? taskSnapshot = await uploadChatItem?.uploadTask;
      if (taskSnapshot != null) {
        final TaskState taskState = taskSnapshot.state;
        if (taskState == TaskState.success)
          return mediaStorageRef.getDownloadURL();
        else if (taskState == TaskState.error) {
          throw Error();
        }
      }
    } catch (e) {
      if (_chatItemMap.containsKey(id)) {
        cancelMediaUpload(id: id); //cancels media upload when an error occurs.
      }
      return null;
    }
  }

  ///function for sending text messages
  void sendChatTextItem({required String message}) {
    _firebaseServices.setChatItem(
      chatItemId: _firebaseServices.getNewChatItemId(),
      sentById: _me!.id,
      content: message,
      createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
      chatItemType: ChatItemType.TEXT,
    );
  }

  ///function creates a UploadChatContentItem for and adds to chatContentItemsMap to
  ///be displayed by the UI.
  UploadChatItem _createUploadChatItem({
    required String chatItemId,
    required content,
    required ChatItemType chatItemType,
  }) {
    UploadChatItem uploadChatItem = UploadChatItem(
      content: content,
      chatItemType: chatItemType,
    );
    _chatItemMap[chatItemId] = uploadChatItem;
    _chatItemKeys = _chatItemMap.keys.toList();
    _uploadChatItemsIdsQueue.add(chatItemId);
    return uploadChatItem;
  }

  ///function for sending images to Firestore.
  void sendChatImageItem({required String imagePath}) async {
    final String chatItemId = _firebaseServices.getNewChatItemId();
    final UploadChatItem uploadChatItem = _createUploadChatItem(
      chatItemId: chatItemId,
      content: imagePath,
      chatItemType: ChatItemType.IMAGE,
    );
    final imageStorageRef =
        _firebaseServices.getImageStorageRef(chatItemId: chatItemId);
    //for image only upload image file.
    final String? chatImageDownloadURL = await _uploadMedia(
      media: File(imagePath),
      id: chatItemId,
      uploadChatItem: uploadChatItem,
      mediaStorageRef: imageStorageRef,
    );
    if (chatImageDownloadURL != null) {
      //set image downloadURL to Firestore
      _firebaseServices.setChatItem(
          chatItemId: chatItemId,
          sentById: _me!.id,
          content: chatImageDownloadURL,
          createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
          chatItemType: ChatItemType.IMAGE);
    }
  }

  ///sends videos to the Cloud Firestore database.
  void sendChatVideoItem({
    required String videoPath,
  }) async {
    final File? thumbnail =
        await _fileServices.genVideoThumbnail(videoPath: videoPath);
    if (thumbnail != null) {
      final String chatItemId = _firebaseServices.getNewChatItemId();
      final UploadChatItem uploadChatItem = _createUploadChatItem(
          content: [videoPath, thumbnail.path],
          chatItemId: chatItemId,
          chatItemType: ChatItemType.VIDEO);
      final Reference videoStorageRef = _firebaseServices.getVideoStorageRef(
        chatItemId: chatItemId,
        chatVideoItemFolder: ChatVideoItemFolder.VideoFile,
      );
      final String? chatVideoDownloadURL = await _uploadMedia(
        id: chatItemId,
        media: File(videoPath),
        uploadChatItem: uploadChatItem,
        mediaStorageRef: videoStorageRef,
      );
      if (chatVideoDownloadURL != null) {
        final thumbnailStorageRef = _firebaseServices.getVideoStorageRef(
          chatItemId: chatItemId,
          chatVideoItemFolder: ChatVideoItemFolder.ThumbnailFile,
        );
        final String? chatThumbnailDownloadURL = await _uploadMedia(
          media: File(thumbnail.path),
          id: chatItemId,
          uploadChatItem: uploadChatItem,
          mediaStorageRef: thumbnailStorageRef,
        );
        if (chatThumbnailDownloadURL != null) {
          //set video and thumbnail downloadURLs to Firestore
          _firebaseServices.setChatItem(
              chatItemId: chatItemId,
              sentById: _me!.id,
              content: [chatVideoDownloadURL, chatThumbnailDownloadURL],
              createdAtTimestamp: Timestamp.fromDate(DateTime.now()),
              chatItemType: ChatItemType.VIDEO);
        }
      }
    }
  }

  ///Function for user to remove chat content item from Cloud firestore.
  void unSendChatContentItem({
    required String id,
  }) async {
    _firebaseServices.deleteChatItem(id: id);
  }
}
