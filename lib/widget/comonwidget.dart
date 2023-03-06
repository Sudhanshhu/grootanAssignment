import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cont.dart';

final kTextFieldDecoration = InputDecoration(
  counterStyle: const TextStyle(color: Colors.white),
  filled: true,
  fillColor: AppConstColor.primaryColor,
  contentPadding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 15.0),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

var kBoldTextStyle = const TextStyle(
  fontSize: 23.0,
  color: Colors.white,
);

showsnackBar(
    {required String msg,
    required String title,
    SnackPosition position = SnackPosition.BOTTOM,
    Color color = Colors.black,
    int time = 2}) {
  Get.snackbar(
    title,
    msg,
    snackPosition: position,
    backgroundColor: color,
    colorText: Colors.white,
    borderRadius: 10,
    margin: const EdgeInsets.all(10),
    borderWidth: 2,
    duration: Duration(seconds: time),
    icon: const Icon(Icons.error, color: Colors.white),
  );
}

String checkDate(DateTime dateToCheck) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  final aDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
  if (aDate == today) {
    return "t";
  } else if (aDate == yesterday) {
    return "y";
  } else {
    return "o";
  }
}
