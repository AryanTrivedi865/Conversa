import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get firebaseUser => auth.currentUser!;
  static String defaultImage = "https://firebasestorage.googleapis.com/v0/b/conversa-c283b.appspot.com/o/assets%2Fdefault-profile-picture.jpg?alt=media&token=a60424bd-6223-42bf-86fd-686812f2205d";
  static List<ChatUser> users = [];

  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(firebaseUser.uid).get()).exists;
  }

  static Future<void> createUser(String name, String email,String status, String photoURL) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    final user = ChatUser(
      userID: auth.currentUser!.uid,
      userName: name,
      userAbout: status,
      userCreatedTime: time,
      userImageUrl: photoURL,
      userOnlineStatus: false,
      userPushToken: "",
      userLastActive: time,
      userAuthenticationCredentials: email,
    );
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .set(user.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('userID', isNotEqualTo: firebaseUser.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentUser() {
    return firestore
        .collection("users")
        .where('userID', isEqualTo: firebaseUser.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser chatUser) {
    return firestore
        .collection("chats/${getConversationID(chatUser.userID)}/messages/")
        .snapshots();
  }

  static String getConversationID(String userID) =>
      firebaseUser.uid.hashCode <= userID.hashCode
          ? '${firebaseUser.uid}_$userID'
          : '${userID}_${firebaseUser.uid}';

  static Future<void> sendMessages(
      ChatUser user, String messageContent, String messageType) async {
    String docID = DateTime.now().millisecondsSinceEpoch.toString();
    final MessageModel messageModel = MessageModel(
        senderID: firebaseUser.uid,
        receiverID: user.userID,
        messageType: messageType,
        readTime: "",
        sendTime: docID,
        messageContent: messageContent);
    final ref = firestore
        .collection("chats/${getConversationID(user.userID)}/messages/");
    await ref.doc(docID).set(messageModel.toJson());
  }

  static Future<void> updateMessageReadStatus(MessageModel messageModel) async {
    if (messageModel.readTime.isEmpty) {
      // Check if readTime is empty
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      firestore
          .collection(
              "chats/${getConversationID(messageModel.senderID)}/messages/")
          .doc(messageModel.sendTime)
          .update({"readTime": time});
      log("created: ${messageModel.sendTime} read:$time");
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection("chats/${getConversationID(chatUser.userID)}/messages/")
        .limit(1)
        .orderBy('sendTime', descending: true)
        .snapshots();
  }
}
