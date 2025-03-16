import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ToastMessage {
  void toastMessage(String message, {Color backgroundColor = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor, // Use the parameter here
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}