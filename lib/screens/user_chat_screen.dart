import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/models/button.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/models/message_model.dart';
import 'package:conversa/utils/audio_utils.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:conversa/utils/gallery_screen.dart';
import 'package:conversa/utils/send_image.dart';
import 'package:conversa/utils/video_preview.dart';
import 'package:conversa/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserChatScreen extends StatefulWidget {
  final ChatUser user;

  const UserChatScreen({super.key, required this.user});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  bool _expand = false;
  bool _emoji = false;
  bool _image = false;
  bool _attachment = false;
  List<MessageModel> _chats = [];
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          _emoji = false;
          _attachment = false;
          _image = false;
        });
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  double _screenWidthRatio(double value) {
    return MediaQuery.of(context).size.width * value;
  }

  double _screenHeightRatio(double value) {
    return MediaQuery.of(context).size.height * value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_emoji || _attachment || _image) {
          setState(() {
            _emoji = false;
            _attachment = false;
            _image = false;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
                padding: const EdgeInsets.only(top: 36.0),
                child: _buildAppBar()),
          ),
          body: GestureDetector(
            onTap: () {
              focusNode.unfocus();
              setState(() {
                _emoji = false;
                _attachment = false;
                _image = false;
              });
            },
            child: Column(
              children: [
                Expanded(child: _chatUI()),
                _chatBar(),
                if (_emoji || _attachment || _image)
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: _bottom(),
                  )
              ],
            ),
          )),
    );
  }

  _chatUI() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder(
          stream: APIs.getAllMessage(widget.user),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data?.docs;
              final temp =
                  data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                      [];
              if (_chats.length < temp.length) {
                _chats = temp;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutSine,
                  );
                });
              }
            }

            if (_chats.isNotEmpty) {
              return Flexible(
                child: ListView.builder(
                  itemCount: _chats.length,
                  controller: _scrollController,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MessageCard(chats: _chats[index]);
                  },
                ),
              );
            } else {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/chat_illustration.png',
                        width: 296,
                        height: 296,
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No Chats Found',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Say hi now and start your new friendship!',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _buildAppBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                if (MediaQuery.of(context).viewInsets.bottom != 0) {
                  focusNode.unfocus();
                } else if (_emoji || _attachment || _image) {
                  setState(() {
                    _emoji = false;
                    _attachment = false;
                    _image = false;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back)),
          Padding(
            padding: EdgeInsets.only(right: _screenWidthRatio(0.02)),
            child: IconButton(
              onPressed: () {},
              icon: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(widget.user.userImageUrl),
                radius: 20,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.userName,
                style: const TextStyle(
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Last active on ${EpochToDate.getFormattedTime(context, widget.user.userLastActive)}",
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          )
        ],
      ),
    );
  }

  _chatBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _screenWidthRatio(0.02)),
      child: Row(
        children: [
          (_expand)
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _expand = false;
                    });
                  },
                )
              : _buttonBar(),
          Expanded(
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_screenHeightRatio(0.04)),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: _screenWidthRatio(0.04)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            hintText: "Message", border: InputBorder.none),
                        textInputAction: TextInputAction.send,
                        maxLines: null,
                        onChanged: (value) {
                          if (value.length > 18) {
                            setState(() {
                              _expand = true;
                            });
                          }
                          if (value.length <= 18) {
                            setState(() {
                              _expand = false;
                            });
                          }
                        },
                        onSubmitted: (message) {
                          _sendChat();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon((_emoji)
                          ? Icons.emoji_emotions
                          : Icons.emoji_emotions_outlined),
                      onPressed: () {
                        focusNode.unfocus();
                        setState(() {
                          _emoji = !_emoji;
                          _image = false;
                          _attachment = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        _sendChat();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buttonBar() {
    return Row(
      children: [
        IconButton(
          icon:
              Icon((_attachment) ? Icons.add_circle : Icons.add_circle_outline),
          onPressed: () {
            focusNode.unfocus();
            setState(() {
              _attachment = !_attachment;
              _image = false;
              _emoji = false;
            });
          },
        ),
        IconButton(
          icon: Icon((_image) ? Icons.photo : Icons.photo_outlined),
          onPressed: () {
            focusNode.unfocus();
            setState(() {
              _image = !_image;
              _emoji = false;
              _attachment = false;
            });
          },
        )
      ],
    );
  }

  void _sendChat() {
    if (textEditingController.text.isNotEmpty) {
      APIs.sendMessages(widget.user, textEditingController.text, "text");
      textEditingController.clear();
      setState(() {
        _expand = false;
      });
    }
  }

  _bottom() {
    if (_emoji) {
      return EmojiPicker(
        textEditingController: textEditingController,
        config: Config(
            columns: 8,
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1),
            buttonMode: ButtonMode.CUPERTINO,
            bgColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.primary,
            enableSkinTones: true,
            initCategory: Category.SMILEYS,
            backspaceColor: Theme.of(context).colorScheme.primary,
            iconColorSelected: Theme.of(context).colorScheme.primary),
      );
    }
    if (_image) {
      return GalleryScreen(chatUser: widget.user);
    }
    if (_attachment) {
      List<ButtonModel> buttonModel = [
        ButtonModel(
            icon: FontAwesomeIcons.camera,
            action: () async {
              ImagePicker imagePicker = ImagePicker();
              XFile? galleryImage =
                  await imagePicker.pickImage(source: ImageSource.camera);
              if (galleryImage != null) {
                if (context.mounted) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageSend(
                              file: File(galleryImage.path),
                              tag: galleryImage.name,
                              chatUser: widget.user)));
                }
              }
            },
            color: Colors.pink,
            text: "Camera"),
        ButtonModel(
            icon: FontAwesomeIcons.image,
            action: () async {
              ImagePicker imagePicker = ImagePicker();
              List<XFile?> galleryImage = await imagePicker.pickMultiImage();
              if (galleryImage.isNotEmpty) {
                if (galleryImage.length == 1) {
                  if (context.mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageSend(
                                file: File(galleryImage[0]!.path),
                                tag: galleryImage[0]!.name,
                                chatUser: widget.user)));
                  }
                } else {
                  final temp = galleryImage.map((e) => File(e!.path)).toList();
                  if (context.mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendImageList(
                                files: temp, chatUser: widget.user)));
                  }
                }
              }
            },
            color: Colors.purple,
            text: "Gallery"),
        ButtonModel(
            icon: FontAwesomeIcons.film,
            action: () async {
              ImagePicker imagePicker = ImagePicker();
              XFile? galleryVideo =
                  await imagePicker.pickVideo(source: ImageSource.gallery);
              if (galleryVideo != null) {
                if (context.mounted) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoPreviewScreen(
                              chatUser: widget.user,
                              videoPath: galleryVideo.path)));
                }
              }
            },
            color: Colors.deepOrange,
            text: "Video"),
        ButtonModel(
            icon: FontAwesomeIcons.file,
            action: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                File file = File(result.files.single.path!);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Send File"),
                      content: Text("Do you want to send this file?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              sendFile(file);
                            },
                            child: Text("Send"))
                      ],
                    );
                  },
                );
              }
            },
            color: Colors.blue,
            text: "Documents"),
        ButtonModel(
            icon: Icons.headphones,
            action: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0))),
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width,
                      child: AudioBottomSheet());
                },
              );
            },
            color: Colors.green,
            text: "Audio")
      ];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              if (index == 5) {}
              final buttonData = buttonModel[index];
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 28,
                            backgroundColor: buttonData.color,
                            child: Center(
                                child: IconButton(
                                    onPressed: buttonData.action,
                                    icon: Icon(buttonData.icon,
                                        color: Colors.white),
                                    iconSize: (buttonData.text == "Audio")
                                        ? 34
                                        : (28)))),
                      ],
                    ),
                  ));
            },
          ),
        ),
      );
    }
  }

  sendFile(File file) async {
    final extension = file.path.split(".").last;
    final videoDate = EpochToDate.getVideoDate(
        context, DateTime.now().millisecondsSinceEpoch.toString());
    final storageRef =
        APIs.storage.ref().child("chats/documents/DOC-$videoDate.$extension");
    final uploadTask = storageRef.putFile(
        file, SettableMetadata(contentType: "application/$extension"));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uploading document"),
          content: StreamBuilder<TaskSnapshot>(
            stream: uploadTask.snapshotEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data!;
                final progress = snap.bytesTransferred / snap.totalBytes;

                final uploadedKB = snap.bytesTransferred;
                final totalKB = snap.totalBytes;

                return SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust the width as needed
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Uploaded: ${_formatBytes(uploadedKB)} / ${_formatBytes(totalKB)}"),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress),
                      ],
                    ),
                  ),
                );
              } else {
                return const LinearProgressIndicator();
              }
            },
          ),
        );
      },
    );

    try {
      await uploadTask;
      if (mounted) {
        final String link = await storageRef.getDownloadURL();
        final String path = extension + ";" + link;
        await APIs.sendMessages(widget.user, path, "document");
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Document upload failed");
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
