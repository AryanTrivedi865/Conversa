import 'dart:developer';
import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/screens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/utils.dart';

class CreateUserScreen extends StatefulWidget {
  final String authCred;
  final String authType;
  final String name;

  const CreateUserScreen(
      {super.key,
      required this.authCred,
      required this.authType,
      required this.name});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  late Color buttonColor;
  late Color textColor;
  late Color buttonTextColor;

  ButtonState state = ButtonState.idle;
  bool isAnimating = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController statusController =
      TextEditingController(text: "Available on Conversa");

  TextEditingController emailController = TextEditingController();

  File? profileFile;
  String profileUrl = APIs.defaultImage;

  @override
  Widget build(BuildContext context) {
    if (widget.name.isNotEmpty) {
      nameController.text = widget.name;
    }
    emailController.text = widget.authCred.isNotEmpty ? widget.authCred : "";
    final isDone = state == ButtonState.done;
    final isStretched = isAnimating || state == ButtonState.idle;
    buttonColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Theme.of(context).colorScheme.onSurface;
    buttonTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Colors.black;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.025)),
                      Text(
                        'Hey There!',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.01)),
                      Text(
                        'Create new user',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.02)),
                      Center(
                        child: Stack(
                          children: [
                            profileFile != null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: FileImage(profileFile!),
                                  )
                                : CircleAvatar(
                                    radius: 64,
                                    backgroundImage:
                                        NetworkImage(APIs.defaultImage),
                                  ),
                            Positioned(
                              right: -8,
                              bottom: -8,
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
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.04)),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: textColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        cursorColor: textColor,
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.02)),
                      TextFormField(
                        controller: emailController,
                        showCursor: false,
                        decoration: InputDecoration(
                          labelText: widget.authType == "email"
                              ? 'Email'
                              : 'Phone Number',
                          labelStyle: TextStyle(color: textColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        cursorColor: textColor,
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.02)),
                      TextFormField(
                        controller: statusController,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: textColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        cursorColor: textColor,
                      ),
                      SizedBox(
                          height: ScreenUtils.screenHeightRatio(context, 0.02)),
                      Container(
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          width: state == ButtonState.idle
                              ? ScreenUtils.screenWidthRatio(context, 1)
                              : ScreenUtils.screenHeightRatio(context, 0.065),
                          height: ScreenUtils.screenHeightRatio(context, 0.065),
                          onEnd: () => setState(() => isAnimating = !isAnimating),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          child: isStretched
                              ? _animatedButton()
                              : _animatedSmallButton(isDone),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _animatedButton() {
    return FilledButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            state = ButtonState.loading;
          });
          if (profileFile != null) {
            profileUrl = await updateProfilePhoto(profileFile!);
          }
          await APIs.firestore.collection("users").doc(APIs.firebaseUser.uid).update({
            "userID": APIs.firebaseUser.uid,
            "userName": nameController.text,
            "userAuthenticationCredentials": emailController.text,
            "userAbout": statusController.text,
            "userImageUrl": profileUrl,
          }).then((value) {
            setState(() {
              state = ButtonState.done;
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false);
          });
        }
      },
      child: Text(
        'Next',
        style: GoogleFonts.poppins(
          fontSize: 18,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  _animatedSmallButton(bool isDone) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? Colors.green.shade400 : buttonColor,
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.done, color: buttonTextColor, size: 32)
            : CircularProgressIndicator(
                strokeWidth: 2,
                color: buttonTextColor,
              ),
      ),
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
                                      setState(() {
                                        profileFile = File(galleryImage.path);
                                      });
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
                                      setState(() {
                                        profileFile = File(galleryImage.path);
                                      });
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

  Future<String> updateProfilePhoto(File file) async {
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
    setState(() {
      profileUrl = path;
    });
    return path;
  }
}

enum ButtonState {
  idle,
  loading,
  done,
}
