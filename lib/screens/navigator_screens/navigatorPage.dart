import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:student_paddy_mobile/components/custom_prompt.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/controllers/home_page_controller.dart';
import 'package:student_paddy_mobile/controllers/navigator_controller.dart';
import 'package:student_paddy_mobile/navigation_icons_icons.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/getXController.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accountsPage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/communityPage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/dubsPage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/homePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/global_search.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/notificationsPage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/messages_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/topicsPage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class NavigatorPage extends StatefulWidget {
  final int? index;
  NavigatorPage({this.index});

  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  NavigatorController navController = Get.put(NavigatorController());
  HomeController homeController = Get.put(HomeController(), permanent: false);
  late PersistentTabController controller;
  TextEditingController appBarSearchController = TextEditingController();
  bool quickActionStatus = false;
  bool showFAB = true;
  int notifsCount = 0;
  int notificationsCount = 0;
  bool showNotificationBadge = false;
  bool showMessageBadge = false;
  final CounterController counterController = Get.put(CounterController());
  int unreadMessagesCount = 0;
  Timer? timer;

  DateTime? backButtonPressTime;
  static const snackBarDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: widget.index ?? 0);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controller.addListener(() {
      setState(() {});
    });
    initSocket();
    // getUnreadMessagesCount(context);
    notificationCount();
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    final newVersion = NewVersion(
      // iOSId: '1563637282',
      androidId: 'com.studentpaddy.student_paddy_mobile',
    );
    if (userModel.canShowUpdate) {
      statusCheck(newVersion);
    } else {}
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      handlePushNotification(context);
      CounterController counterController = Get.put(CounterController());
      counterController.addListener(() async {
        if (counterController.notificationData.isNotEmpty) {
          //  print(counterController.notificationData);
          if (counterController.notificationData == {}) {
          } else if (counterController.notificationData["subType"] == "Post") {
            Map<String, dynamic> data = await getPostsOrResourcesById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["subType"] ==
              "Comment") {
            Map<String, dynamic> data = await getPostsOrResourcesById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["subType"] ==
              "Repost") {
            Map<String, dynamic> data = await getPostsOrResourcesById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["subType"] == "Reask") {
            Map<String, dynamic> data = await getQuestionById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["subType"] ==
              "Question") {
            Map<String, dynamic> data = await getQuestionById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["subType"] ==
              "Resource") {
            Map<String, dynamic> data = await getPostsOrResourcesById(
                context, counterController.notificationData["paddyId"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          } else if (counterController.notificationData["type"] == "Message") {
            // Map<String, dynamic> data = await getPostsOrResourcesById(context, controlModel.notificationDetails!["paddyId"]);
            pushNewScreen(context, screen: MessagesScreen());
          } else if (counterController.notificationData["type"] == "Profile") {
            pushNewScreen(context,
                screen: OtherProfilePage(content: {
                  "personId": counterController.notificationData["personId"]
                }));
          }
          counterController.clearNotif();
        }
      });
    });
    // retrieveDynamicLink(context);
    getData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // getNotifsCount();
      // timer = Timer.periodic(Duration(seconds: 4), (timer) async {
      //   notificationsCount = await getNotificationCount(context);
      //   unreadMessagesCount = await getUnreadMessagesCount(context);
      //   //  print(notificationsCount.toString());
      //   setState(() {});
      // });
    });
    controlModel.addListener(() {
      //  print("Handling push Notifications");
      //  print(controlModel.notificationDetails);
      if (controlModel.notificationDetails!.isNotEmpty) {
        //  print("Handling push Notifications");
        //  print(controlModel.notificationDetails);
        handlePushNotification(context);
      }
      if (controlModel.updateTopicList == true) {
        quickTopics(context);
      }
    });
  }

  getData() async {
    await quickUserData(context);
  }

  increaseNotificationCount(int count) async {
    notifsCount = count;
    unreadMessagesCount > 0
        ? showMessageBadge = true
        : showMessageBadge = false;
    counterController.setNotifCount(notifsCount.obs);
    //  print("Count: ${counterController.notifCount}");
    showNotificationBadge = counterController.notifCount.toInt() > 0;
    setState(() {});
  }

  notificationCount() async {
    notifsCount = await getNotificationCount(context);
    unreadMessagesCount = await getUnreadMessagesCount(context);
    unreadMessagesCount > 0
        ? showMessageBadge = true
        : showMessageBadge = false;
    counterController.setNotifCount(notifsCount.obs);
    //  print("Count: ${counterController.notifCount}");
    showNotificationBadge = counterController.notifCount.toInt() > 0;
    setState(() {});
  }

  getNotifsCount() async {
    notifsCount = await getNotificationCount(context);
    //  print("Notifs Count: $notifsCount");
    setState(() {});
  }

  statusCheck(NewVersion newVersion) async {
    // UserChangeNotifierModel userModel = Provider.of<UserChangeNotifierModel>(context, listen: false);
    // final status = await newVersion.getVersionStatus();
    // //  print(status?.canUpdate);
    // //  print(status?.localVersion);
    // //  print(status?.storeVersion);
    // //  print(status?.canUpdate);
    // //  print(status?.appStoreLink);
    // //  print(status?.releaseNotes);
    // // newVersion.showAlertIfNecessary(
    // //   context: context,
    // // );
    // newVersion.showUpdateDialog(
    //   context: context,
    //   versionStatus: status!,
    //   dialogTitle: 'App Update Available',
    //   updateButtonText: 'Update Now',
    //   dismissAction: () {
    //     Navigator.pop(context);
    //     userModel.setCanShowUpdate(false);
    //   },
    //   dismissButtonText: 'Later',
    //   dialogText: 'A newer version of the app is available: ${status.releaseNotes}',
    // );
    // //  print(newVersion.iOSId);
  }

  void initSocket() {
    //  print("Connecting to Socket");
    // IO.Socket socket = IO.io(NetworkData.baseUrl.replaceAll("/v1/", ""), <String, dynamic>{
    //   'transports': ['websocket'],
    //   'autoConnect': false,
    // });
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.socket.connect();
    //  print('Trying to connect');
    //  print(controlModel.socket.connected);
    controlModel.socket.onConnect((data) => //  print("Connected"));
        controlModel.socket.on("initiateChat", (data) async {
          //  print(data);
          unreadMessagesCount = await getUnreadMessagesCount(context);
        }));
    controlModel.socket.on(
        "connect",
        (data) => {
              controlModel.socket.emit("message-room", {"userId": userModel.id})
            });
    controlModel.socket.on("paddy-stream", (data) {
      //  print(data);
      setActionState(data);
    });
    controlModel.socket.on("receive-message", (data) {
      //  print(data);
      if (mounted)
        setState(() {
          showMessageBadge = true;
          controlModel.setMessageBadge(true);
        });
    });
    controlModel.socket.on("notification", (data) {
      //  print("DATA $data");
      // Write a function to get the time
      // if (data["userId"] == userModel.id) {
      increaseNotificationCount(data["count"]);
      // }
      // getNotifsCount();
      // setState(() {});
    });
    controlModel.socket.on("message-count", (data) async {
      //  print("Data $data");
      notificationCount();
    });
  }

  handlePushNotification(BuildContext context) async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    if (controlModel.notificationDetails == {} ||
        controlModel.notificationDetails == null ||
        controlModel.notificationDetails!.isEmpty) {
      return;
    } else if (controlModel.notificationDetails!["subType"] == "Post") {
      Map<String, dynamic> data = await getPostsOrResourcesById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Comment") {
      Map<String, dynamic> data = await getPostsOrResourcesById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Repost") {
      Map<String, dynamic> data = await getPostsOrResourcesById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Reask") {
      Map<String, dynamic> data = await getQuestionById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Question") {
      Map<String, dynamic> data = await getQuestionById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Resource") {
      Map<String, dynamic> data = await getPostsOrResourcesById(
          context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context, screen: ThreadScreen(content: data));
    } else if (controlModel.notificationDetails!["subType"] == "Follow") {
      // Map<String, dynamic> data = await getPostsOrResourcesById(context, controlModel.notificationDetails!["paddyId"]);
      pushNewScreen(context,
          screen: OtherProfilePage(content: {
            "personId": controlModel.notificationDetails!["personId"]
          }));
    } else if (controlModel.notificationDetails!["type"] == "Message") {
      pushNewScreen(context, screen: MessagesScreen());
    }
    controlModel.clearNotificationDetails();
  }

  /// Real-time update of the number of upvotes, downvotes, e.t.c.
  setActionState(dynamic data) {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.setActionStream(data);
    controlModel.setActionUpdate(true);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > snackBarDuration;

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      toastMessage("Press back again to leave", context, seconds: 3);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    // UserChangeNotifierModel userModel = Provider.of<UserChangeNotifierModel>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: controller.index == 4
          ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
          : controller.index == 3
              ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
              : controller.index == 2
                  ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
                  : /* controller.index == 1
                      ? PreferredSize(
                          child: Container(), preferredSize: Size(0, 0))
                      : */
                  AppBar(
                      bottomOpacity: 0,
                      elevation: 0.0,
                      centerTitle: true,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0, top: 10),
                          child: IconButton(
                              icon: Badge(
                                position: BadgePosition.topEnd(end: 2),
                                badgeColor: colors.paddygreen,
                                badgeContent: unreadMessagesCount > 0
                                    ? textControl(
                                        (unreadMessagesCount).toString(),
                                        context,
                                        size: 7,
                                        color: colors.white)
                                    : null,
                                showBadge: showMessageBadge,
                                // showBadge: controlModel.showMessageBadge,
                                child: Icon(Icons.send),
                              ),
                              onPressed: () {
                                setState(() {
                                  unreadMessagesCount = 0;
                                  controlModel.setMessageBadge(false);
                                  showMessageBadge = false;
                                });
                                pushNewScreen(context,
                                        screen: MessagesScreen(),
                                        withNavBar: false)
                                    .then((value) => notificationCount());
                              },
                              color: colors.paddygreen,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints()),
                        )
                      ],
                      backgroundColor: colors.backgroundWhite,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      leadingWidth: 30,
                      leading: Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: IconButton(
                              icon: GetBuilder<CounterController>(
                                  init:
                                      CounterController(), // Init only the first time
                                  builder: (_) => Badge(
                                        // showBadge: counterController.notifCount
                                        //         .toInt() >
                                        //     0,
                                        showBadge:
                                            notifsCount > 0 ? true : false,
                                        badgeColor: colors.paddygreen,
                                        badgeContent: /* textControl(notifsCount.toString(), context, size: 7, color: colors.white), */
                                            GetBuilder<CounterController>(
                                                builder: (_) {
                                          return textControl(
                                              counterController.notifCount
                                                  .toString(),
                                              context,
                                              size: 7,
                                              color: colors.white);
                                        }),
                                        position:
                                            BadgePosition.topStart(start: -5),
                                        child: Icon(
                                            Icons.notifications_outlined,
                                            color: colors.darkGrey),
                                      )),
                              onPressed: () {
                                notifsCount = 0;
                                pushNewScreen(context,
                                    screen: NotificationsPage(),
                                    withNavBar: false);
                              },
                              tooltip: "Notifications",
                            ),
                          );
                        },
                      ),
                      title: InkWell(
                        onTap: () {
                          pushNewScreen(context,
                              screen: GlobalSearch(), withNavBar: false);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            child: CustomContainer(
                                height: getSize(context, 48),
                                child: Row(
                                  children: [
                                    SizedBox(width: getSize(context, 20)),
                                    SvgPicture.asset(
                                        "assets/svgs/search_icon.svg",
                                        height: 16),
                                    SizedBox(width: getSize(context, 10)),
                                    // textControl(controlModel.notificationDetails.toString(), context, color: colors.textGrey, fontWeight: FontWeight.w500)
                                    Expanded(
                                        child: textControl(
                                            "Search here at Student paddy...",
                                            context,
                                            color: colors.textGrey,
                                            fontWeight: FontWeight.w500,
                                            overflow: true))
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
      body: Builder(builder: (context) {
        return WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: Stack(
            children: [
              PersistentTabView(
                context,
                onItemSelected: (index) {
                  /* if (controller.index == 0 ) {
                    debug//  print("Going to top");
                    controlModel.setGoToFeedTop(true);
                  } else { */
                  setState(() {
                    controller.index = index;
                  });
                },
                // },
                backgroundColor: colors.blueColorOne,
                controller: controller,
                screens: buildScreens(),
                items: navBarsItems(),
                confineInSafeArea: true,
                resizeToAvoidBottomInset:
                    true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
                stateManagement: true, // Default is true.
                hideNavigationBarWhenKeyboardShows:
                    true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                navBarStyle: NavBarStyle
                    .style3, // Choose the nav bar style with this property.
                floatingActionButton: getFAB(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget getFAB(BuildContext context) {
    if (controller.index == 4) {
      return Container();
    } else
      return Padding(
        padding: EdgeInsets.zero,
        child: FloatingActionButton(
          heroTag: null,
          tooltip: "Quick Action",
          mini: false,
          backgroundColor: colors.blueColorOne,
          onPressed: () {
            setState(() {
              showFAB = false;
              quickActionModalBottomSheet2(context);
            });
          },
          child: Center(
            child: Icon(Icons.add, size: 35),
          ),
        ),
      );
  }

  List<Widget> buildScreens() {
    return [
      HomePage(),
      DubsPage(),
      CommunityPage(),
      TopicsPage(),
      AccountsPage()
    ];
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return [
      PersistentBottomNavBarItem(
        onSelectedTabPressWhenNoScreensPushed: () =>
            controlModel.setGoToFeedTop(true),
        icon: Icon(NavigationIcons.home, size: 20),
        // title: controller.index == 0 ? ("Home") : null,
        activeColorPrimary: colors.white,
        inactiveColorPrimary: colors.white.withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(NavigationIcons.dubs, size: 24),
        activeColorPrimary: colors.white,
        inactiveColorPrimary: colors.white.withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset("assets/svgs/community_icon.svg",
            color: controller.index == 2
                ? colors.white
                : colors.white.withOpacity(0.7),
            height: 16),
        // icon: Center(child: Align(alignment: Alignment.center, child: Icon(NavigationIcons.community, size: 16))),
        activeColorPrimary: colors.white,
        inactiveColorPrimary: colors.white.withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(NavigationIcons.topics, size: 20),
        activeColorPrimary: colors.white,
        inactiveColorPrimary: colors.white.withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(NavigationIcons.account, size: 20),
        activeColorPrimary: colors.white,
        inactiveColorPrimary: colors.white.withOpacity(0.7),
      ),
    ];
  }
}

// List<Widget> quickActionTypes(BuildContext context, {Function? onTap}) {
//   List<Widget> quickActionTypes = [];
//   quickActionTypes.add(itemContent(context, "Ask a Question", onTap: () {}));
//   quickActionTypes.add(itemContent(context, "Add a File", onTap: () {}));
//   quickActionTypes.add(itemContent(context, "Add a Resource", onTap: () {}));
//   quickActionTypes.add(itemContent(context, "Make a Post", onTap: () {}));
//   return quickActionTypes;
// }
