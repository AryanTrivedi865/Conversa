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
        stream: APIs.getAllUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasData) {
                final data = snapshot.data?.docs;
                users = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                APIs.users=users;
              }
              if (users.isNotEmpty) {
                return ListView.builder(
                  itemCount: users.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return UserItem(
                      chatUser: users[index],
                    );
                  },
                );
              } else {
                return Wrap(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/network_connection_error.png',
                            width: ScreenUtils.screenWidthRatio(context,0.8),
                            height: ScreenUtils.screenHeightRatio(context,0.4),
                          ),
                          SizedBox(height: ScreenUtils.screenHeightRatio(context,0.04)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('No Users Found',
                              style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: ScreenUtils.screenHeightRatio(context,0.02)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Please check your internet connection and try again',
                              style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w500
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }
}
