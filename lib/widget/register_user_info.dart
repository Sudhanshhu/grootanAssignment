import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:grootan_test/models/user_detail_model.dart';
import 'package:grootan_test/widget/comonwidget.dart';
import 'package:location/location.dart';

class UserHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future saveUser(
      {required User user,
      required BuildContext context,
      String? qrUrl}) async {
    String ipv4 = "";
    try {
      ipv4 = await Ipify.ipv4();
    } catch (e) {
      showsnackBar(
          title: "Error", msg: "Can not get ip address", color: Colors.red);
    }
    final userRef = _db.collection("users").doc(user.uid);
    Location location = Location();

    bool serviceEnabled = false;
    PermissionStatus? permissionGranted;
    LocationData? locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    try {
      locationData = await location.getLocation();
    } catch (e) {
      // ignore: use_build_context_synchronously
      showsnackBar(
          title: "Error", msg: "Error in getting locations", color: Colors.red);
    }
    List<gc.Placemark> placemarks = [];
    print(
        "Location data is ${locationData?.latitude} long: ${locationData?.longitude}");
    if (locationData != null) {
      placemarks = await gc.placemarkFromCoordinates(
          locationData.latitude!, locationData.longitude!);
      print("placemarks  ${placemarks.length}   ${placemarks[0].locality}");
    }
    UserModel userModel = UserModel(
        ip: ipv4,
        locality: placemarks.isNotEmpty ? placemarks[0].locality : "",
        loginTime: DateTime.now().toIso8601String(),
        qrUrl: qrUrl ?? "");

    // Map<String, dynamic> userData = {
    //   "userId": user.uid,
    //   "ip": ipv4,
    //   "locality": placemarks.isNotEmpty ? placemarks[0].locality : "",
    //   "loginTime": DateTime.now().toIso8601String()
    // };
    if (qrUrl != null) {
      await userRef.update({
        "userDetail": FieldValue.arrayUnion([userModel.toMap()])
      });
    } else {
      if ((await userRef.get()).exists) {
        await userRef.update({
          "userDetail": FieldValue.arrayUnion([userModel.toMap()])
        });
      } else {
        await userRef.set({
          "userDetail": [userModel.toMap()]
        });
      }
    }
  }
}
