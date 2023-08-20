import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/welcome_screen.dart';
import 'package:conversa/main.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:conversa/utils/photo_zoom.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ChatUser chatUser;
  late String name, about;

  bool deleteProfile = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Conversa",
            style: TextStyle(
              fontSize: ScreenUtils.screenWidthRatio(context, 0.08),
              fontFamily: "BackToBlack",
            ),
          ),
          centerTitle: true,
          actions: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: IconButton(
                key: ValueKey<bool>(brightness == Brightness.dark),
                onPressed: () {
                  _toggleTheme(
                      context,
                      Theme.of(context).brightness == Brightness.dark
                          ? ThemeMode.light
                          : ThemeMode.dark);
                },
                icon: Icon(
                  brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  size: ScreenUtils.screenWidthRatio(context, 0.06),
                ),
              ),
            ),
          ],
        ),
        body: deleteProfile
            ? Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: APIs.getCurrentUser(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final current =
                      ChatUser.fromJson(snapshot.data!.docs.first.data());
                  chatUser = current;
                  return Wrap(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ZoomImage(
                                              photoUrl: current.userImageUrl,
                                              tag: "userProfile")));
                                },
                                icon: Hero(
                                  tag: "zoomProfileImage",
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(current.userImageUrl),
                                    radius: ScreenUtils.screenWidthRatio(
                                        context, 0.15),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton(
                                  onPressed: () {
                                    _showEditModal();
                                  },
                                  icon: const CircleAvatar(
                                    child: Icon(Icons.edit),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  ScreenUtils.screenHeightRatio(context, 0.01)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              current.userName,
                              style: Theme.of(context).textTheme.headlineLarge,
                              //handle overflow
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                              height:
                                  ScreenUtils.screenHeightRatio(context, 0.01)),
                          Text(
                            current.userAuthenticationCredentials,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(
                              height:
                                  ScreenUtils.screenHeightRatio(context, 0.03)),
                          SizedBox(
                            width: ScreenUtils.screenWidthRatio(context, .5),
                            height:
                                ScreenUtils.screenHeightRatio(context, 0.06),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(elevation: 12),
                              onPressed: () {
                                _showProfileUpdate();
                              },
                              child: const Text(
                                "Edit Profile",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.025)),
                          _divider("Profile Information"),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.025)),
                          _buildInfoRow(
                              "Created On",
                              EpochToDate.getFormattedDate(
                                  context, current.userCreatedTime)),
                          _buildInfoRow("Status", current.userAbout),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.025)),
                          _divider("Profile Actions"),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.025)),
                          _button(FontAwesomeIcons.rightFromBracket, "Logout",
                              _handleLogoutClick),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.012)),
                          _button(FontAwesomeIcons.receipt,
                              "Download Account Info", _downloadAccountInfo),
                          SizedBox(
                              height: ScreenUtils.screenHeightRatio(
                                  context, 0.012)),
                          _button(FontAwesomeIcons.userXmark, "Delete Account",
                              _deleteAccount),
                        ],
                      ),
                    ],
                  );
                }));
  }

  void _handleLogoutClick() {
    Dialogs.showDialogSingleButton(context, "Log Out",
        "Do you really want to logout?", "Yes", _logout, "No", () {
      Navigator.pop(context);
    });
  }

  void _deleteAccount() {
    Dialogs.showDialogSingleButton(
        context,
        "Delete Account",
        "Do you really want to delete your account?",
        "Yes",
        () {
          Navigator.pop(context);
          _showConfirm();
        },
        "No",
        () {
          Navigator.pop(context);
        });
  }

  void _showConfirm() {
    TextEditingController _confirmController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete your account"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "This action cannot be undone. To confirm, please type \"DELETE MY ACCOUNT\" below."),
                SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.02)),
                TextFormField(
                  controller: _confirmController,
                  decoration: InputDecoration(
                    labelText: "Confirm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    if (_confirmController.text == "DELETE MY ACCOUNT") {
                      _deleteAccountConfirmed();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Account not deleted.");
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Yes")),
            ],
          );
        });
  }

  void _deleteAccountConfirmed() async {
    setState(() {
      deleteProfile = true;
    });
    await APIs.firestore
        .collection("users")
        .doc(APIs.firebaseUser.uid)
        .delete();
    await APIs.firebaseUser.delete();
    //delete all chats which have this user

    _logout();
  }

  void _downloadAccountInfo() async {
    Map<String, dynamic> data = await APIs.firestore
        .collection("users")
        .doc(APIs.firebaseUser.uid)
        .get()
        .then((value) => value.data()!);
    Map<String, dynamic> json = {
      "userAuthenticationCredentials": data["userAuthenticationCredentials"],
      "userCreatedTime":
          EpochToDate.getFormattedDate(context, data["userCreatedTime"]),
      "userImageUrl": data["userImageUrl"],
      "userName": data["userName"],
      "userAbout": data["userAbout"],
    };
    try {
      final dir = Directory('/storage/emulated/0/Documents/Conversa/');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/account_info.txt');
      await file.writeAsString(jsonEncode(json));
      Fluttertoast.showToast(msg: 'Account info downloaded');
      print("File saved at ${file.path}");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _logout() async {
    await APIs.auth.signOut();
    await GoogleSignIn().signOut().then((value) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (Route<dynamic> route) => false,
        ));
  }

  Widget _button(IconData icon, String message, VoidCallback voidCallback) {
    return SizedBox(
      width: ScreenUtils.screenWidthRatio(context, 0.8),
      height: ScreenUtils.screenHeightRatio(context, 0.06),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 12),
        onPressed: voidCallback,
        child: Row(
          children: [
            Icon(icon, size: ScreenUtils.screenWidthRatio(context, 0.06)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtils.screenHeightRatio(context, 0.016),
          horizontal: ScreenUtils.screenWidthRatio(context, 0.04)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtils.screenWidthRatio(context, 0.045),
            ),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: ScreenUtils.screenWidthRatio(context, 0.045)),
          ),
        ],
      ),
    );
  }

  Widget _divider(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
          child: Divider(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.screenWidthRatio(context, 0.036)),
          child: Text(
            message,
            style: TextStyle(
                fontSize: ScreenUtils.screenWidthRatio(context, 0.05)),
          ),
        ),
        const Expanded(
          child: Divider(),
        ),
      ],
    );
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          key: GlobalKey(),
          child: SizedBox(
            height: ScreenUtils.screenHeightRatio(context, 0.221),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, left: 16, right: 8, bottom: 4),
                    child: SizedBox(
                      width: ScreenUtils.screenWidthRatio(context, 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text("Profile photo",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.start),
                          ),
                          IconButton(
                              onPressed: () => _handleDeleteButton(),
                              icon: const Icon(Icons.delete),
                              alignment: Alignment.centerRight)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 6),
                          child: Column(
                            children: [
                              IconButton.outlined(
                                  onPressed: () async {
                                    ImagePicker imagePicker = ImagePicker();
                                    XFile? galleryImage = await imagePicker
                                        .pickImage(source: ImageSource.camera);
                                    if (galleryImage != null) {
                                      updateProfilePhoto(
                                          File(galleryImage.path));
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  iconSize: 28,
                                  padding: const EdgeInsets.all(12)),
                              const Text(
                                "Camera",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 6),
                          child: Column(
                            children: [
                              IconButton.outlined(
                                  onPressed: () async {
                                    ImagePicker imagePicker = ImagePicker();
                                    XFile? galleryImage = await imagePicker
                                        .pickImage(source: ImageSource.gallery);
                                    if (galleryImage != null) {
                                      updateProfilePhoto(
                                          File(galleryImage.path));
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.photo),
                                  iconSize: 28,
                                  padding: const EdgeInsets.all(12)),
                              const SizedBox(height: 4),
                              const Text(
                                "Gallery",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onSaved: (val) => chatUser.userName = val ?? "",
                  initialValue: chatUser.userName,
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onSaved: (val) => chatUser.userAbout = val ?? "",
                  initialValue: chatUser.userAbout,
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.import_contacts),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  log("inside validator");
                  _formKey.currentState!.save();
                  updateUserInfo(chatUser.userName, chatUser.userAbout);
                  Navigator.of(context).pop();
                } else {}
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteButton() {
    Dialogs.showDialogSingleButton(
        context,
        "Edit Profile",
        "Do you really want to delete your profile picture?",
        "Yes",
        deleteProfilePic,
        "No", () {
      Navigator.pop(context);
    });
  }

  updateProfilePhoto(File file) async {
    final extension = file.path.split(".").last;
    final storageRef = APIs.storage
        .ref()
        .child("profilePicture/${APIs.firebaseUser.uid}.$extension");
    await storageRef
        .putFile(file, SettableMetadata(contentType: "image/$extension"))
        .then((p0) {
      log("Data transferred: ${p0.bytesTransferred} Kb");
    });
    final String path = await storageRef.getDownloadURL();
    await APIs.firestore.collection("users").doc(APIs.firebaseUser.uid).update({
      "userImageUrl": path,
    });
    await APIs.firebaseUser.updatePhotoURL(path);
  }

  deleteProfilePic() {
    APIs.firestore
        .collection("users")
        .doc(APIs.firebaseUser.uid)
        .update({"userImageUrl": APIs.defaultImage});
    APIs.firebaseUser.updatePhotoURL(APIs.defaultImage);
    Navigator.pop(context);
  }

  void _toggleTheme(BuildContext context, ThemeMode themeMode) {
    const conversa = Conversa();
    conversa.toggleThemeMode(themeMode);
  }

  Future<void> updateUserInfo(String userName, String userAbout) async {
    await APIs.firestore.collection("users").doc(APIs.firebaseUser.uid).update({
      "userName": userName,
      "userAbout": userAbout,
    });
  }
}
