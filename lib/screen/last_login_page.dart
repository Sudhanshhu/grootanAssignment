import 'package:flutter/material.dart';

import 'package:grootan_test/models/user_detail_model.dart';
import 'package:grootan_test/screen/common_bg.dart';
import 'package:grootan_test/widget/cont.dart';
import 'package:intl/intl.dart';

import '../widget/comonwidget.dart';

class LastLoginPage extends StatefulWidget {
  static const routeName = "lastLoginPage";
  const LastLoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LastLoginPage> createState() => _LastLoginPageState();
}

class _LastLoginPageState extends State<LastLoginPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  ScrollController? scrollViewController;
  final textStyle = const TextStyle(
    color: Colors.white,
  );
  var now = DateTime.now();

  List<UserModel> userModelList = [];
  List<UserModel> filterList = [];
  int currentIndex = 0;

  filteredList(List<UserModel> list) {
    filterList = [];

    if (currentIndex == 0) {
      for (var e in list) {
        if (checkDate(DateTime.parse(e.loginTime!)) == "t") {
          filterList.add(e);
        }
      }
    }
    if (currentIndex == 1) {
      for (var e in list) {
        if (checkDate(DateTime.parse(e.loginTime!)) == "y") {
          filterList.add(e);
        }
      }
    }
    if (currentIndex == 2) {
      for (var e in list) {
        if (checkDate(DateTime.parse(e.loginTime!)) == "o") {
          filterList.add(e);
        }
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    scrollViewController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var yester = now.subtract(const Duration(days: 1));
    userModelList =
        ModalRoute.of(context)!.settings.arguments as List<UserModel>;
    filteredList(userModelList);
    return CommonBackground(
        title: "Last Login",
        logOutBtnEnable: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: NestedScrollView(
            controller: scrollViewController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  expandedHeight: 10,
                  toolbarHeight: 10,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  bottom: TabBar(
                      onTap: (value) {
                        setState(() {
                          currentIndex = value;
                          tabController!.index = value;
                        });
                        // print("value is $value");
                      },
                      controller: tabController,
                      tabs: const [
                        Padding(
                          padding: EdgeInsets.only(bottom: 18.0),
                          child: Text("Today"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 18.0),
                          child: Text("Yesterday"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 18.0),
                          child: Text("others"),
                        ),
                      ]),
                )
              ];
            },
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  // if (currentIndex == 0)
                  displayLoginDetailAcTODayOfSignIn(filterList),
                  // if (currentIndex == 1)
                  displayLoginDetailAcTODayOfSignIn(filterList),
                  // if (currentIndex == 2)
                  displayLoginDetailAcTODayOfSignIn(filterList),
                ]),
          ),
        )
        // DefaultTabController(
        //     initialIndex: currentIndex,
        //     length: 3,
        //     child: Scaffold(
        //       backgroundColor: AppConstColor.secondaryColor,
        //       appBar: PreferredSize(
        //         preferredSize: const Size.fromHeight(60),
        //         child: AppBar(
        //           backgroundColor: AppConstColor.secondaryColor,
        //           automaticallyImplyLeading: false,
        //           bottom: TabBar(
        //               onTap: (value) {
        //                 print("vlue is $value");
        //               },
        //               physics: const NeverScrollableScrollPhysics(),
        //               isScrollable: false,
        //               indicatorColor: Colors.white,
        //               tabs: [
        //                 Padding(
        //                   padding: const EdgeInsets.only(bottom: 4.0),
        //                   child: TextButton(
        //                       onPressed: () {
        //                         if (currentIndex != 0) {
        //                           setState(() {
        //                             currentIndex = 0;
        //                           });
        //                         }
        //                       },
        //                       child: const Text("Today")),
        //                 ),
        //                 TextButton(
        //                   onPressed: () {
        //                     if (currentIndex != 1) {
        //                       setState(() {
        //                         currentIndex = 1;
        //                       });
        //                     }
        //                   },
        //                   child: const Padding(
        //                     padding: EdgeInsets.only(bottom: 4.0),
        //                     child: Text("Yesterday"),
        //                   ),
        //                 ),
        //                 TextButton(
        //                   onPressed: () {
        //                     if (currentIndex != 2) {
        //                       setState(() {
        //                         currentIndex = 2;
        //                       });
        //                     }
        //                   },
        //                   child: const Padding(
        //                     padding: EdgeInsets.only(bottom: 4.0),
        //                     child: Text("Others"),
        //                   ),
        //                 ),
        //               ]),
        //           // title: const Text("Tabs Demo"),
        //         ),
        //       ),
        //       body: TabBarView(
        //         children: [
        //           displayLoginDetailAcTODayOfSignIn(filterList),
        //           displayLoginDetailAcTODayOfSignIn(filterList),
        //           displayLoginDetailAcTODayOfSignIn(filterList),
        //         ],
        //       ),
        //     )
        //     // child:
        //     ),

        );
  }

  SingleChildScrollView displayLoginDetailAcTODayOfSignIn(
      List<UserModel> userDetail) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(
                top: 0.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Column(
              children: userDetail
                  .map(
                      (e) => UserDetailCard(userModel: e, textStyle: textStyle))
                  .toList()
              // UserDetailCard(textStyle: textStyle),
              ,
            )));
  }
}

class UserDetailCard extends StatelessWidget {
  final UserModel userModel;
  const UserDetailCard({
    Key? key,
    required this.userModel,
    required this.textStyle,
  }) : super(key: key);

  final TextStyle textStyle;
  final bigBoxHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.parse(userModel.loginTime!);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    // color: Colors.red,
                  ),
                  width: double.infinity,
                  height: bigBoxHeight,
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: AppConstColor.greyColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.jm().format(dateTime),
                                // dateTime.fo,
                                style: textStyle,
                              ),
                              Text(
                                "IP : ${userModel.ip}",
                                style: textStyle,
                              ),
                              Text(
                                userModel.locality ?? "N/A",
                                style: textStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              if (userModel.qrUrl != null && userModel.qrUrl!.isNotEmpty)
                Positioned(
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: AppConstColor.whiteColor,
                      ),
                      height: bigBoxHeight,
                      width: bigBoxHeight,
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        userModel.qrUrl!,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        // When dealing with networks it completes with two states,
                        // complete with a value or completed with an error,
                        // So handling errors is very important otherwise it will crash the app screen.
                        // I showed dummy images from assets when there is an error, you can show some texts or anything you want.
                        errorBuilder: (context, exception, stackTrace) {
                          return const Text("Image not found");
                        },
                      ),
                    ))
            ],
          ),
        )
      ],
    );
  }
}

//  Column(
//   children: [
//     SizedBox(
//       height: 90,
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Column(
//               children: [
//                 const Spacer(),
//                 Column(
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.grey),
//                         height: 70,
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Time", style: textStyle),
//                                   Text("IP : 254.254.2325",
//                                       style: textStyle),
//                                   Text("location", style: textStyle)
//                                 ],
//                               ),
//                             ),
//                             const Spacer(),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 color: Colors.amber,
//                                 height: 80,
//                                 width: 80,
//                               ),
//                             )
//                           ],
//                         )),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         color: Colors.amber,
//         height: 80,
//         width: 80,
//       ),
//     )
//   ],
// ),
