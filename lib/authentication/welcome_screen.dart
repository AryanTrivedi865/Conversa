import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/login_screen.dart';
import 'package:conversa/authentication/phone_sing_in.dart';
import 'package:conversa/screens/home_screen.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoading = false;
  bool isDone = false;

  late Color bottomSheet;
  late Color buttonColor;
  late Color textColor;

  @override
  Widget build(BuildContext context) {
    bottomSheet = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.primaryContainer;
    buttonColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Colors.black;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie_animation/hello.json'),
          Text(
            'Welcome to',
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
          ),
          Text(
            'Conversa',
            style: TextStyle(
              fontSize: ScreenUtils.screenWidthRatio(context, 0.15),
              fontFamily: "BackToBlack",
            ),
          ),
          SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.1)),
        ],
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        backgroundColor: bottomSheet,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: ScreenUtils.screenHeightRatio(context, 0.03),
                    right: ScreenUtils.screenWidthRatio(context, 0.03),
                    left: ScreenUtils.screenWidthRatio(context, 0.03),
                    bottom: ScreenUtils.screenHeightRatio(context, 0.01)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(buttonColor),
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          _googleButtonHandle();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(
                              ScreenUtils.screenWidthRatio(context, 0.03)),
                          child: Row(
                            children: [
                              const Spacer(),
                              SizedBox(
                                width: ScreenUtils.screenWidthRatio(
                                    context, (isLoading || isDone) ? 0.07 : 0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 11),
                                  Icon(FontAwesomeIcons.google,
                                      color: textColor),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: ScreenUtils.screenWidthRatio(
                                          context, 0.05),
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              isLoading
                                  ? isDone
                                      ? Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green),
                                          width: ScreenUtils.screenWidthRatio(
                                              context, 0.07),
                                          height: ScreenUtils.screenWidthRatio(
                                              context, 0.07),
                                          child: const Icon(
                                            FontAwesomeIcons.check,
                                            color: Colors.white,
                                          ),
                                        )
                                      : SizedBox(
                                          width: ScreenUtils.screenWidthRatio(
                                              context, 0.07),
                                          height: ScreenUtils.screenWidthRatio(
                                              context, 0.07),
                                          child: CircularProgressIndicator(
                                              color: textColor, strokeWidth: 1),
                                        )
                                  : const SizedBox(width: 0)
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => const LoginScreen()))
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            ScreenUtils.screenWidthRatio(context, 0.03)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline, color: textColor),
                            const SizedBox(width: 10),
                            Text(
                              'Sign in with Email',
                              style: TextStyle(
                                fontSize:
                                    ScreenUtils.screenWidthRatio(context, 0.05),
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: ScreenUtils.screenWidthRatio(context, 0.02)),
                    ElevatedButton(
                      onPressed: () => {
                        showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            builder: (_) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: const PhoneSIScreen(),
                              );
                            })
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            ScreenUtils.screenWidthRatio(context, 0.03)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 6),
                            Icon(Icons.phone_outlined, color: textColor),
                            const SizedBox(width: 10),
                            Text(
                              'Sign in with Phone',
                              style: TextStyle(
                                fontSize:
                                    ScreenUtils.screenWidthRatio(context, 0.05),
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  _googleButtonHandle() {
    Dialogs.showProgressbar(context);
    Navigator.pop(context);
    _signInWithGoogle().then((user) async {
      if (FirebaseAuth.instance.currentUser != null) {
        if ((await APIs.userExists())) {
          if (mounted) {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (_) => const HomeScreen()));
          }
        } else {
          User currentUser = FirebaseAuth.instance.currentUser!;
          await APIs.createUser(currentUser.displayName.toString(),currentUser.email.toString(),"Available on Conversa",currentUser.photoURL.toString()).then((value) {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await APIs.auth.signInWithCredential(credential).then((value) {
        setState(() {
          isDone = true;
        });
        return value;
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      Dialogs.showSnackbar(
          context, "Something went wrong. Check your internet connection");
      return Future.error("Authentication failed: $e");
    }
  }
}
