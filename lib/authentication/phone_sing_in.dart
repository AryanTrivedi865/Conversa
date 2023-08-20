import 'package:conversa/authentication/verification_otp.dart';
import 'package:conversa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonenumbers/phonenumbers.dart';

import '../screens/home_screen.dart';

class PhoneSIScreen extends StatefulWidget {
  const PhoneSIScreen({super.key});

  @override
  State<PhoneSIScreen> createState() => _PhoneSIScreenState();
}

class _PhoneSIScreenState extends State<PhoneSIScreen> {
  late Color buttonColor;
  late Color textColor;
  late Color buttonTextColor;

  ButtonState state = ButtonState.idle;
  bool isAnimating = true;
  PhoneNumberEditingController phoneNumberController =
      PhoneNumberEditingController.fromCountryCode('IN');

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.025)),
              Text(
                'Welcome to Conversa!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.01)),
              Text(
                'Continue with phone',
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.03)),
              PhoneNumberField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                dialogTitle: "Select your country",
                countryCodeWidth: ScreenUtils.screenWidthRatio(context, 0.263),
                prefixBuilder: (context, country) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CountryFlag.fromCountryCode(
                    country!.code,
                    height: 24,
                    width: 24,
                    borderRadius: 8,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.screenHeightRatio(context, 0.03)),
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
            ],
          ),
        ),
      ),
    );
  }

  _animatedButton() {
    return FilledButton(
      onPressed: () async {
        if (phoneNumberController.value.toString().isEmpty||
            phoneNumberController.value.toString().length < 10) {
          Dialogs.showSnackbar(context, "Please enter a valid phone number");
        } else {
          FocusScope.of(context).unfocus();
          setState(() {
            state = ButtonState.loading;
          });
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNumberController.value.toString(),
            timeout: Duration(seconds: 30),
            forceResendingToken: null,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential);
              setState(() {
                state = ButtonState.done;
              });
              await FirebaseAuth.instance.signInWithCredential(credential);
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            verificationFailed: (FirebaseAuthException e) {
              setState(() {
                state = ButtonState.idle;
              });
              showDialog(context: context, builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text(e.message.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ));
            },
            codeSent: (String verificationId, int? resendToken) async {
              setState(() {
                state = ButtonState.done;
              });
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerificationOTPScreen(
                    number: phoneNumberController.value.toString(), verificationId: verificationId,
                  ),
                ),
              ).then((value) => setState(() => state = ButtonState.idle));
            },
            codeAutoRetrievalTimeout: (String verificationId) {
            },
          );
        }
      },
      child: Text(
        'Send Verification Code',
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
}

enum ButtonState {
  idle,
  loading,
  done,
}
