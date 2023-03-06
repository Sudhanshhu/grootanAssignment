import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grootan_test/screen/login_page.dart';
import 'package:grootan_test/widget/plugin_screen.dart';
import 'package:grootan_test/widget/register_user_info.dart';

import 'common_bg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          UserHelper.saveUser(user: snapshot.data!, context: context);
          return QRImage(user: snapshot.data!);
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }
        return CommonBackground(
            logOutBtnEnable: false, title: "Login", child: const LoginPage());
      },
    );
  }
}
