import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/welcome_screen.dart';
import 'package:conversa/bottom_navigation_screens/ai_screen.dart';
import 'package:conversa/bottom_navigation_screens/call_screen.dart';
import 'package:conversa/bottom_navigation_screens/chat_screen.dart';
import 'package:conversa/bottom_navigation_screens/status_screen.dart';
import 'package:conversa/models/chat_user.dart';
import 'package:conversa/screens/profile_screen.dart';
import 'package:conversa/widgets/user_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  List<ChatUser> searchResults = [];

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
        key: _scaffoldKey,
        appBar: _getAppBar(_showAppBar),
        body: (!_isSearching)
            ? _getSelectedScreen(_selectedIndex)
            : _showSearchScreen(searchResults),
        floatingActionButton: _getFloatingActionButton(_selectedIndex),
        bottomNavigationBar: _getBottomNavigationBar(_showBottomNavigation),
        drawer: Drawer(
          child: IconButton(
              onPressed: () => {FirebaseAuth.instance.signOut(),
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomeScreen(),), (route) => false)},
              icon: Icon(Icons.logout)),
        ),
      ),
    );
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
                    final current =
                        ChatUser.fromJson(snapshot.data!.docs.first.data());
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(current.userImageUrl),
                    );
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
          onPressed: () {},
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
    Brightness currentThemeMode = Theme.of(context).brightness;
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
