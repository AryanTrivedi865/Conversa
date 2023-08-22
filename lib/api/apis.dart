import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String userToken = "";

  static User get firebaseUser => auth.currentUser!;
  static String defaultImage =
      "https://firebasestorage.googleapis.com/v0/b/conversa-c283b.appspot.com/o/assets%2Fdefault-profile-picture.jpg?alt=media&token=a60424bd-6223-42bf-86fd-686812f2205d";
  static List<ChatUser> users = [];

  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(firebaseUser.uid).get())
        .exists;
  }

  static Future<void> createUser(
      String name, String email, String status, String photoURL) async {
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

  /** Stream **/

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('userID', isNotEqualTo: firebaseUser.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers(
      List<String> users) {
    return firestore
        .collection("users")
        .where('userID', whereIn: users)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getBlockedUsers(
      List<String> users) {
    return firestore
        .collection("users")
        .where('userID', whereNotIn: users)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatContacts() {
    return firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("chat_users")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getBlocked() {
    return firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("blocked_users")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getArchived() {
    return firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("archived_users")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getBlockedBy() {
    return firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("blocked_by_users")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentUser() {
    return firestore
        .collection("users")
        .where('userID', isEqualTo: firebaseUser.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUser(ChatUser user) {
    return firestore
        .collection("users")
        .where('userID', isEqualTo: user.userID)
        .snapshots();
  }

  /** User Functions **/

  static Future<void> blockUser(ChatUser user) async {
    deleteAllChat(user);
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("blocked_users")
        .doc(user.userID)
        .set({});
    await firestore
        .collection("users")
        .doc(user.userID)
        .collection("blocked_by_users")
        .doc(firebaseUser.uid)
        .set({});
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("chat_users")
        .doc(user.userID)
        .delete();
    await firestore
        .collection("users")
        .doc(user.userID)
        .collection("chat_users")
        .doc(firebaseUser.uid)
        .delete();
  }

  static Future<void> archiveUser(ChatUser user) async {
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("archived_users")
        .doc(user.userID)
        .set({});
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("chat_users")
        .doc(user.userID)
        .delete();
  }

  static Future<void> unarchiveUser(ChatUser user) async {
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("archived_users")
        .doc(user.userID)
        .delete();
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("chat_users")
        .doc(user.userID)
        .set({});
  }

  static Future<void> unblockUser(ChatUser user) async {
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("blocked_users")
        .doc(user.userID)
        .delete();
    await firestore
        .collection("users")
        .doc(user.userID)
        .collection("blocked_by_users")
        .doc(firebaseUser.uid)
        .delete();
  }

  static Future<void> addUser(ChatUser user) async {
    await firestore
        .collection("users")
        .doc(user.userID)
        .collection("chat_users")
        .doc(firebaseUser.uid)
        .set({});
    await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("chat_users")
        .doc(user.userID)
        .set({});
  }

  /** Chat Functions **/
  static Future<void> deleteMessage(
      ChatUser user, MessageModel messageModel) async {
    String messageID = messageModel.sendTime;
    String messageType = messageModel.messageType;
    String messageCon = messageModel.messageContent;
    final ref = firestore
        .collection("chats/${getConversationID(user.userID)}/messages/");
    try {
      if (messageType == "image" ||
          messageType == "video" ||
          messageType == "audio" ||
          messageType == "document") {
        final storageRef = storage.refFromURL(messageCon);
        await storageRef.delete();
      }
      await ref.doc(messageID).delete();
      log("Message Deleted");
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> deleteAllChat(ChatUser user) async {
    final ref = firestore
        .collection("chats/${getConversationID(user.userID)}/messages/");
    try {
      await ref.get().then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
      firestore
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("chat_users")
          .doc(user.userID)
          .delete();
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> editMessage(
      ChatUser user, String messageID, String messageContent) async {
    final ref = firestore
        .collection("chats/${getConversationID(user.userID)}/messages/");
    try {
      await ref.doc(messageID).update({"messageContent": messageContent});
      log("Message Edited");
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    if (token != null) {
      log("token: $token");
      userToken = token;
      firestore.collection("users").doc(firebaseUser.uid).update({
        "userPushToken": token,
      });
    }
    firestore.collection("users").doc(firebaseUser.uid).update({
      "userOnlineStatus": isOnline,
      "userLastActive": time,
    });
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
    await ref
        .doc(docID)
        .set(messageModel.toJson())
        .then((value) => sendPushNotification(
            user,
            messageType == "text"
                ? messageContent
                : messageType == "image"
                    ? "Image"
                    : messageType == "video"
                        ? "Video"
                        : messageType == "audio"
                            ? "Audio"
                            : messageType == "document"
                                ? "File"
                                : "Images"))
        .then((value) {
      firestore
          .collection("users")
          .doc(user.userID)
          .collection("chat_users")
          .doc(firebaseUser.uid)
          .set({});
      firestore
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("chat_users")
          .doc(user.userID)
          .set({});
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String message) async {
    final body = {
      "to": chatUser.userPushToken,
      "notification": {
        "title": firebaseUser.displayName,
        "body": message,
        //add icon
        "icon": firebaseUser.photoURL,
        "android_channel_id": "conversa_chats_notification",
      },
      "data": ChatUser(
              userID: firebaseUser.uid,
              userName: firebaseUser.displayName!,
              userAbout: "",
              userCreatedTime: "",
              userImageUrl: firebaseUser.photoURL!,
              userOnlineStatus: false,
              userPushToken: userToken,
              userLastActive: DateTime.now().millisecondsSinceEpoch.toString(),
              userAuthenticationCredentials: (firebaseUser.email != null
                  ? firebaseUser.email
                  : firebaseUser.phoneNumber)!)
          .toJson(),
    };
    try {
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAVsuyLZA:APA91bEH7ffM3b-NKAAzn9vtvq-3t5_iASaWYl7h8-QqquOjz1TdnmtmCFr0WyYNEFkLEji-oe1et8oFsA0FR3WKNI5Xm0vQNOOWzzCmx7F6U0XKRh7J1iRptcLuG0Ri-AxP4B3rnjZ1'
              },
              body: jsonEncode(body));
      log(response.body);
      log(response.statusCode.toString());
    } catch (e) {
      log(e.toString());
    }
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
