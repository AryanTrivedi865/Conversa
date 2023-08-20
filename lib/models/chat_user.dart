import 'package:conversa/api/apis.dart';

class ChatUser {
  ChatUser({
    required this.userImageUrl,
    required this.userOnlineStatus,
    required this.userCreatedTime,
    required this.userPushToken,
    required this.userLastActive,
    required this.userName,
    required this.userID,
    required this.userAbout,
    required this.userAuthenticationCredentials,
  });

  late String userImageUrl;
  late bool userOnlineStatus;
  late String userCreatedTime;
  late String userPushToken;
  late String userLastActive;
  late String userName;
  late String userID;
  late String userAbout;
  late String userAuthenticationCredentials;

  ChatUser.fromJson(Map<String, dynamic> json) {
    userImageUrl = json['userImageUrl'] ?? APIs.defaultImage;
    userOnlineStatus = json['userOnlineStatus'] ?? false;
    userCreatedTime = json['userCreatedTime'] ?? "";
    userPushToken = json['userPushToken'] ?? "";
    userLastActive = json['userLastActive'] ?? "";
    userName = json['userName'] ?? "";
    userID = json['userID'] ?? "";
    userAbout = json['userAbout'] ?? "";
    userAuthenticationCredentials = json['userAuthenticationCredentials'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userImageUrl'] = userImageUrl;
    data['userOnlineStatus'] = userOnlineStatus;
    data['userCreatedTime'] = userCreatedTime;
    data['userPushToken'] = userPushToken;
    data['userLastActive'] = userLastActive;
    data['userName'] = userName;
    data['userID'] = userID;
    data['userAbout'] = userAbout;
    data['userAuthenticationCredentials'] = userAuthenticationCredentials;
    return data;
  }
}
