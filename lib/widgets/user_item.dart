import 'package:conversa/api/apis.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/models/message_model.dart';
import 'package:conversa/screens/user_chat_screen.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:conversa/utils/photo_zoom.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserItem extends StatefulWidget {
  final ChatUser chatUser;

  const UserItem({super.key, required this.chatUser});

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  MessageModel? _messageModel;
  Icon icon = const Icon(Icons.image, size: 18);

  @override
  Widget build(BuildContext context) {
    ChatUser user = widget.chatUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => UserChatScreen(user: user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              if (data != null && data.isNotEmpty) {
                _messageModel = MessageModel.fromJson(data.first.data());
              }
              switch (_messageModel?.messageType) {
                case "image":
                  icon = const Icon(FontAwesomeIcons.image, size: 14);
                  break;
                case "video":
                  icon = const Icon(FontAwesomeIcons.film, size: 14);
                  break;
                case "document":
                  icon = const Icon(FontAwesomeIcons.file, size: 13);
                  break;
                case "images":
                  icon = const Icon(FontAwesomeIcons.images, size: 14);
                  break;
                case "audio":
                  icon = const Icon(FontAwesomeIcons.music, size: 14);
                  break;
                default:
                  icon = const Icon(Icons.text_fields_rounded,
                      color: Colors.transparent, size: 0);
                  break;
              }
              return ListTile(
                leading: Stack(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ZoomImage(
                                      photoUrl: user.userImageUrl,
                                      tag: user.userID,
                                    )));
                      },
                      child: Hero(
                        tag: user.userID,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(user.userImageUrl),
                          radius: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor:
                            user.userOnlineStatus ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.userName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      EpochToDate.getLastMessageTime(context,
                          _messageModel?.sendTime ?? user.userLastActive),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: (_messageModel?.messageType == "text")
                          ? Text(
                              _messageModel?.messageContent ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : Row(
                              children: [
                                icon,
                                const SizedBox(width: 4),
                                Text(capitalizeFirstLetter(
                                    _messageModel?.messageType ?? ""))
                              ],
                            ),
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: (_messageModel == null)
                          ? Colors.transparent
                          : ((_messageModel!.readTime.isEmpty &&
                                  _messageModel!.senderID !=
                                      APIs.firebaseUser.uid)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input.substring(0, 1).toUpperCase() +
        input.substring(1).toLowerCase();
  }
}
