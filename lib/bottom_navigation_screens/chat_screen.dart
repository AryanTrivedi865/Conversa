import 'package:conversa/models/chat_user.dart';
import 'package:conversa/utils/utils.dart';
import 'package:conversa/widgets/user_item.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatUser> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: APIs.getChatContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chatContacts = snapshot.data?.docs ?? [];
            final contactIds = chatContacts.map((e) => e.id).toList();
            return contactIds.isNotEmpty
                ? StreamBuilder(
                    stream: APIs.getUsers(contactIds),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('An error occurred.'),
                        );
                      } else if (snapshot.hasData) {
                        final userData = snapshot.data?.docs;
                        users = userData
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (users.isNotEmpty) {
                          return ListView.builder(
                            itemCount: users.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserItem(
                                chatUser: users[index],
                                chatBoolean: true,
                                blocked: false,
                                archived: false,
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/network_connection_error.png',
                                  width: ScreenUtils.screenWidthRatio(
                                      context, 0.8),
                                  height: ScreenUtils.screenHeightRatio(
                                      context, 0.4),
                                ),
                                SizedBox(
                                    height: ScreenUtils.screenHeightRatio(
                                        context, 0.04)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'No Users Found',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtils.screenHeightRatio(
                                        context, 0.02)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Press "Start Chat" to start a conversation with your friends.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      // Handle other ConnectionState cases if needed.
                      return const Center(
                        child: Text('No data available.'),
                      );
                    },
                  )
                : SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height:
                                ScreenUtils.screenHeightRatio(context, 0.1)),
                        Image.asset(
                          'assets/images/network_connection_error.png',
                          width: ScreenUtils.screenWidthRatio(context, 0.8),
                          height: ScreenUtils.screenHeightRatio(context, 0.4),
                        ),
                        SizedBox(
                            height:
                                ScreenUtils.screenHeightRatio(context, 0.04)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No Users Found',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            height:
                                ScreenUtils.screenHeightRatio(context, 0.02)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Press "Start Chat" to start a conversation with your friends.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
