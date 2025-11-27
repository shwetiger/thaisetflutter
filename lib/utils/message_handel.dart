// @dart=2.9
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class MessageHandel {
  static showMessage(BuildContext context, String title, String msg) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: title,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.only(top: 300.0, left: 10.0, right: 10.0),
      message: msg,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[200],
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
  }

  static showError(BuildContext context, String title, String msg) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.red, //.withOpacity(0.9),
      margin: const EdgeInsets.only(top: 200.0, left: 10.0, right: 10.0),
      message: msg,

      duration: const Duration(seconds: 3),

      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
    //if(msg.contains(other))
  }

  static showMessageDuration(
      BuildContext context, String title, String msg, int second) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.green[200], //.withOpacity(0.9),
      margin: const EdgeInsets.only(top: 200.0, left: 10.0, right: 10.0),
      message: msg,

      duration: Duration(seconds: second),

      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
    //if(msg.contains(other))
  }

  static showErrMessage(BuildContext context, String title, String msg) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      title: title,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.only(top: 300.0, left: 10.0, right: 10.0),
      message: msg,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
  }

  static void showErrSnackbar(
      String message, BuildContext context, int durationInSecs) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.red, //.withOpacity(0.9),
      margin: const EdgeInsets.only(top: 200.0, left: 10.0, right: 10.0),
      message: message,

      duration: Duration(seconds: durationInSecs),

      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
  }

  static void showSnackbar(
      String message, BuildContext context, int durationInSecs) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.green[200], //.withOpacity(0.9),
      margin: const EdgeInsets.only(top: 200.0, left: 10.0, right: 10.0),
      message: message,

      duration: Duration(seconds: durationInSecs),

      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
  }
}
