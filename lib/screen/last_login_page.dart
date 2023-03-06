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
                  displayLoginDetailAcTODayOfSignIn(filterList),
                  displayLoginDetailAcTODayOfSignIn(filterList),
                  displayLoginDetailAcTODayOfSignIn(filterList),
                ]),
          ),
        ));
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
                  .toList(),
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
