import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';
import 'package:grootan_test/widget/plugin_screen.dart';

import 'dart:async';

import '../widget/comonwidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? phoneNumber;
  String verificationId = "";
  String otp = "";
  String authStatus = "";
  bool isLoading = false;
  bool codeSent = false;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  Future<void> verifyPhoneNumber(BuildContext context, phoneNumber) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 100),
      verificationCompleted: (AuthCredential authCredential) {
        showsnackBar(
          title: "Success",
          msg: "Mobile number successfully verified",
        );
      },
      verificationFailed: (FirebaseAuthException authException) {
        print("authException is $authException");
        showsnackBar(
            title: "Failed",
            msg: "Authentication failed ${authException.code}",
            color: Colors.red);
        setState(() {
          authStatus = "Authentication failed";
          isLoading = false;
        });
      },
      codeSent: (verId, forceCodeResent) {
        verificationId = verId;
        setState(() {
          codeSent = true;
          authStatus = "OTP has been successfully send";
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> verifyPhoneNo(String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) {
        showsnackBar(
            msg: "Mobile number successfully registered",
            title: "Success",
            color: Colors.green);

        User? user = FirebaseAuth.instance.currentUser;
        Get.offAll(() => QRImage(user: user!));
      }).catchError((onError) {
        if (onError.code.toString() == "invalid-verification-code") {
          showsnackBar(
              msg: "verification code entered is wrong",
              title: "Error",
              color: Colors.red,
              time: 5);
          return;
        }
        showsnackBar(
            msg: "Something went wrong",
            title: "Error",
            color: Colors.red,
            time: 5);
      });
    } catch (e) {
      print("Error in Phone otp");
      print(e);
      showsnackBar(
          msg: "Otp you entered is wrong please try again",
          title: "Error",
          color: Colors.red);
    }
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Enter mobile number",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextField(
            controller: phoneNumberController,
            maxLength: 10,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.center,
            decoration: kTextFieldDecoration.copyWith(
                prefixIcon: const Icon(Icons.mobile_friendly),
                helperText: "Enter mobile number"),
          ),
          const SizedBox(height: 20),
          if (!codeSent)
            SizedBox(
              height: 60,
              child: Center(
                child: OutlinedButton(
                    onPressed: () async {
                      if (isLoading) {
                        showsnackBar(title: "Loading", msg: "please wait");
                        return;
                      }
                      if (phoneNumberController.text.length != 10) {
                        showsnackBar(
                            title: "Error",
                            msg: "Please enter valid mobile number",
                            color: Colors.red);
                        return;
                      }
                      await verifyPhoneNumber(
                          context, "+91${phoneNumberController.text}");
                    },
                    child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text("Send otp")))),
              ),
            ),
          if (codeSent)
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: kTextFieldDecoration,
            ),
          if (codeSent)
            SizedBox(
              height: 60,
              child: Center(
                child: OutlinedButton(
                    onPressed: () async {
                      await verifyPhoneNo(otpController.text);
                    },
                    child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text("Login")))),
              ),
            )
        ],
      ),
    );
  }
}
