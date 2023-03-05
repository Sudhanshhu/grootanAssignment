import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grootan_test/screen/common_bg.dart';
import 'package:grootan_test/widget/register_user_info.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
// show QrEmbeddedImageStyle, QrImage, QrPainter, QrVersions;

import '../models/user_detail_model.dart';
import 'comonwidget.dart';
import '../firebase_api.dart';

class QRImage extends StatefulWidget {
  final User user;
  const QRImage({super.key, required this.user});

  @override
  State<QRImage> createState() => _QRImageState();
}

class _QRImageState extends State<QRImage> {
  File? file;
  UploadTask? task;
  Uint8List? imageinUint;

  Future<Uint8List> toQrImageData(String text) async {
    try {
      final image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        // color: hexToColor('#000000'),
        // emptyColor: hexToColor('#ffffff'),
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);
      return a!.buffer.asUint8List();
    } catch (e) {
      rethrow;
    }
  }

  String rendomNumber = "";
  String lastLoginTime = "";
  bool saved = false;
  bool isLoding = false;
  @override
  void initState() {
    rendomNumber = Random().nextInt(9999).toString();
    super.initState();
  }

  // Future<Uint8List> _getWidgetImage() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //         _renderObjectKey.currentContext.findRenderObject();
  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     var pngBytes = byteData.buffer.asUint8List();
  //     var bs64 = base64Encode(pngBytes);
  //     debugPrint(bs64.length.toString());
  //     return pngBytes;
  //   } catch (exception) {}
  // }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
        logOutBtnEnable: false,
        title: "PLUGINS",
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }
              if (snapshot.hasData) {
                var dataRecd = snapshot.data?.data();
                List data = (dataRecd != null && dataRecd.isNotEmpty)
                    ? dataRecd["userDetail"] as List
                    : [];
                List<UserModel> userDataList =
                    data.map((e) => UserModel.fromMap(e)).toList();
                print(userDataList.length);
                lastLoginTime = userDataList.isEmpty
                    ? ""
                    : (userDataList.length > 1)
                        ? userDataList[userDataList.length - 1].loginTime ?? ""
                        : userDataList.last.loginTime ?? "";
                if (lastLoginTime.isNotEmpty) {
                  String day = checkDate(DateTime.parse(lastLoginTime));
                  if (day == "t") {
                    lastLoginTime =
                        "today ${DateFormat().add_jm().format(DateTime.parse(lastLoginTime))}";
                  } else if (day == "y") {
                    lastLoginTime =
                        "yesterday ${DateFormat().add_jm().format(DateTime.parse(lastLoginTime))}";
                  } else {
                    lastLoginTime = DateFormat("d MMM,h:mm a")
                        .format(DateTime.parse(lastLoginTime));
                  }
                }
                print("lastLoginTime $lastLoginTime");
                return body(context: context, userDataList: userDataList);
              }
              return const Center(child: Text("Loading"));
            }));
  }

  Stack body(
      {required BuildContext context, required List<UserModel> userDataList}) {
    const Color background = Color.fromARGB(18, 18, 18, 1);
    Color fill = Colors.indigo;
    final List<Color> gradient = [
      background,
      background,
      fill,
      fill,
    ];
    const double fillPercent = 56.23; // fills 56.23% for container from bottom
    const double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    return Stack(
      children: [
        // generated number card
        Column(
          children: [
            const SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: gradient,
                    stops: stops,
                    // end: Alignment.bottomCenter,
                    // begin: Alignment.topCenter,
                    begin: const Alignment(0.8, 1.7),
                    end: const Alignment(-0.1, 2.0),
                    // colors: [
                    //   AppConstColor.primaryColor,
                    //   Colors.indigo,
                    //   const Color.fromARGB(255, 72, 66, 66),
                    //   const Color.fromARGB(255, 11, 11, 11)
                    // ],
                    transform: const GradientRotation(pi * 6 / 8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        "Generated number",
                        style: kBoldTextStyle,
                      ),
                      Text(
                        rendomNumber,
                        style: kBoldTextStyle,
                      ),
                      const SizedBox(height: 25)
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        // QR code
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: QrImage(
                    data: rendomNumber,
                    size: 150,
                    // You can include embeddedImageStyle Property if you
                    //wanna embed an image from your Asset folder
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(
                        100,
                        100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Spacer(),
            Center(
                child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed("lastLoginPage", arguments: userDataList);
              },
              child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      "Last login $lastLoginTime",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
            )),
            const SizedBox(height: 20),

            // button(
            //     btnTitle: Text(
            //         "Last login ${DateFormat("MMM d,h:mm a").format(DateTime.parse(lastLoginTime))}"),
            //     fun: () {
            //       Navigator.of(context)
            //           .pushNamed("lastLoginPage", arguments: userDataList);
            //     },
            //     color: Colors.white)),
            if (task != null)
              SizedBox(
                height: 80,
                child: buildUploadStatus(task!),
              ),
            button(
                btnTitle: (isLoding)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Text(saved ? "Already saved" : "Save"),
                fun: () async {
                  if (saved) {
                    showsnackBar(title: "Error", msg: "Already saved");
                    return;
                  }
                  setState(() {
                    isLoding = true;
                  });
                  var image = await toQrImageData(rendomNumber);
                  // file = File.fromRawPath(image);
                  // if (file != null) {
                  print("image uploading");
                  uploadFile(image).then((value) async {
                    await UserHelper.saveUser(
                        context: context, user: widget.user, qrUrl: value);
                    // showsnackBar(
                    //     msg: "Successsfully uploaded", context: context);
                    setState(() {
                      saved = true;
                      isLoding = false;
                      task = null;
                    });

                    // UserModel userModel = UserModel(ip: ip)
                    // FirebaseApi.uploadUserStatus();
                  });
                },
                color: Colors.grey),
            const SizedBox(height: 80)
          ],
        )
        // topStackWidget(Column(
        //   children: [button(), button()],
        // ))
      ],
    );
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return SizedBox(
              height: 100,
              child: Column(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    color: Colors.green,
                  ),
                  const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "uploading file",
                        style: TextStyle(color: Colors.white),
                      )
                      // "Uploading $uploadingCount/${fileList.length} file"),
                      )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );

  Future<String> uploadFile(Uint8List uploadingFile) async {
    final fileName = DateTime.now().toIso8601String();
    task = FirebaseApi.uploadFile(fileName, uploadingFile);
    setState(() {});
    if (task == null) return "";
    try {
      final snapshot = await task!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download-Link: $urlDownload');
      return urlDownload;
    } catch (e) {
      return "";
    }
  }
}

