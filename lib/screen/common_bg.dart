import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:grootan_test/screen/sign_in_screen.dart';

import '../widget/cont.dart';

class CommonBackground extends StatelessWidget {
  final String title;
  final bool logOutBtnEnable;
  final Widget child;
  CommonBackground(
      {Key? key,
      required this.title,
      required this.child,
      required this.logOutBtnEnable})
      : super(key: key);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _key,
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: AppConstColor.primaryColor,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: GestureDetector(
                              onTap: () {
                                FirebaseAuth.instance.signOut().then((value) =>
                                    Get.to(() => const SignInScreen()));
                              },
                              child: const SizedBox(
                                  height: 50,
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ))),
                        )),
                    Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppConstColor.secondaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ))),
                    Expanded(
                      child: Container(
                          color: AppConstColor.secondaryColor, child: child),
                    )
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const Spacer()
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
