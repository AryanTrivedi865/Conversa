import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;
  final ChatUser chatUser;

  const VideoPreviewScreen(
      {super.key, required this.videoPath, required this.chatUser});

  @override
  VideoPreviewScreenState createState() => VideoPreviewScreenState();
}

class VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  late File _videoThumbnail;
  late String path;

  Future<void> getPath() async {
    path=await VideoThumbnail.thumbnailFile(video: widget.videoPath,maxHeight: 250)??"";
    _videoThumbnail= File(path);
  }
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: File(widget.videoPath).existsSync()
            ? Text(File(widget.videoPath).path.split("/").last,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18))
            : const Text("Video Preview"),
        actions: [
          IconButton(
            icon: Icon(
              _controller.value.volume == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
            ),
            onPressed: () {
              setState(() {
                _controller.value.volume == 0
                    ? _controller.setVolume(1)
                    : _controller.setVolume(0);
              });
            },
          ),
        ],
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 86.0),
          child: Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(), // Show loading indicator until video is initialized
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 86),
          child: Center(
            child: IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48, color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
          ),
        ),
      ]),
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              _formatBytes(File(widget.videoPath).lengthSync()),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 12),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                sendChat(File(widget.videoPath));
              },
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  sendChat(File file) async {
    final extension = file.path.split(".").last;
    final videoDate = EpochToDate.getVideoDate(
        context, DateTime.now().millisecondsSinceEpoch.toString());
    final storageRef =
    APIs.storage.ref().child("chats/video/VID-$videoDate.$extension");
    final uploadTask = storageRef.putFile(
        file, SettableMetadata(contentType: "video/$extension"));

    final thumbRef = APIs.storage.ref().child("chats/video/thumbnail/THUMB-$videoDate.jpg");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uploading Video"),
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
      String thumbPath="";
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        final String path = await storageRef.getDownloadURL().then((value) async {
          await thumbRef.putFile(_videoThumbnail);
          thumbPath = await thumbRef.getDownloadURL();
          return value;
        });
        await APIs.sendMessages(widget.chatUser, thumbPath+";"+path, "video");
        if(mounted){
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Video upload failed");
    }
  }
}
