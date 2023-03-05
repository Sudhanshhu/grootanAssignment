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
        // otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        // setState(() {
        //   authStatus = "TIMEOUT";
        // });
      },
    );
  }

  Future<void> verifyPhoneNo(String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      // FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          // .updatePhoneNumber(credential)
          .then((value) {
        showsnackBar(
            msg: "Mobile number successfully registered",
            title: "Success",
            color: Colors.green);
        // setState(() {
        //   isLoading = false;
        // });
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
    // await FirebaseAuth.instance
    //     .signInWithCredential(
    // //       PhoneAuthProvider.getCredential(
    // //   verificationId: verificationId,
    // //   smsCode: otp,
    // // )
    // );
  }

  // otpDialogBox(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Enter your OTP'),
  //           content: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextFormField(
  //               keyboardType: TextInputType.number,
  //               textAlign: TextAlign.center,
  //               maxLength: 6,
  //               style: const TextStyle(
  //                   fontSize: 30,
  //                   fontWeight: FontWeight.bold,
  //                   letterSpacing: 15),
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.all(
  //                     Radius.circular(30),
  //                   ),
  //                 ),
  //               ),
  //               onChanged: (value) {
  //                 otp = value;
  //               },
  //             ),
  //           ),
  //           contentPadding: const EdgeInsets.all(10.0),
  //           actions: <Widget>[
  //             OutlinedButton(
  //               onPressed: () {
  //                 verifyPhoneNo(otp);
  //               },
  //               child: const Text(
  //                 'Submit',
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

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

// class VerifyMobileNumber extends StatefulWidget {
//   const VerifyMobileNumber({super.key});

//   @override
//   State<VerifyMobileNumber> createState() => _VerifyMobileNumberState();
// }

// class _VerifyMobileNumberState extends State<VerifyMobileNumber> {
//   String? phoneNumber;
//   String verificationId = "";
//   String otp = "";
//   String authStatus = "";
//   bool isLoading = false;
//   TextEditingController mobileNumberController = TextEditingController();

//   Future<void> verifyPhoneNumber(BuildContext context, phoneNumber) async {
//     setState(() {
//       isLoading = true;
//     });
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       timeout: const Duration(seconds: 100),
//       verificationCompleted: (AuthCredential authCredential) {
//         showsnackBar(
//             title: "Success", msg: "Mobile number successfully verified");
//       },
//       verificationFailed: (FirebaseAuthException authException) {
//         print("authException is $authException");
//         showsnackBar(
//             title: "Error",
//             msg: "Authentication failed ${authException.code}",
//             color: Colors.red);
//         setState(() {
//           authStatus = "Authentication failed";
//           isLoading = false;
//         });
//       },
//       codeSent: (verId, forceCodeResent) {
//         verificationId = verId;
//         setState(() {
//           authStatus = "OTP has been successfully send";
//         });
//         otpDialogBox(context).then((value) {});
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         verificationId = verId;
//         setState(() {
//           authStatus = "TIMEOUT";
//         });
//       },
//     );
//   }

//   Future<void> verifyPhoneNo(String otp) async {
//     try {
//       final PhoneAuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: verificationId, smsCode: otp);
//       FirebaseAuth.instance.signInWithCredential(credential);

//       // FirebaseAuth.instance.currentUser!
//       //     .updatePhoneNumber(credential)
//       //     .then((value) {
//       //   showsnackBar(
//       //       msg: "Mobile nuber successfully registered 555", context: context);
//       //   setState(() {
//       //     isLoading = false;
//       //   });
//       // });
//     } on FirebaseAuthException catch (e) {
//       print("Error in Phone otp");
//       print(e.code);
//       showsnackBar(
//         title: "Error",
//         msg: "Otp you entered is wrong please try again",
//       );
//     }
//   }

//   otpDialogBox(BuildContext context) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Enter your OTP'),
//             content: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextFormField(
//                 keyboardType: TextInputType.number,
//                 textAlign: TextAlign.center,
//                 maxLength: 6,
//                 style: const TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 15),
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(30),
//                     ),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   otp = value;
//                 },
//               ),
//             ),
//             contentPadding: const EdgeInsets.all(10.0),
//             actions: <Widget>[
//               OutlinedButton(
//                 onPressed: () {
//                   verifyPhoneNo(otp);
//                 },
//                 child: const Text(
//                   'Submit',
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.2,
//           ),
//           const Text(
//             "Please verify your mobile number",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.cyan,
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               keyboardType: TextInputType.phone,
//               controller: mobileNumberController,
//               decoration: InputDecoration(
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(30),
//                     ),
//                   ),
//                   filled: true,
//                   // prefixIcon: const Icon(
//                   //   Icons.phone_iphone,
//                   //   color: Colors.cyan,
//                   // ),
//                   prefix: const Text(
//                     "+91",
//                     style: TextStyle(color: Color.fromARGB(255, 206, 28, 28)),
//                   ),
//                   hintStyle: TextStyle(color: Colors.grey[800]),
//                   hintText: "Enter your mobile number",
//                   fillColor: Colors.white70),
//               onChanged: (value) {
//                 phoneNumber = value;
//               },
//             ),
//           ),
//           const SizedBox(
//             height: 10.0,
//           ),
//           if (isLoading) const CircularProgressIndicator(),
//           if (!isLoading)
//             OutlinedButton(
//               onPressed: () => (mobileNumberController.text.length != 10)
//                   ? showsnackBar(
//                       title: "Error",
//                       msg: "plese enter  valid mobile number",
//                       color: Colors.red)
//                   : verifyPhoneNumber(context, mobileNumberController.text),
//               child: const Text(
//                 "Generate OTP",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           const SizedBox(
//             height: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }
