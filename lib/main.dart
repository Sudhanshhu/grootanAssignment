import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grootan_test/screen/last_login_page.dart';
import 'package:grootan_test/screen/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        routes: {"lastLoginPage": (context) => const LastLoginPage()},
        debugShowCheckedModeBanner: false,
        home: const SignInScreen());
  }
}
