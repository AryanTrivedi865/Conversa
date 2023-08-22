import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImage extends StatefulWidget {
  final String photoUrl;
  final String tag;

  const ZoomImage({super.key, required this.photoUrl, required this.tag});

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  late String time;
  @override
  Widget build(BuildContext context) {
    time= EpochToDate.getVideoDate(context,DateTime.now().millisecondsSinceEpoch.toString());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Hero(
        tag: widget.tag,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: CachedNetworkImageProvider(widget.photoUrl),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () => downloadImage(widget.photoUrl),
          child: const Icon(Icons.download),
        ),
      ),
    );
  }
  Future<void> downloadImage(String url) async {
    try {
      final dir = Directory('/storage/emulated/0/DCIM/Conversa/Images');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final file =File('${dir.path}/IMG-$time}.jpg');
      await file.writeAsBytes(response.data);
      Fluttertoast.showToast(msg: 'Image saved to DCIM/Conversa/Images/');

      const MethodChannel platform = MethodChannel('conversa');
      platform.invokeMethod('triggerMediaScan', {'file_path': file.path});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving image');
    }
  }
}
class ZoomImageList extends StatefulWidget {
  final List<String> files;
  final int index;

  const ZoomImageList({Key? key, required this.files, required this.index})
      : super(key: key);

  @override
  ZoomImageListState createState() => ZoomImageListState();
}

class ZoomImageListState extends State<ZoomImageList> {
  late List<String> files;
  late int index;
  late String time;

  @override
  void initState() {
    super.initState();
    files = widget.files;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    time= EpochToDate.getVideoDate(context,DateTime.now().millisecondsSinceEpoch.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .secondaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            "${index + 1}/${files.length}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSecondaryContainer,
                fontSize: 12),
          ),
        ),
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
          tag: files[index],
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: CachedNetworkImageProvider(files[index]),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () => downloadImage(files[index]),
          child: const Icon(Icons.download),
        ),
      ),
    );
  }
  Future<void> downloadImage(String url) async {
    try {
      final dir = Directory('/storage/emulated/0/DCIM/Conversa/Images');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final file =File('${dir.path}/IMG-$time}"$index".jpg');
      await file.writeAsBytes(response.data);
      Fluttertoast.showToast(msg: 'Image saved to DCIM/Conversa/Images/');

      const MethodChannel platform = MethodChannel('conversa');
      platform.invokeMethod('triggerMediaScan', {'file_path': file.path});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving image');
    }
  }
}