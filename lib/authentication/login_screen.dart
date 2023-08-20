import 'dart:io';

import 'package:conversa/authentication/register_screen.dart';
import 'package:conversa/screens/home_screen.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Color buttonColor;
  late Color textColor;
  late Color buttonTextColor;

  ButtonState state = ButtonState.idle;
  bool isAnimating = true;

  bool passwordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Key emailKey = GlobalKey();
  Key passwordKey = GlobalKey();

  TextEditingController emailFPController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDone = state == ButtonState.done;
    final isStretched = isAnimating || state == ButtonState.idle;
    buttonColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Theme.of(context).colorScheme.onSurface;
    buttonTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Colors.black;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Wrap(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.025)),
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.01)),
                  Text(
                    'Login to your account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.05)),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    cursorColor: textColor,
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.02)),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: textColor,
                        ),
                      ),
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    cursorColor: textColor,
                    obscureText: !passwordVisible,
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.01)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _forgotPassword();
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.01)),
                  Container(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      width: state == ButtonState.idle
                          ? ScreenUtils.screenWidthRatio(context, 1)
                          : ScreenUtils.screenHeightRatio(context, 0.065),
                      height: ScreenUtils.screenHeightRatio(context, 0.065),
                      onEnd: () => setState(() => isAnimating = !isAnimating),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: isStretched
                          ? _animatedButton()
                          : _animatedSmallButton(isDone),
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.05)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _forgotPassword() {
    final GlobalKey<FormState> _formFPKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: Form(
          key: _formFPKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email address to reset your password'),
              SizedBox(height: 16),
              TextFormField(
                key: emailKey,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                controller: emailFPController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: textColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                cursorColor: textColor,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formFPKey.currentState!.validate()) {
                setState(() {
                  state = ButtonState.loading;
                });
                Navigator.pop(context);
                _resetPassword();
              }
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
  _resetPassword(){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.sendPasswordResetEmail(email: emailFPController.text.toString().trim()).then((value) {
      setState(() {
        state = ButtonState.done;
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            state = ButtonState.idle;
          });
        });
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Password reset email sent'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  state = ButtonState.idle;
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      print(error.toString());
      setState(() {
        state = ButtonState.idle;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
  }

  _animatedButton() {
    return FilledButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            state = ButtonState.loading;
          });
          _login();
        }
      },
      child: Text(
        'Login',
        style: GoogleFonts.poppins(
          fontSize: 18,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  _login() async {
    try {
      await InternetAddress.lookup("google.com");
      FirebaseAuth auth = FirebaseAuth.instance;
      auth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then(
        (value) {
          setState(() {
            state = ButtonState.done;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Success'),
              content: Text('Login successful'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      state = ButtonState.idle;
                    });
                    Navigator.pop(context);
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
      ).catchError(
        (error) {
          setState(
            () {
              state = ButtonState.idle;
            },
          );
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
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

  _animatedSmallButton(bool isDone) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? Colors.green.shade400 : buttonColor,
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.done, color: buttonTextColor, size: 32)
            : CircularProgressIndicator(
                strokeWidth: 2,
                color: buttonTextColor,
              ),
      ),
    );
  }
}

enum ButtonState {
  idle,
  loading,
  done,
}
