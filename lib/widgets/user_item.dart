
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conversa/api/apis.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/models/message_model.dart';
import 'package:conversa/screens/user_chat_screen.dart';
import 'package:conversa/utils/epoch_to_date.dart';
import 'package:conversa/utils/photo_zoom.dart';
import 'package:conversa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class UserItem extends StatefulWidget {
  final ChatUser chatUser;
  final bool chatBoolean;
  final bool blocked;
  final bool archived;

  const UserItem(
      {super.key,
      required this.chatUser,
      required this.chatBoolean,
      required this.blocked, required this.archived});

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
            if (widget.blocked) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Blocked"),
                    content: const Text(
                        "You have blocked this user. Unblock to chat. \n\n Do you want to unblock?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("No")),
                      TextButton(
                          onPressed: () {
                            APIs.unblockUser(widget.chatUser);
                            Navigator.pop(context);
                          },
                          child: const Text("Yes")),
                    ],
                  );
                },
              );
            } else if (!widget.chatBoolean) {
              FocusScope.of(context).unfocus();
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Add to contacts?"),
                      content: Text(
                          "Do you want to add ${widget.chatUser.userName.trim()} to your contacts?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () {
                              APIs.addUser(widget.chatUser);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("Add")),
                      ],
                    );
                  });
            } else {
              FocusScope.of(context).unfocus();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UserChatScreen(user: user)));
            }
          },
          onLongPress: () {
            if (!widget.blocked) {
              showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  showDragHandle: true,
                  builder: (context) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: CachedNetworkImageProvider(
                                      widget.chatUser.userImageUrl),
                                  radius: 32,
                                ),
                                SizedBox(
                                    width: ScreenUtils.screenWidthRatio(
                                        context, 0.025)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        widget.chatUser.userName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: ScreenUtils.screenHeightRatio(context,0.01)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        widget.chatUser.userAbout,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text("Delete All Chats"),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Delete All Chats"),
                                      content: Text(
                                          "Do you want to delete all chats?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              APIs.deleteAllChat(widget.chatUser);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text("Delete"))
                                      ],
                                    );
                                  });
                            },
                          ),
                          (!widget.archived)?
                           ListTile(
                             leading: Icon(Icons.archive),
                             title: Text("Archive ${widget.chatUser.userName}"),
                             onTap: () {
                               showDialog(
                                   context: context,
                                   builder: (context) {
                                     return AlertDialog(
                                       title: Text("Archive User"),
                                       content: Text(
                                           "Do you want to archive this user?"),
                                       actions: [
                                         TextButton(
                                             onPressed: () {
                                               Navigator.pop(context);
                                             },
                                             child: Text("Cancel")),
                                         TextButton(
                                             onPressed: () {
                                               APIs.archiveUser(widget.chatUser);
                                               Navigator.pop(context);
                                               Navigator.pop(context);
                                             },
                                             child: Text("Archive"))
                                       ],
                                     );
                                   });
                             },
                           ):
                           ListTile(
                             leading: Icon(Icons.unarchive),
                             title: Text("Unarchive ${widget.chatUser.userName}"),
                             onTap: () {
                               showDialog(
                                   context: context,
                                   builder: (context) {
                                     return AlertDialog(
                                       title: Text("Unarchive User"),
                                       content: Text(
                                           "Do you want to unarchive this user?"),
                                       actions: [
                                         TextButton(
                                             onPressed: () {
                                               Navigator.pop(context);
                                             },
                                             child: Text("Cancel")),
                                         TextButton(
                                             onPressed: () {
                                               APIs.unarchiveUser(widget.chatUser);
                                               Navigator.pop(context);
                                               Navigator.pop(context);
                                             },
                                             child: Text("Unarchive"))
                                       ],
                                     );
                                   });
                             },
                           ),
                          ListTile(
                            leading: Icon(Icons.block),
                            title: Text("Block ${widget.chatUser.userName}"),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Block User"),
                                      content: Text(
                                          "Do you want to block this user?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              APIs.blockUser(widget.chatUser);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text("Block"))
                                      ],
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                    );
                  });;
            }
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
                      EpochToDate.getLastTime(
                          context,
                          widget.chatBoolean
                              ? (_messageModel?.sendTime ?? user.userLastActive)
                              : user.userLastActive),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: widget.chatBoolean
                          ? (_messageModel?.messageType == "text")
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
                                )
                          : Text(
                              capitalizeFirstLetter(user.userAbout),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                    ),
                    (widget.chatBoolean)
                        ? CircleAvatar(
                            radius: 5,
                            backgroundColor: (_messageModel == null)
                                ? Colors.transparent
                                : ((_messageModel!.readTime.isEmpty &&
                                        _messageModel!.senderID !=
                                            APIs.firebaseUser.uid)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent),
                          )
                        : const SizedBox(width: 0),
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
