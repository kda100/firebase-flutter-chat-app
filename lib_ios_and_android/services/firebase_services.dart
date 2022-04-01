import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/firebase_field_names.dart';
import '../models/chat_video_item_folder.dart';

///class that contains references to firebase collections, docs and storage references.
///It contains useful functions that helpers the Chat Provider perform functions after user interaction.
class FirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._();

  FirebaseServices._();

  factory FirebaseServices() {
    return _instance;
  }

  final CollectionReference _chatItemsCollection = FirebaseFirestore.instance
      .collection("chatItems"); //Firebase Firestore col ref for all messages

  ///function to get chat app (me) data from firestore.
  Future<User?> fetchMyData() async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.doc("users/1234").get();
    if (userDoc.exists) {
      return User(id: userDoc.id, name: userDoc[FieldNames.nameField]);
    }
    return null;
  }

  ///function to get user (recipient) data from firestore.
  Future<User?> fetchRecipientData() async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.doc("users/4321").get();
    if (userDoc.exists) {
      return User(id: userDoc.id, name: userDoc[FieldNames.nameField]);
    }
    return null;
  }

  ///function that communicates with chat content items collection to create a listener for messages.
  void setUpChatItemsCollectionSnapshotListener(
      {required int limit,
      required void Function(QuerySnapshot)? onData,
      required void Function(Object) onError}) {
    _chatItemsCollection
        .orderBy(
          FieldNames.createdAtField,
        )
        .limitToLast(limit) //limit to only 100 messages
        .snapshots()
        .listen(
      onData,
      onError: (error) {
        print(error);
        onError(error);
      },
      cancelOnError: false,
    );
  }

  ///gets id for a new chat content item.
  String getNewChatItemId() {
    return _chatItemsCollection.doc().id;
  }

  ///sets chat content item data to Cloud Firestore database.
  Future<void> setChatItem({
    required String chatItemId,
    required String sentById,
    required var content,
    required Timestamp createdAtTimestamp,
    required ChatItemType chatItemType,
  }) async {
    _chatItemsCollection.doc(chatItemId).set({
      FieldNames.contentField: content,
      FieldNames.createdAtField: createdAtTimestamp,
      FieldNames.chatItemTypeField: ChatItemTypeConverter.encode(chatItemType),
      FieldNames.sentByIdField: sentById,
      FieldNames.onCloudField: false,
      FieldNames.readField: false,
    });
  }

  ///get image storage reference for new image message
  Reference getImageStorageRef({required String chatItemId}) {
    return FirebaseStorage.instance.ref("images").child(chatItemId);
  }

  ///gets thumbnail and video storage reference for video message.
  Reference getVideoStorageRef({
    required String chatItemId,
    required ChatVideoItemFolder chatVideoItemFolder,
  }) {
    final Reference videoItemStorageRef =
        FirebaseStorage.instance.ref("videos").child(chatItemId);
    if (chatVideoItemFolder == ChatVideoItemFolder.VideoFile) {
      return videoItemStorageRef.child(
        "video",
      );
    } else {
      return videoItemStorageRef.child(
        "thumbnail",
      );
    }
  }

  ///changes read receipts to true for all unread messages in firestore.
  Future<void> updateReadReceipt({required String id}) async {
    try {
      //user may delete message before it is read.
      await _chatItemsCollection.doc(id).update({FieldNames.readField: true});
    } catch (e) {
      return;
    }
  }

  ///deletes message.
  Future<void> deleteChatItem({required String id}) async {
    await _chatItemsCollection.doc(id).delete();
  }
}
