import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/image_viewer.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/measure_widget_size.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/shimmer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_communities.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_followers.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_following.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class OtherProfilePage extends StatefulWidget {
  OtherProfilePage({required this.content});

  final Map<String, dynamic> content;

  @override
  _OtherProfilePageState createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage>
    with SingleTickerProviderStateMixin {
  Size childSize = Size.zero;
  String? id;
  bool blacklisted = false;
  bool isLoading = false;
  bool isPostLoading = true;
  bool isQuestionLoading = true;
  bool isResourceLoading = true;
  bool isMorePostLoading = false;
  bool isMoreQuestionLoading = false;
  bool isMoreResourceLoading = false;
  List<dynamic> postList = [];
  int postPage = 1;
  ScrollController postScrollController = ScrollController();
  Map<String, dynamic> posts = {};
  int questionPage = 1;
  ScrollController questionScrollController = ScrollController();
  Map<String, dynamic> questions = {};
  List<dynamic> questionsList = [];
  int resourcePage = 1;
  ScrollController resourceScrollController = ScrollController();
  Map<String, dynamic> resources = {};
  List<dynamic> resourcesList = [];
  TabController? tabController;
  Map<String, dynamic> user = {};
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    isLoading = true;
    user = widget.content;
    tabController = TabController(length: 3, vsync: this);
    // getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUser();
      // userData = await getUserById(
      //     context,
      //     user["createdBy"] != null
      //         ? user["createdBy"]["_id"]
      //         : (user["userId"] != null ? user["userId"]["_id"] : user["_id"]));
      // //  print(userData["data"]);
      // if (userData["data"]["blacklisted"] == true)
      //   setState(() {
      //     blacklisted = true;
      //   });
      // setState(() {
      //   isLoading = false;
      // });
      //  print(tabController?.index);
      if (tabController?.index == 0) {
        if (posts.isEmpty) getPosts(context);
      } else if (tabController?.index == 1) {
        if (questions.isEmpty) getQuestions(context);
      } else if (tabController?.index == 2) {
        if (resources.isEmpty) getResources(context);
      }
      tabController?.addListener(() {
        if (tabController!.indexIsChanging) {
          if (tabController?.index == 0) {
            if (posts.isEmpty) getPosts(context);
          } else if (tabController?.index == 1) {
            if (questions.isEmpty) getQuestions(context);
          } else if (tabController?.index == 2) {
            if (resources.isEmpty) getResources(context);
          }
        }
      });
      tabController!.animation
      ?..addListener(() {
        if (tabController!.indexIsChanging) {
          if (tabController?.index == 0) {
            if (posts.isEmpty) getPosts(context);
          } else if (tabController?.index == 1) {
            if (questions.isEmpty) getQuestions(context);
          } else if (tabController?.index == 2) {
            if (resources.isEmpty) getResources(context);
          }
        }
      });
      postScrollController.addListener(() {
        if (postScrollController.position.pixels ==
            postScrollController.position.maxScrollExtent) {
          postPage++;
          if (postList.length < posts["total"]) {
            getPosts(context, moreData: true);
          }
        }
      });
      questionScrollController.addListener(() {
        if (questionScrollController.position.pixels ==
            questionScrollController.position.maxScrollExtent) {
          questionPage++;
          if (questionsList.length < questions["total"]) {
            getQuestions(context, moreData: true);
          }
        }
      });
      resourceScrollController.addListener(() {
        if (resourceScrollController.position.pixels ==
            resourceScrollController.position.maxScrollExtent) {
          resourcePage++;
          if (resourcesList.length < resources["total"]) {
            getResources(context, moreData: true);
          }
        }
      });
    });
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    userData = await getUserById(
      context,
      user["createdBy"] != null
          ? user["createdBy"]["_id"]
          : (user["userId"] != null
              ? user["userId"]["_id"]
              : user["_id"] == null
                  ? user["personId"]
                  : user["_id"]),
    );
    //  print(userData["data"]);
    if (userData["data"]["blacklisted"] == true)
      setState(() {
        blacklisted = true;
      });
    setState(() {
      isLoading = false;
    });
    // userData = await getUserById(
    //     context,
    //     user["createdBy"] != null
    //         ? user["createdBy"]["_id"]
    //         : (user["userId"] != null ? user["userId"]["_id"] : user["_id"]));
    // log(userData.toString());
    // //  print(user["createdBy"]!=null?user["createdBy"]["_id"]:user["_id"]);
    // setState(() {
    //   isLoading = false;
    // });
    // //  print(userData["data"]["profilepic"].substring(
    //     userData["data"]["profilepic"].toString().lastIndexOf(".") + 1,
    //     userData["data"]["profilepic"].toString().length));
  }

  follow() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (userData["data"]["followers"].contains(userModel.id)) {
      setState(() {
        userData["data"]["followers"].remove(userModel.id);
        userModel.userData!["data"]["following"]
            .remove(userData["data"]["_id"]);
      });
      await followUser(context, {"action": "undo"}, userData["data"]["_id"]);
      userModel.setUpdatedResult(true);
    } else {
      setState(() {
        userData["data"]["followers"].add(userModel.id);
        userModel.userData!["data"]["following"].add(userData["data"]["_id"]);
      });
      await followUser(context, {"action": "follow"}, userData["data"]["_id"]);
      userModel.setUpdatedResult(true);
    }
  }

  getPosts(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isPostLoading = true;
      });
    } else {
      setState(() {
        isMorePostLoading = true;
      });
    }
    posts = await getUserPosts(context, {}, userData["data"]["_id"], postPage);
    //  print(posts);
    postList.addAll(posts['data']);
    setState(() {
      isPostLoading = false;
      isMorePostLoading = false;
    });
  }

  getQuestions(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isQuestionLoading = true;
      });
    } else {
      setState(() {
        isMoreQuestionLoading = true;
      });
    }
    questions = await getUserQuestions(
        context, {}, userData["data"]["_id"], questionPage);
    questionsList.addAll(questions['data']);
    //  print(questionsList);
    setState(() {
      isQuestionLoading = false;
      isMoreQuestionLoading = false;
    });
  }

  getResources(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isResourceLoading = true;
      });
    } else {
      setState(() {
        isMoreResourceLoading = true;
      });
    }
    resources = await getUserResources(
        context, {}, userData["data"]["_id"], resourcePage);
    resourcesList.addAll(resources['data']);
    setState(() {
      isResourceLoading = false;
      isMoreResourceLoading = false;
    });
  }

  unblock() async {
    setState(() {
      isLoading = true;
    });
    await unblockUser(context, userData["data"]["_id"]);
    setState(() {
      isLoading = false;
    });
    getUser();
    // Navigator.pop(context);
  }

  shareProfileLink() {
    Share.share("https://www.instagram.com/p/B_Z-_xgBXZ/?igshid=1hxqzqzqzqzqz");
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      body: isLoading
          ? loaderMain(context, status: true, color: colors.paddygreen)
          : DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (context, value) {
                  return [
                    SliverAppBar(
                      iconTheme: IconThemeData(color: colors.blueColorOne),
                      pinned: true,
                      floating: true,
                      snap: false,
                      backgroundColor: colors.backgroundWhite,
                      expandedHeight: childSize.height == 0
                          ? 600
                          : childSize.height +
                              (Platform.isIOS
                                  ? 265
                                  : (getWidth(context) > 400 ? 285 : 260)),
                      // (getWidth(context) < 400
                      //     ? Platform.isIOS
                      //         ? 270
                      //         : 400
                      //     : 280),
                      shadowColor: colors.paddygreen,
                      flexibleSpace: Container(
                        color: Colors.transparent,
                        child: FlexibleSpaceBar(
                          background: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: getSize(context, 250),
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => pushNewScreen(context,
                                          screen: ImageViewer(
                                              imageUrl: userData['data']
                                                      ['backgroundPic'] ??
                                                  ""),
                                          withNavBar: false),
                                      child: Container(
                                        height: getSize(context, 200),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                userData["data"]
                                                        ["backgroundPic"] ??
                                                    "",
                                              ),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: GestureDetector(
                                        onTap: () => pushNewScreen(context,
                                            screen: ImageViewer(
                                                imageUrl: userData["data"] ==
                                                        null
                                                    ? ""
                                                    : userData['data']
                                                            ['profilepic'] ??
                                                        ""),
                                            withNavBar: false),
                                        child: Container(
                                          clipBehavior: Clip.none,
                                          width: getSize(context, 100),
                                          height: getSize(context, 100),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 5,
                                                  color:
                                                      colors.backgroundWhite),
                                              shape: BoxShape.circle,
                                              image: userData["data"]
                                                              ["profilepic"]
                                                          .substring(
                                                              userData["data"][
                                                                          "profilepic"]
                                                                      .toString()
                                                                      .lastIndexOf(
                                                                          ".") +
                                                                  1,
                                                              userData["data"][
                                                                      "profilepic"]
                                                                  .toString()
                                                                  .length) ==
                                                      "svg"
                                                  ? DecorationImage(
                                                      image: AssetImage(
                                                          "assets/pngs/profile_icon.png"))
                                                  : DecorationImage(
                                                      image: NetworkImage(
                                                        userData["data"]
                                                            ["profilepic"],
                                                      ),
                                                      fit: BoxFit.cover)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              MeasureSize(
                                onChange: (size) {
                                  childSize = size;
                                  //  print(childSize.height);
                                  setState(() {});
                                },
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: getSize(context, 20)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: getSize(context, 60),
                                          width: getWidth(context),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: textControl(
                                                      userData["data"][
                                                                  "firstname"] ==
                                                              null
                                                          ? ""
                                                          : "${userData["data"]["firstname"] + " " + userData["data"]["lastname"]}",
                                                      context,
                                                      size: 18,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              PopupMenuButton(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                ),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    child: Text(
                                                        "Share Profile Link"),
                                                    value: 1,
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 1) {
                                                    shareProfileLink();
                                                  }
                                                },
                                              ),
                                              blacklisted
                                                  ? SizedBox()
                                                  : userData["data"]
                                                              ["blacklistedBy"]
                                                          .contains(
                                                              userModel.id)
                                                      ? CustomButton(
                                                          width: 80,
                                                          height: 30,
                                                          textSize: 12,
                                                          text: "Unblock",
                                                          onPressed: () =>
                                                              unblock(),
                                                          buttonColor:
                                                              Color(0xFFFF0000))
                                                      : CustomButton(
                                                          text: userData["data"][
                                                                      "followers"]
                                                                  .contains(
                                                                      userModel
                                                                          .id)
                                                              ? "Following"
                                                              : "Follow",
                                                          onPressed: () =>
                                                              follow(),
                                                          width: 80,
                                                          height: 30,
                                                          textSize: 12,
                                                          buttonColor:
                                                              colors.paddygreen,
                                                          buttonType: userData[
                                                                          "data"]
                                                                      ["followers"]
                                                                  .contains(userModel.id)
                                                              ? ButtonType.one
                                                              : ButtonType.two)
                                            ],
                                          ),
                                        ),
                                        blacklisted
                                            ? textControl(
                                                "You've been blocked by this user",
                                                context,
                                                color: Color(0xFFFF0000))
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  textControl(
                                                      "@${userData["data"]["username"].toString()}",
                                                      context,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 5)),
                                                  textControl(
                                                      ((userData["data"]["bio"] ==
                                                                          null ||
                                                                      userData["data"]
                                                                              [
                                                                              "bio"] ==
                                                                          "")
                                                                  ? "No bio"
                                                                  : userData[
                                                                          "data"]
                                                                      ["bio"])
                                                              .replaceAll(
                                                                  "\n", " ") ??
                                                          "",
                                                      context,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      spacing: 0,
                                                      wordSpacing: 0),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 5)),
                                                  userData["data"][
                                                              "academic_status"] ==
                                                          null
                                                      ? SizedBox()
                                                      : textControl(
                                                          "${userData["data"]["academic_status"].toString().capitalizeString()} '${userData["data"]["graduation_year"] != null ? userData["data"]["graduation_year"].substring(2, 4) : ""}",
                                                          context,
                                                          color: colors.textBlue
                                                              .withOpacity(
                                                                  0.85),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          size: 16),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 5)),
                                                  userData["data"]
                                                              ["institution"] ==
                                                          null
                                                      ? SizedBox()
                                                      : Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                              // Icon(Icons.location_on, size: 14),
                                                              // SizedBox(width: getSize(context, 5)),
                                                              // textControl("Lagos, Nigeria", context, fontWeight: FontWeight.w500),
                                                              // SizedBox(width: getSize(context, 15)),
                                                              Image.asset(
                                                                  "assets/pngs/grad_cap.png",
                                                                  height: 14,
                                                                  color: Colors
                                                                      .black),
                                                              SizedBox(
                                                                  width: getSize(
                                                                      context,
                                                                      5)),
                                                              textControl(
                                                                  userData["data"]
                                                                          [
                                                                          "institution"] ??
                                                                      "",
                                                                  context,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200),
                                                            ]),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 5)),
                                                  userData["data"]["faculty"] ==
                                                          null
                                                      ? SizedBox()
                                                      : Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/svgs/book.svg",
                                                                height: 12),
                                                            SizedBox(
                                                                width: getSize(
                                                                    context,
                                                                    5)),
                                                            textControl(
                                                                "Faculty of ${userData["data"]["faculty"]}",
                                                                context,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200),
                                                          ],
                                                        ),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 5)),
                                                  userData["data"]
                                                              ["department"] ==
                                                          null
                                                      ? SizedBox()
                                                      : Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/svgs/book.svg",
                                                                height: 12),
                                                            SizedBox(
                                                                width: getSize(
                                                                    context,
                                                                    5)),
                                                            Expanded(
                                                                child: textControl(
                                                                    "Department of ${userData["data"]["department"]}",
                                                                    context,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200)),
                                                          ],
                                                        ),
                                                  Container(
                                                      height:
                                                          getSize(context, 60),
                                                      width: getWidth(context),
                                                      child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            textControl(
                                                                "Skills  -  ",
                                                                context,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                            Expanded(
                                                              child: textControl(
                                                                  (userData["data"]["skill_sets"] !=
                                                                              null &&
                                                                          userData["data"]["skill_sets"]
                                                                              .isNotEmpty)
                                                                      ? userData["data"]
                                                                              [
                                                                              "skill_sets"]
                                                                          .join(
                                                                              ', ')
                                                                      : "No skills",
                                                                  context,
                                                                  color: colors
                                                                      .textBlue
                                                                      .withOpacity(
                                                                          0.85),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                          ])),
                                                  SizedBox(
                                                      height:
                                                          getSize(context, 10)),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () => pushNewScreen(
                                                              context,
                                                              screen: ProfileFollowingPage(
                                                                  userId: userData[
                                                                          "data"]
                                                                      ["_id"])),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                textControl(
                                                                    "${userData["data"]["following"].length} ",
                                                                    context),
                                                                textControl(
                                                                    "Following",
                                                                    context,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () => pushNewScreen(
                                                              context,
                                                              screen: ProfileFollowersPage(
                                                                  userId: userData[
                                                                          "data"]
                                                                      ["_id"])),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                textControl(
                                                                    "${userData["data"]["followers"].length} ",
                                                                    context),
                                                                textControl(
                                                                    userData["data"]["followers"].length ==
                                                                            1
                                                                        ? "Follower"
                                                                        : "Followers",
                                                                    context,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () => pushNewScreen(
                                                              context,
                                                              screen: ProfileCommunities(
                                                                  userId: userData[
                                                                          "data"]
                                                                      ["_id"])),
                                                          child: Row(
                                                            children: [
                                                              textControl(
                                                                  "${userData["data"]["community"].length} ",
                                                                  context),
                                                              textControl(
                                                                  userData["data"]["community"]
                                                                              .length ==
                                                                          1
                                                                      ? "Community"
                                                                      : "Communities",
                                                                  context,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200),
                                                            ],
                                                          ),
                                                        ),
                                                      ]),
                                                  // SizedBox(height: getSize(context, 20))
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          collapseMode: CollapseMode.pin,
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size(
                          Get.width,
                          getSize(context, 50),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color:
                                          colors.paddygreen.withOpacity(0.5)))),
                          child: TabBar(
                            labelPadding: EdgeInsets.symmetric(horizontal: 30),
                            isScrollable: true,
                            controller: tabController,
                            labelColor: colors.paddygreen,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(text: "Post"),
                              Tab(text: "Q & A"),
                              Tab(text: "Resources"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: tabController,
                  children: [
                    isPostLoading
                        ? ShimmerWidget(count: 3)
                        : postList.length < 1
                            ? EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      controller: postScrollController,
                                      //physics: BouncingScrollPhysics(),
                                      itemCount: postList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: getSize(context, 20),
                                              vertical: 10),
                                          child: Column(
                                            children: [
                                              PostWidget(
                                                  content: postList[index]),
                                              SizedBox(height: 10),
                                              divider(context)
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  isMorePostLoading
                                      ? loaderMain(context,
                                          status: true,
                                          size: getSize(context, 20),
                                          height: 50)
                                      : SizedBox()
                                ],
                              ),
                    isQuestionLoading
                        ? ShimmerWidget(count: 3)
                        : questionsList.length < 1
                            ? EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      controller: questionScrollController,
                                      //physics: BouncingScrollPhysics(),
                                      itemCount: questionsList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: getSize(context, 20),
                                              vertical: 10),
                                          child: Column(
                                            children: [
                                              questionsList[index]["type"] ==
                                                      "Question"
                                                  ? QuestionWidget(
                                                      content:
                                                          questionsList[index],
                                                      isOnProfilePage: true)
                                                  : questionsList[index]
                                                              ["type"] ==
                                                          "Answer"
                                                      ? AnswerWidget(
                                                          content:
                                                              questionsList[
                                                                  index],
                                                          isOnProfilePage: true)
                                                      : SizedBox(),
                                              SizedBox(height: 10),
                                              divider(context),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  isMoreQuestionLoading
                                      ? loaderMain(context,
                                          status: true,
                                          size: getSize(context, 20),
                                          height: 50)
                                      : SizedBox()
                                ],
                              ),
                    isResourceLoading
                        ? ShimmerWidget(count: 3)
                        : resourcesList.length < 1
                            ? EmptyState()
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      controller: resourceScrollController,
                                      //physics: BouncingScrollPhysics(),
                                      itemCount: resourcesList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: getSize(context, 20),
                                              vertical: 10),
                                          child: Column(
                                            children: [
                                              ResourceWidget(
                                                  content:
                                                      resourcesList[index]),
                                              SizedBox(height: 10),
                                              divider(context)
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  isMoreResourceLoading
                                      ? loaderMain(context,
                                          status: true,
                                          size: getSize(context, 20),
                                          height: 50)
                                      : SizedBox()
                                ],
                              ),
                  ],
                ),
              ),
            ),
    );
  }
}
