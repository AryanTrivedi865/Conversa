import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:conversa/api/apis.dart';
import 'package:conversa/models/message_model.dart';
import 'package:conversa/utils/documents.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:conversa/utils/photo_zoom.dart';
import 'package:conversa/utils/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:internet_file/internet_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageCard extends StatefulWidget {
  final MessageModel chats;

  const MessageCard({super.key, required this.chats});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  String messageType = "";
  bool isSender = false;
  Color background = Colors.pink, text = Colors.blue;

  @override
  Widget build(BuildContext context) {
    messageType = widget.chats.messageType;
    isSender = (APIs.firebaseUser.uid == widget.chats.senderID) ? true : false;
    background = (isSender)
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.secondary;
    text = (isSender)
        ? Theme.of(context).colorScheme.onTertiary
        : Theme.of(context).colorScheme.onSecondary;
    double width = MediaQuery.of(context).size.width;
    if (!isSender) {
      APIs.updateMessageReadStatus(widget.chats);
    }
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChatBubble(
            clipper: ChatBubbleClipper5(
                type: (isSender)
                    ? BubbleType.sendBubble
                    : BubbleType.receiverBubble),
            alignment:
                (isSender) ? Alignment.centerRight : Alignment.centerLeft,
            margin: EdgeInsets.only(
                top: 8, left: (isSender) ? 0 : 4, right: (isSender) ? 4 : 0),
            padding: (messageType == "image")
                ? EdgeInsets.zero
                : (messageType == "images")
                    ? const EdgeInsets.all(4)
                    : (messageType == "video")
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.all(8),
            backGroundColor: background,
            elevation: 0,
            child: Container(
                constraints: BoxConstraints(
                  minWidth: width * 0.05,
                  maxWidth:
                      (messageType == "image") ? width * 0.4 : width * 0.6,
                ),
                child: _messageChild())),
        Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4, top: 6),
            child: Wrap(
              children: [
                Text(
                    EpochToDate.getFormattedTime(
                        context, widget.chats.sendTime),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 4),
                isSender
                    ? ((widget.chats.readTime.isNotEmpty)
                        ? const Icon(Icons.done_all,
                            color: Colors.blue, size: 16)
                        : const Icon(Icons.done_all, size: 16))
                    : const Icon(null)
              ],
            ))
      ],
    );
  }

  _messageChild() {
    String message = widget.chats.messageContent;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color link = isDark ? Colors.blue : Colors.green;
    switch (messageType) {
      case "image":
        return Hero(
          tag: widget.chats.messageType + widget.chats.sendTime,
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ZoomImage(
                        photoUrl: message,
                        tag:
                            widget.chats.messageType + widget.chats.sendTime))),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage(
                    image: NetworkImage(message),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/placeholder.jpg');
                    },
                    placeholder:
                        const AssetImage('assets/images/placeholder.jpg'))),
          ),
        );
      case "text":
        if (_isLink(message)) {
          return InkWell(
            onTap: () async {
              if (!await launchUrl(
                Uri.parse(
                    (message.startsWith("https")) || message.startsWith("http")
                        ? message
                        : "https://$message"),
                mode: LaunchMode.externalApplication,
              )) {
                throw Exception('Could not launch $message');
              }
            },
            child: Text.rich(
              TextSpan(
                text: message,
                style: TextStyle(fontSize: 14, color: link),
              ),
            ),
          );
        } else {
          return Text(message,
              style: TextStyle(
                  fontSize: _isOnlyEmoji(message) ? 24 : 14, color: text));
        }
      case "images":
        List<String> images = message.split(";");
        int imageCount = images.length;
        if (imageCount >= 2 && imageCount <= 4) {
          return SizedBox(
            height: images.length == 2 ? 98 : 196,
            width: 196,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: imageCount,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ZoomImageList(files: images, index: index);
                    }));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FadeInImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(images[index]),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/placeholder.jpg');
                        },
                        placeholder:
                            const AssetImage('assets/images/placeholder.jpg')),
                  ),
                );
              },
            ),
          );
        } else {
          return Column(
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final isFourthImage = index == 3;

                  return GestureDetector(
                    onTap: () {
                      if (isFourthImage) {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                backgroundColor: Colors.transparent,
                                appBar: AppBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  elevation: 0,
                                  title: Text("Album ($imageCount)"),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  centerTitle: true,
                                  leading: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                body: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                      ),
                                      itemCount: imageCount,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ZoomImage(
                                                  photoUrl: images[index],
                                                  tag: widget
                                                          .chats.messageType +
                                                      widget.chats.sendTime +
                                                      index.toString());
                                            }));
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: FadeInImage(
                                                fit: BoxFit.cover,
                                                image:
                                                    NetworkImage(images[index]),
                                                placeholder: const AssetImage(
                                                    'assets/images/placeholder.jpg')),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ZoomImageList(files: images, index: index);
                        }));
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isFourthImage
                          ? Stack(fit: StackFit.expand, children: [
                              ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                                child: FadeInImage(
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/images/placeholder.jpg'),
                                  image: NetworkImage(images[3]),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "+${imageCount - 3}",
                                  style: const TextStyle(
                                      fontSize: 32, color: Colors.white),
                                ),
                              ),
                            ])
                          : FadeInImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(images[index]),
                              placeholder: const AssetImage(
                                  'assets/images/placeholder.jpg'),
                            ),
                    ),
                  );
                },
              ),
            ],
          );
        }
      case "video":
        String link = widget.chats.messageContent.split(';').last;
        String thumbnail = widget.chats.messageContent.split(';').first;
        return InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoScreen(videoUrl: link))),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(thumbnail),
                    placeholder:
                        const AssetImage('assets/images/placeholder.jpg'),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40, // Specify the desired icon size
                    ),
                  ),
                ),
                Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer
                            .withOpacity(0.667),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: StreamBuilder<String>(
                        stream: getFileSize(link).asStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center();
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error'));
                          } else {
                            final String fileSize = snapshot.data ?? '';
                            return Text(
                              fileSize,
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            );
                          }
                        },
                      ),
                    ))
              ],
            ));
      case "document":
        String extension = widget.chats.messageContent.split(';').first;
        String link = widget.chats.messageContent.split(';').last;
        String prefix = _getPrefix(extension);
        return InkWell(
          onTap: () async {
            switch (extension) {
              case 'jpg':
              case 'jpeg':
              case 'png':
              case 'gif':
              case 'webp':
              case 'bmp':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ZoomImage(
                            photoUrl: link,
                            tag: widget.chats.messageType +
                                widget.chats.sendTime)));
                break;
              case 'mp4':
              case 'mkv':
              case 'webm':
              case 'avi':
              case 'mov':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoScreen(videoUrl: link)));
                break;
              case 'pdf':
              case 'doc':
              case 'docx':
              case 'txt':
                _openFile(link, extension,
                    EpochToDate.getVideoDate(context, widget.chats.sendTime));
                break;
              default:
                if (!await launchUrl(
                  Uri.parse(
                      (link.startsWith("https")) || link.startsWith("http")
                          ? link
                          : "https://$link"),
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $message');
                }
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.file, color: text, size: 32),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$prefix-${EpochToDate.getVideoDate(context, widget.chats.sendTime)}.$extension",
                      style: TextStyle(
                          color: text,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis),
                      softWrap: false,
                    ),
                    Row(
                      children: [
                        StreamBuilder<String>(
                          stream: getFileSize(link).asStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center();
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else {
                              final String fileSize = snapshot.data ?? '';
                              return Text(
                                fileSize,
                                style: TextStyle(fontSize: 12, color: text),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.circle_rounded, size: 4, color: text),
                        const SizedBox(width: 4),
                        Text(extension.toUpperCase(),
                            style: TextStyle(color: text, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
    }
  }

  Future<String> getFileSize(String fileUrl) async {
    try {
      final response = await http.head(Uri.parse(fileUrl));
      return _formatBytes(int.parse(response.headers["content-length"]!));
    } catch (e) {
      return 'Error';
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

  bool _isLink(String content) {
    RegExp urlPattern = RegExp(
      r'^(http://www\.|https://www\.|http://|https://)?[a-z0-9]+([-.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(/.*)?$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlPattern.hasMatch(content);
  }

  bool _isOnlyEmoji(String text) {
    RegExp emojiRegExp = RegExp(r'[^\x00-\x7F]');
    String textWithoutEmojis = text.replaceAll(emojiRegExp, '');
    return textWithoutEmojis.isEmpty;
  }

  String _getPrefix(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return 'IMG';
      case 'mp4':
      case 'mkv':
      case 'webm':
      case 'avi':
      case 'mov':
        return 'VID';
      default:
        return 'DOC';
    }
  }

  _openFile(String url, String extension, String videoDate) async {
    Uint8List bytes = await InternetFile.get(url);
    File file =
        await File('${(await getTemporaryDirectory()).path}/temp.$extension')
            .writeAsBytes(bytes);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Documents(
                  path: file.path,
                  extension: extension,
                  videoDate: videoDate,
                )));
  }
}
