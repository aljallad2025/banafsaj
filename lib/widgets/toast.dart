import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/theme.dart';

class ToastUtil {
  static void show(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.TOP,
      backgroundColor: isError ? AppColors.red : AppColors.navy,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
