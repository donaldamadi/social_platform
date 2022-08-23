import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/community_screens/single_community.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';

import '../screens/navigator_screens/accounts_screens/profilePage.dart';
import '../screens/navigator_screens/internal_screens/other_profile_page.dart';
import '../screens/navigator_screens/internal_screens/thread_screen.dart';

class NavigatorController extends GetxController {
  @override
  void onInit() {
    initDynamicLinks();
    super.onInit();
  }

  Future<void> initDynamicLinks() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(Get.context!,
            listen: false);
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    /// `When app is terminated, or user just signs in/ signs up to app after clicking on dynamic link`
    PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    Uri? deepLink = data?.link;
    if (deepLink != null) {
      var list = deepLink.toString().split(".com/");
      var validList = list[1].split("/");
      print("=====================+> $validList");
      if (validList[0] == "post") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "resource") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "question") {
        Map<String, dynamic> data =
            await getQuestionById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "comment") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "profile") {
        if (validList[1] == userModel.id) {
          pushNewScreen(Get.context!, screen: ProfilePage());
        } else {
          pushNewScreen(Get.context!, screen: OtherProfilePage(content: {"_id": validList[1]}));
        }
      } else if (validList[0] == "topics") {
        Map<String, dynamic> data =
            await getTopicDetails(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: SingleTopic(content: data["data"]));
      } else if (validList[0] == "community") {
        Map<String, dynamic> data =
            await getCommunityDetails(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: SingleCommunity(content: data["data"]));
      } else if (validList[0] == "answer") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      }
    }

    /// `When user clicks on dynamic link while app is not terminated`
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      var list = dynamicLinkData.link.toString().split(".com/");
      var validList = list[1].split("/");
      print(validList);
      if (validList[0] == "post") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "resource") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "question") {
        Map<String, dynamic> data =
            await getQuestionById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "comment") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      } else if (validList[0] == "profile") {
        if (validList[1] == userModel.id) {
          pushNewScreen(Get.context!, screen: ProfilePage());
        } else {
          pushNewScreen(Get.context!, screen: OtherProfilePage(content: {"_id": validList[1]}));
        }
      } else if (validList[0] == "topics") {
        Map<String, dynamic> data =
            await getTopicDetails(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: SingleTopic(content: data["data"]));
      } else if (validList[0] == "community") {
        Map<String, dynamic> data =
            await getCommunityDetails(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: SingleCommunity(content: data["data"]));
      } else if (validList[0] == "answer") {
        Map<String, dynamic> data =
            await getPostsOrResourcesById(Get.context!, validList[1]);
        pushNewScreen(Get.context!, screen: ThreadScreen(content: data));
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }


  Future<void> retrieveDynamicLink(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    //  print(dynamicLinks.getInitialLink());
    // //  print(dynamicLinks.getDynamicLink(Uri.parse(dynamicLinks.getInitialLink.toString() ?? "")));
    try {
      //Called when app is terminated
      final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
      final Uri? deepLink = data?.link;
      if (deepLink.toString().contains("/login")) {
        if (userModel.token != null) logoutUser(context, userModel.token!);
        //  print("This is the link: ${deepLink?.queryParameters.toString()}");
        //  print("Other link: ${deepLink?.queryParameters}");
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
      }

      if (deepLink != null) {
        //  print("This is the link: ${deepLink.queryParameters.toString()}");
        //  print("Other link: ${deepLink.queryParameters}");
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
      }

      //Called when app is in background
      dynamicLinks.onLink.listen((event) {
        Uri link = event.link;
        //  print("Event: ${event.link}");
        if (link.toString().contains("/login")) {
          if (userModel.token != null) logoutUser(context, userModel.token!);
          //  print("This is the link: ${link.queryParameters.toString()}");
          //  print("Other link: ${link.queryParameters}");
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
        }
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
      });
    } catch (e) {
      //  print(e.toString());
    }
  }
}
