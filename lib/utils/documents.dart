import 'dart:io';

import 'package:dio/dio.dart';
import 'package:document_viewer/document_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Documents extends StatefulWidget {
  final String path;
  final String videoDate;
  final String extension;

  const Documents(
      {super.key,
      required this.path,
      required this.extension,
      required this.videoDate});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('DOC-${widget.videoDate}.${widget.extension}'),
          actions: [
            IconButton(
              onPressed: () {
                _downloadDocument(widget.path);
              },
              icon: Icon(Icons.download),
            )
          ],
        ),
        body: DocumentViewer(
          filePath: widget.path,
        ));
  }

  Future<void> _downloadDocument(String url) async {
    try {
      final dir = Directory('/storage/emulated/0/Documents/Conversa/');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final dio = Dio();
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      final file =
          File("${dir.path}/DOC-${widget.videoDate}.${widget.extension}");
      await file.writeAsBytes(response.data);
      Fluttertoast.showToast(msg: 'Image saved to Documents/Conversa/');
      const MethodChannel platform = MethodChannel('conversa');
      platform.invokeMethod('triggerMediaScan', {'file_path': file.path});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving image');
    }
  }
}
