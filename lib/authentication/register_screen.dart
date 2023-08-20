import 'package:conversa/api/apis.dart';
import 'package:conversa/authentication/create_user.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late Color buttonColor;
  late Color textColor;
  late Color buttonTextColor;

  ButtonState state = ButtonState.idle;
  bool isAnimating = true;

  final _globalKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool passwordVisible = false;

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
              key: _globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.025)),
                  Text(
                    'Welcome to Conversa!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.01)),
                  Text(
                    'Create your account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: ScreenUtils.screenHeightRatio(context, 0.05)),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
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
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email cannot be empty';
                      } else if (!value.contains('@')) {
                        return 'Email must contain @';
                      }
                      return null;
                    },
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
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password cannot be empty';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      } else if (!value
                          .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain at least one special character';
                      } else if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one number';
                      } else if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Password must contain at least one uppercase letter';
                      } else if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Password must contain at least one lowercase letter';
                      }
                      return null;
                    },
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
                      height: ScreenUtils.screenHeightRatio(context, 0.03)),
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
                      height:
                          ScreenUtils.screenHeightRatio(context, 0.05)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Log in',
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

  _animatedButton() {
    return FilledButton(
      onPressed: () {
        if (_globalKey.currentState!.validate()) {
          setState(() {
            state = ButtonState.loading;
          });
          _signUp();
        }
      },
      child: Text(
        'Sign Up',
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

  void _signUp() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text)
        .then((_) async {
      User? user = auth.currentUser;
      user!.updateDisplayName(_nameController.text);
      user.updatePhotoURL(APIs.defaultImage);
      user.updateEmail(_emailController.text);
      await APIs.createUser(user.uid.toString(),_emailController.text,"Available on Conversa",APIs.defaultImage);
      setState(() {
        state = ButtonState.done;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Success'),
                content: Text('Account created successfully'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CreateUserScreen(authCred: _emailController.text, authType: "email", name: _nameController.text)));
                    },
                    child: Text('OK'),
                  ),
                ],
              ));
    }).catchError((error) {
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
              ));
    });
  }
}

enum ButtonState {
  idle,
  loading,
  done,
}
