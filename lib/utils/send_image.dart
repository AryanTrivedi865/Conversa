import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_picker/image_picker.dart' as im_picker;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class SendImageList extends StatefulWidget {
  final List<File> files;
  final ChatUser chatUser;

  const SendImageList({Key? key, required this.files, required this.chatUser})
      : super(key: key);

  @override
  SendImageListState createState() => SendImageListState();
}

class SendImageListState extends State<SendImageList> {
  late List<File> files;
  late ChatUser chatUser;
  late int index;

  @override
  void initState() {
    super.initState();
    files = widget.files;
    chatUser = widget.chatUser;
    index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            "${index + 1}/${files.length}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12),
          ),
        ),
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final List<XFile> images = await ImagePicker().pickMultiImage();
              setState(() {
                files.addAll(images.map((e) => File(e.path)).toList());
              });
            },
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.crop),
            onPressed: () async {
              await ImageCropper().cropImage(
                sourcePath: files[index].path,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                uiSettings: [
                  AndroidUiSettings(
                      toolbarTitle: 'Crop Image',
                      toolbarColor: Colors.black,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                      hideBottomControls: true,
                      activeControlsWidgetColor: Colors.white),
                ],
              ).then((value) {
                if (value != null) {
                  setState(() {
                    files[index] = File(value.path);
                  });
                }
              });
            },
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final XFile? image = await ImagePicker()
                  .pickImage(source: im_picker.ImageSource.gallery);
              if (image != null) {
                setState(() {
                  files[index] = File(image.path);
                });
              }
            },
          ),
          IconButton.filledTonal(
              onPressed: () {
                setState(() {
                  files.removeAt(index);
                  if (index == files.length) {
                    index = 0;
                  }
                });
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            setState(() {
              if (index == 0) {
                index = files.length - 1;
              } else {
                index--;
              }
            });
          } else if (details.primaryVelocity! < 0) {
            setState(() {
              if (index == files.length - 1) {
                index = 0;
              } else {
                index++;
              }
            });
          }
        },
        child: Hero(
          tag: files[index].path,
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: FileImage(files[index]),
          ),
        ),
      ),
      floatingActionButton: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  chatUser.userName.split(" ").first,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                sendChat(files);
              },
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  void sendChat(List<File> files) async {
    final List<String> imageUrls = [];
    int currentIndex = -1; // Change -2 to -1
    int totalIndex = files.length;
    final albumDate = EpochToDate.getVideoDate(
        context, DateTime.now().millisecondsSinceEpoch.toString());
    for (final file in files) {
      currentIndex++;
      final extension = file.path.split(".").last;
      final videoDate = EpochToDate.getVideoDate(
          context, DateTime.now().millisecondsSinceEpoch.toString());
      final storageRef = APIs.storage
          .ref()
          .child("chats/images/albums/$albumDate/IMG-$videoDate.$extension");
      try {
        final uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: "image/$extension"),
        );

        // Show the progress dialog before await uploadTask
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent users from dismissing the dialog
          builder: (context) {
            return AlertDialog(
              title: const Text("Uploading image"),
              content: StreamBuilder<TaskSnapshot>(
                stream: uploadTask.snapshotEvents,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!;
                    final progress = snap.bytesTransferred / snap.totalBytes;
                    final uploadedKB = snap.bytesTransferred;
                    final totalKB = snap.totalBytes;
                    final imagesTransferred = currentIndex + 1;
                    final imagesLeft = totalIndex - imagesTransferred;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Uploaded: ${_formatBytes(uploadedKB)} / ${_formatBytes(totalKB)}"),
                          const SizedBox(height: 8),
                          Text(
                              "Images Transferred: $imagesTransferred / $totalIndex"),
                          const SizedBox(height: 8),
                          Text("Images Left: $imagesLeft"),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(value: progress),
                        ],
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
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } catch (error) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (imageUrls.isNotEmpty) {
      try {
        String combinedUrls = imageUrls.join(';');
        await APIs.sendMessages(widget.chatUser, combinedUrls, "images")
            .then((value) => Navigator.pop(context));
      } catch (error) {
        Fluttertoast.showToast(msg: "Failed to send messages");
      }
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

class ImageSend extends StatefulWidget {
  final File file;
  final String tag;
  final ChatUser chatUser;

  const ImageSend(
      {Key? key, required this.file, required this.tag, required this.chatUser})
      : super(key: key);

  @override
  State<ImageSend> createState() => _ImageSendState();
}

class _ImageSendState extends State<ImageSend> {
  late File file;

  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton.filledTonal(
                onPressed: () async {
                  await ImageCropper().cropImage(
                    sourcePath: file.path,
                    aspectRatioPresets: [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9
                    ],
                    uiSettings: [
                      AndroidUiSettings(
                          toolbarTitle: 'Crop Image',
                          toolbarColor: Colors.black,
                          toolbarWidgetColor: Colors.white,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                          hideBottomControls: true,
                          activeControlsWidgetColor: Colors.white),
                    ],
                  ).then((value) => _updatePhoto(value!.path));
                },
                icon: const Icon(Icons.crop)),
            IconButton.filledTonal(
                onPressed: () {
                  final image = ImageEditorOption();
                  image.addOption(const RotateOption(-90));
                  ImageEditor.editFileImageAndGetFile(
                          file: file, imageEditorOption: image)
                      .then((value) => _updatePhoto(value!.path));
                },
                icon: const Icon(Icons.rotate_left)),
            IconButton.filledTonal(
                onPressed: () {
                  final image = ImageEditorOption();
                  image.addOption(const RotateOption(90));
                  ImageEditor.editFileImageAndGetFile(
                          file: file, imageEditorOption: image)
                      .then((value) => _updatePhoto(value!.path));
                },
                icon: const Icon(Icons.rotate_right)),
            IconButton.filledTonal(
                onPressed: () {
                  final image = ImageEditorOption();
                  image.addOption(const FlipOption(horizontal: true));
                  ImageEditor.editFileImageAndGetFile(
                          file: file, imageEditorOption: image)
                      .then((value) => _updatePhoto(value!.path));
                },
                icon: const Icon(Icons.flip)),
            IconButton.filledTonal(
                onPressed: () {
                  _updatePhoto(widget.file.path);
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Stack(
          children: [
            Hero(
              tag: widget.tag,
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained,
                imageProvider: FileImage(file),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    widget.chatUser.userName.split(" ").first,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  sendChat(file);
                },
                child: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendChat(File file) async {
    final extension = file.path.split(".").last;
    final videoDate = EpochToDate.getVideoDate(
        context, DateTime.now().millisecondsSinceEpoch.toString());
    final storageRef =
        APIs.storage.ref().child("chats/images/IMG-$videoDate.$extension");
    final uploadTask = storageRef.putFile(
        file, SettableMetadata(contentType: "image/$extension"));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uploading image"),
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
        Navigator.of(context, rootNavigator: true).pop();
        final String path = await storageRef.getDownloadURL();
        await APIs.sendMessages(widget.chatUser, path, "image");
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Image upload failed");
    }
  }

  void _updatePhoto(String path) {
    setState(() {
      file = File(path);
    });
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
