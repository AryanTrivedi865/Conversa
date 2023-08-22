import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/api/apis.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/screens/profile_screen.dart';
import 'package:conversa/utils/utils.dart';
import 'package:conversa/widgets/user_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  SearchController searchController = SearchController();
  bool _isSearching = false;

  List<ChatUser> searchResults = [];
  List<ChatUser> users = [];
  List<String> blocked = [];
  List<String> blockedBy = [];

  double _screenWidthRatio(double value) {
    return MediaQuery.of(context).size.width * value;
  }

  double _screenHeightRatio(double value) {
    return MediaQuery.of(context).size.height * value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  _getAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(_screenHeightRatio(0.10)),
      // Relative height
      child: Padding(
        padding: EdgeInsets.only(
          left: _screenWidthRatio(0.05),
          right: _screenWidthRatio(0.05),
          top: _screenHeightRatio(0.05),
          bottom: _screenHeightRatio(0.005),
        ),
        child: SearchBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
          controller: searchController,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(
                () {
                  _isSearching = false;
                },
              );
            } else {
              searchResults.clear();
              for (var i in APIs.users) {
                if (i.userName.toLowerCase().contains(value.toLowerCase()) ||
                    i.userAuthenticationCredentials
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                  searchResults.add(i);
                }
              }
              setState(
                () {
                  searchResults;
                  _isSearching = true;
                },
              );
            }
          },
          hintText: "Search",
          trailing: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: APIs.getCurrentUser(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                    );
                  }
                  final current =
                      ChatUser.fromJson(snapshot.data!.docs.first.data());
                  // ignore: unnecessary_null_comparison
                  if (current.userImageUrl != null) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(current.userImageUrl),
                    );
                  } else {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getBody() {
    return Scaffold(
      body: StreamBuilder(
        stream: APIs.getBlocked(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            blocked = data?.map((e) => e.id).toList() ?? [];
          }
          return StreamBuilder(
            stream: APIs.getBlockedBy(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data?.docs;
                blockedBy = data?.map((e) => e.id).toList() ?? [];
              }
              List<String> notDisplay = blocked + blockedBy;
              notDisplay.add(APIs.firebaseUser.uid);
              return StreamBuilder(
                stream: APIs.getBlockedUsers(notDisplay),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data?.docs;
                    users = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                    APIs.users = users;
                  }
                  if (!_isSearching) {
                    if (users.isNotEmpty) {
                      return ListView.builder(
                        itemCount: users.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return UserItem(
                            chatUser: users[index],
                            chatBoolean: false,
                            blocked: false,
                            archived: false,
                          );
                        },
                      );
                    } else {
                      return ListView.builder(
                        itemCount: APIs.users.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return UserItem(
                            chatUser: APIs.users[index],
                            chatBoolean: false,
                            blocked: false,
                            archived: false,
                          );
                        },
                      );
                    }
                  } else {
                    if (searchResults.isNotEmpty) {
                      return ListView.builder(
                        itemCount: searchResults.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return UserItem(
                            chatUser: searchResults[index],
                            chatBoolean: false,
                            blocked: false,
                            archived: false,
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
                                Lottie.asset(
                                  'assets/lottie_animation/search_empty.json',
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
                                    'No Such Users Found',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                    height: ScreenUtils.screenHeightRatio(
                                        context, 0.02)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Try searching for another user.',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
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
              );
            },
          );
        },
      ),
    );
  }
}
