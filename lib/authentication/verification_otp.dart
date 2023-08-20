import 'dart:io';

import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/create_user.dart';
import 'package:conversa/screens/home_screen.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class VerificationOTPScreen extends StatefulWidget {
  final String number;
  final String verificationId;

  const VerificationOTPScreen(
      {super.key, required this.number, required this.verificationId});

  @override
  State<VerificationOTPScreen> createState() => _VerificationOTPScreenState();
}

class _VerificationOTPScreenState extends State<VerificationOTPScreen> {
  late Color buttonColor;
  late Color buttonTextColor;
  late Color textColor;

  String _verificationCode = "";
  String verificationId = "";

  @override
  Widget build(BuildContext context) {
    verificationId= widget.verificationId;
    buttonColor = Theme
        .of(context)
        .brightness == Brightness.light
        ? Colors.black
        : Theme
        .of(context)
        .colorScheme
        .onSurface;
    buttonTextColor = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    textColor = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Theme
        .of(context)
        .colorScheme
        .onSurface
        : Colors.black;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.screenHeightRatio(context, 0.02),
            vertical: ScreenUtils.screenHeightRatio(context, 0.08)),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Verification",
                style: GoogleFonts.poppins(
                    fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.04),
              ),
              Text(
                "Enter the OTP sent to the number",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.008),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: ScreenUtils.screenWidthRatio(context, 0.1),
                  ),
                  Text(
                    widget.number,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: buttonColor,
                        size: 18,
                      ))
                ],
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.05),
              ),
              Pinput(
                length: 6,
                autofocus: true,
                showCursor: false,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                    fontSize: 22,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .surface,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: Colors.grey),
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                  ),
                ),
                onSubmitted: (String pin) {
                  _signIn(pin);
                },
                androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
                onCompleted: (String pin) {
                  _signIn(pin);
                  setState(() {
                    _verificationCode = pin;
                  });
                },
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.05),
              ),
              FilledButton(
                onPressed: () {
                  _signIn(_verificationCode);
                },
                child: Text(
                  "Verify",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(ScreenUtils.screenWidthRatio(context, 1),
                      ScreenUtils.screenHeightRatio(context, 0.065)),
                ),
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.05),
              ),
              Text(
                "Didn't receive the OTP?",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: ScreenUtils.screenHeightRatio(context, 0.01),
              ),
              TextButton(
                child: Text("Resend OTP",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                onPressed: () {
                  FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: widget.number,
                    verificationCompleted: (PhoneAuthCredential credential) {
                      FirebaseAuth.instance
                          .signInWithCredential(credential)
                          .then((value) {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text('Success'),
                                content: Text('Login successful'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      if (await APIs.userExists()) {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()));
                                      } else {
                                        TextEditingController _controller =
                                        TextEditingController();
                                        GlobalKey<FormState> _formKey =
                                        GlobalKey<FormState>();
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              AlertDialog(
                                                title: Text(
                                                    "Profile Information"),
                                                content: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Please enter your name";
                                                          }
                                                          return null;
                                                        },
                                                        controller: _controller,
                                                        decoration: InputDecoration(
                                                          labelText: "Name",
                                                          border: OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          FirebaseAuth.instance
                                                              .currentUser!
                                                              .updateDisplayName(
                                                              _controller.text);
                                                          await APIs.createUser(FirebaseAuth.instance.currentUser!.uid.toString(),widget.number,"Available on Conversa",APIs.defaultImage);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      CreateUserScreen(authCred: widget.number, authType: "phone", name: "")));
                                                        }
                                                      },
                                                      child: Text("OK"))
                                                ],
                                              ),
                                        );
                                      }
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      }).catchError((error) {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text('Error'),
                                content: Text(error.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      });
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {
                      verificationId= verificationId;
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      verificationId = verificationId;
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text('Error'),
                              content: Text(e.message.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                      );
                    },

                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signIn(String pin) async {
    try {
      await InternetAddress.lookup("google.com");
      FirebaseAuth auth = FirebaseAuth.instance;
      auth
          .signInWithCredential(PhoneAuthProvider.credential(
          smsCode: pin, verificationId: widget.verificationId))
          .then(
            (value) async {
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text('Success'),
                  content: Text('Login successful'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (await APIs.userExists()) {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => HomeScreen()));
                        } else {
                          await APIs.createUser(FirebaseAuth.instance.currentUser!.uid.toString(),widget.number,"Available on Conversa",APIs.defaultImage);
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => CreateUserScreen(authCred: widget.number, authType: "phone", name: "")));
                        }
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
          );
        },
      ).catchError(
            (error) {
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text('Error'),
                  content: Text(error.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
          );
        },
      );
    } on Exception catch (e) {
      Navigator.pop(context);
      Dialogs.showSnackbar(
          context, "Something went wrong. Check your internet connection");
      return Future.error("Authentication failed: $e");
    }
  }
}
