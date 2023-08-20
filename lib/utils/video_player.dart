import 'dart:io';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;

  const VideoScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  late FlickManager flickManager;
  late String time;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    time= EpochToDate.getVideoDate(context,DateTime.now().millisecondsSinceEpoch.toString());
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  downloadVideo(widget.videoUrl);
                },
                icon: const Icon(Icons.download_for_offline_rounded))
          ],
        ),
        body: FlickVideoPlayer(flickManager: flickManager));
  }

  Future<void> downloadVideo(String url) async {
    try {
      final dir = Directory('/storage/emulated/0/DCIM/Conversa/Video');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final file =File('${dir.path}/VID-$time.mp4');
      await file.writeAsBytes(response.data);
      Fluttertoast.showToast(msg: 'Video saved to DCIM/Conversa/Video/');

      const MethodChannel platform = MethodChannel('conversa');
      platform.invokeMethod('triggerMediaScan', {'file_path': file.path});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving video');
    }
  }
}
