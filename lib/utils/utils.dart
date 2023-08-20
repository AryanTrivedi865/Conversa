import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
          label: "OK",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ));
  }

  static void showDialogSingleButton(BuildContext context, String title,
      String message,String positiveText, VoidCallback voidCallback,String negativeText,VoidCallback negative) {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: voidCallback, child: Text(positiveText)),
                TextButton(onPressed: negative, child: Text(negativeText))
              ],
            ));
  }
}
class ScreenUtils{

  static double screenWidthRatio(BuildContext context,double value) {
    return MediaQuery.of(context).size.width * value;
  }
  static double screenHeightRatio(BuildContext context,double value) {
    return MediaQuery.of(context).size.height * value;
  }

}