Widget button(
    {required Color color,
    required Widget btnTitle,
    required VoidCallback fun}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: fun,
      child: Container(
        width: 250,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: btnTitle,
        ),
      ),
    ),
  );
}


        // SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       const SizedBox(height: 150),
        //       SizedBox(
        //         height: 350,
        //         width: width * 0.9,
        //         child: Stack(
        //           clipBehavior: Clip.none,
        //           children: [
        //             Padding(
        //               padding: const EdgeInsets.all(12.0),
        //               child: Container(
        //                 height: 250,
        //                 width: double.infinity,
        //                 decoration: BoxDecoration(
        //                   gradient: LinearGradient(
        //                     begin: const Alignment(-1.0, 0.0),
        //                     end: const Alignment(1.0, 0.0),
        //                     colors: [AppConstColor.primaryColor, Colors.indigo],
        //                     transform: const GradientRotation(pi / 4),
        //                   ),
        //                 ),
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Column(
        //                     children: [
        //                       const Spacer(),
        //                       Text(
        //                         "Generated number",
        //                         style: kBoldTextStyle,
        //                       ),
        //                       Text(
        //                         rendomNumber,
        //                         style: kBoldTextStyle,
        //                       ),
        //                       const SizedBox(height: 25)
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             Positioned(
        //               top: -50,
        //               left: width / 4,
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     color: Colors.white,
        //                     borderRadius: BorderRadius.circular(10.0)),
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: QrImage(
        //                     data: rendomNumber,
        //                     size: 150,
        //                     // You can include embeddedImageStyle Property if you
        //                     //wanna embed an image from your Asset folder
        //                     embeddedImageStyle: QrEmbeddedImageStyle(
        //                       size: const Size(
        //                         100,
        //                         100,
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       TextButton(
        //           onPressed: () async {
        //             var image = await toQrImageData(" Default Address");
        //             // file = File.fromRawPath(image);
        //             // if (file != null) {
        //             print("image uploading");
        //             uploadFile(image);
        //             // }
        //           },
        //           child: const Text("Save QR COde")),
        //       TextButton(
        //           onPressed: () async {
        //             var image = await toQrImageData(" Default Address");
        //             imageinUint = image;
        //             file = File.fromRawPath(image);
        //             if (file != null) {
        //               print("image uploading");
        //               // uploadFile(file!);
        //             }
        //             setState(() {});
        //           },
        //           child: const Text("Generate Image")),
        //       if (imageinUint != null) Image.memory(imageinUint!)
        //     ],
        //   ),
        // ),


