
import 'dart:io';

import 'package:conversa/models/chat_user.dart';
import 'package:conversa/utils/send_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';

class AlbumPage extends StatefulWidget {
  final Album album;
  final ChatUser chatUser;

  const AlbumPage(this.album, {super.key, required this.chatUser});

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    var imagesOnly = mediaPage.items.where((medium) => medium.mediumType == MediumType.image).toList();
    setState(() {
      _media = imagesOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Scaffold(
          body: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 6.0,
            crossAxisSpacing: 6.0,
            children: <Widget>[
              ...?_media?.map(
                    (medium) => InkWell(
                  onTap: () async {
                    File file = await medium.getFile();
                    if(mounted){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageSend(
                            file: file,
                            chatUser: widget.chatUser,
                            tag: medium.filename ?? "",
                          ),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                    child: Container(
                      color: Colors.grey[300],
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: const AssetImage('assets/images/placeholder.jpg'),
                        image: ThumbnailProvider(
                          mediumId: medium.id,
                          mediumType: medium.mediumType,
                          highQuality: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
