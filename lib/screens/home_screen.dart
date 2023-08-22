import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/api/apis.dart';
import 'package:conversa/bottom_navigation_screens/ai_screen.dart';
import 'package:conversa/bottom_navigation_screens/call_screen.dart';
import 'package:conversa/bottom_navigation_screens/chat_screen.dart';
import 'package:conversa/bottom_navigation_screens/status_screen.dart';
import 'package:conversa/main.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/screens/contacts_screen.dart';
import 'package:conversa/screens/profile_screen.dart';
import 'package:conversa/utils/utils.dart';
import 'package:conversa/widgets/user_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  final bool _showBottomNavigation = true;
  final bool _showAppBar = true;
  SearchController searchController = SearchController();
  bool _isSearching = false;
  int _indexForDrawer = 0;

  List<ChatUser> searchResults = [];
  List<ChatUser> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message == AppLifecycleState.resumed.toString()) {
        APIs.updateActiveStatus(true);
      } else if (message == AppLifecycleState.paused.toString() ||
          message == AppLifecycleState.detached.toString()) {
        APIs.updateActiveStatus(false);
      }
      return Future.value('');
    });
  }

  double _screenWidthRatio(double value) {
    return MediaQuery
        .of(context)
        .size
        .width * value;
  }

  double _screenHeightRatio(double value) {
    return MediaQuery
        .of(context)
        .size
        .height * value;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        APIs.updateActiveStatus(false);
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _getAppBar(_showAppBar),
          body: (!_isSearching)
              ? (_indexForDrawer == 0)
              ? _getSelectedScreen(_selectedIndex)
              : _getOtherScreens(_indexForDrawer)
              : _showSearchScreen(searchResults),
          floatingActionButton: _getFloatingActionButton(_selectedIndex),
          bottomNavigationBar: _getBottomNavigationBar(_showBottomNavigation),
          drawer: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _screenHeightRatio(0.05),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    'Conversa',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'BackToBlack',
                    ),
                  ),
                ),
                SizedBox(
                  height: _screenHeightRatio(0.01),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.inbox),
                    title: const Text('Primary'),
                    selected: _indexForDrawer == 0,
                    selectedTileColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .tertiaryContainer,
                    shape: _indexForDrawer == 0
                        ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    )
                        : null,
                    selectedColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .onTertiaryContainer,
                    onTap: () {
                      setState(() {
                        _indexForDrawer = 0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.archive),
                    title: const Text('Archived Chats'),
                    selected: _indexForDrawer == 1,
                    selectedTileColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .tertiaryContainer,
                    shape: _indexForDrawer == 1
                        ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    )
                        : null,
                    selectedColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .onTertiaryContainer,
                    onTap: () {
                      setState(() {
                        _indexForDrawer = 1;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.person_off),
                    title: const Text('Blocked Users'),
                    selected: _indexForDrawer == 2,
                    selectedTileColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .tertiaryContainer,
                    shape: _indexForDrawer == 2
                        ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    )
                        : null,
                    selectedColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .onTertiaryContainer,
                    onTap: () {
                      setState(() {
                        _indexForDrawer = 2;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Spacer(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                  child: ListTile(
                    //theme change slider button
                    leading: Icon(Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    title: Text(
                        Theme
                            .of(context)
                            .brightness ==
                            Brightness.dark
                            ? 'Dark Mode'
                            : 'Light Mode'
                    ),
                    trailing: Switch(
                      value: Theme
                          .of(context)
                          .brightness ==
                          Brightness.dark, //check if dark mode is on
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            Conversa().toggleThemeMode(ThemeMode.dark);
                          } else {
                            Conversa().toggleThemeMode(ThemeMode.light);
                          }
                        },);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help and Feedback'),
                    onTap: () {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text('Help and Feedback'),
                        content: const Text('Contact us at: \n\nInstagram: aryan_.___ \n\nEmail: conversa1805@gmail.com\n\nGithub: AryanTrivedi865\n\n'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getOtherScreens(int index) {
    List<ChatUser> users = [];
    if (index == 1) {
      return StreamBuilder(
        stream: APIs.getArchived(),
        builder: (context, snapshot) {
          List<String> blocked = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            blocked = data?.map((e) => e.id).toList() ?? [];
            if (blocked.isNotEmpty) {
              return StreamBuilder(
                builder: (context, snapshot) =>
                    StreamBuilder(
                      stream: APIs.getUsers(blocked),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data?.docs;
                          users = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];
                        }
                        if (users.isNotEmpty) {
                          return ListView.builder(
                            itemCount: users.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserItem(
                                chatUser: users[index],
                                chatBoolean: true,
                                blocked: false,
                                archived: true,
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
                                      width: ScreenUtils.screenWidthRatio(
                                          context, 0.8),
                                      height: ScreenUtils.screenHeightRatio(
                                          context, 0.4),
                                    ),
                                    SizedBox(
                                        height: ScreenUtils.screenHeightRatio(
                                            context, 0.04)),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'No Starred Users Found',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
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
                          width: ScreenUtils.screenWidthRatio(context, 0.8),
                          height: ScreenUtils.screenHeightRatio(context, 0.4),
                        ),
                        SizedBox(
                            height:
                            ScreenUtils.screenHeightRatio(context, 0.04)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No Starred Users Found',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    } else {
      return StreamBuilder(
        stream: APIs.getBlocked(),
        builder: (context, snapshot) {
          List<String> blocked = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            blocked = data?.map((e) => e.id).toList() ?? [];
            if (blocked.isNotEmpty) {
              return StreamBuilder(
                builder: (context, snapshot) =>
                    StreamBuilder(
                      stream: APIs.getUsers(blocked),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data?.docs;
                          users = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];
                        }
                        if (users.isNotEmpty) {
                          return ListView.builder(
                            itemCount: users.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserItem(
                                chatUser: users[index],
                                chatBoolean: false,
                                blocked: true,
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'No Blocked Users Found',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
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
                          width: ScreenUtils.screenWidthRatio(context, 0.8),
                          height: ScreenUtils.screenHeightRatio(context, 0.4),
                        ),
                        SizedBox(
                            height:
                            ScreenUtils.screenHeightRatio(context, 0.04)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No Blocked Users Found',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }
  }

  _getAppBar(showAppBar) {
    if (_showAppBar) {
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
            controller: searchController,
            leading: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              icon: const Icon(Icons.menu),
            ),
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
                onTap: () =>
                {
                  showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .surface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: const ProfileScreen(),
                        );
                      })
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
    } else {
      return null;
    }
  }

  _showSearchScreen(List<ChatUser> searchResults) {
    if (searchResults.isNotEmpty) {
      return ListView.builder(
        itemCount: searchResults.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return UserItem(
            chatUser: searchResults[index],
            chatBoolean: true,
            blocked: false,
            archived: false,
          );
        },
      );
    } else {
      return Scaffold(
        body: OverflowBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_animation/search_empty.json',
                  width: 296,
                  height: 296,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Oops! No results found',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    ' It looks like there are no users matching your search criteria. Please try again with different search parameters.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _getSelectedScreen(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const AIScreen();
      case 1:
        return const ChatScreen();
      case 2:
        return const StatusScreen();
      case 3:
        return const CallScreen();
      default:
        return const ChatScreen();
    }
  }

  _getFloatingActionButton(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return null;
      case 1:
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => const ContactsScreen(),
              ),
            );
          },
          label: const Text("Start Chat"),
          icon: const Icon(Icons.message),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add_photo_alternate),
        );
      case 3:
        return FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.call),
        );
      default:
        return const ChatScreen();
    }
  }

  _getBottomNavigationBar(bool showBottomNavigation) {
    Brightness currentThemeMode = Theme
        .of(context)
        .brightness;
    Color itemColor =
    currentThemeMode == Brightness.dark ? Colors.white : Colors.black;
    if (showBottomNavigation) {
      return SizedBox(
        height: _screenHeightRatio(0.098), // Relative height
        child: BottomNavigationBar(
          currentIndex: (_selectedIndex > 3 ? 1 : _selectedIndex),
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 12,
          // Relative elevation
          selectedItemColor: itemColor,
          unselectedItemColor: itemColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart_outlined),
              activeIcon: Icon(Icons.bubble_chart),
              label: 'Luna AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.motion_photos_on_outlined),
              activeIcon: Icon(Icons.motion_photos_on),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined),
              activeIcon: Icon(Icons.call),
              label: 'Call',
            ),
          ],
        ),
      );
    } else {
      return null;
    }
  }
}
