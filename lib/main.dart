import 'dart:developer';

import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/welcome_screen.dart';
import 'package:conversa/firebase_options.dart';
import 'package:conversa/screens/home_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const Conversa());
}

class Conversa extends StatefulWidget {
  const Conversa({super.key});

  @override
  State<Conversa> createState() => _ConversaState();

  void toggleThemeMode(ThemeMode themeMode) {
    _conversaState?._toggleTheme(themeMode);
  }
}

_ConversaState? _conversaState;

class _ConversaState extends State<Conversa> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _conversaState = this;
    _loadSavedThemeMode();
  }

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _currentThemeMode = mode;
      _saveThemeMode();
    });
  }

  void _saveThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _currentThemeMode.index);
  }

  void _loadSavedThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeModeIndex = prefs.getInt('themeMode');
    if (themeModeIndex != null) {
      setState(() {
        _currentThemeMode = ThemeMode.values[themeModeIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Conversa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: _currentThemeMode,
        home: const SplashScreen(),
      );
    });
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFirebase().then((value) {
      if(APIs.auth.currentUser!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomeScreen()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const WelcomeScreen()));
      }
    });
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    } catch (e) {
      log('Firebase initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(),
    );
  }
}


/**  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 ***/

