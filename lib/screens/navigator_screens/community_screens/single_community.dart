import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/shimmer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/topic_widget.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/community_screens/community_followers.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/community_screens/contributors_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

import '../../../components/answer_widget.dart';
import '../../../network/data.dart';

class SingleCommunity extends StatefulWidget {
  final Map<String, dynamic> content;
  SingleCommunity({required this.content});

  @override
  _SingleCommunityState createState() => _SingleCommunityState();
}

class _SingleCommunityState extends State<SingleCommunity>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  bool isLoading = false;
  bool isPostLoading = true;
  bool isQuestionsLoading = true;
  bool isResourcesLoading = true;
  bool isTopicsLoading = true;
  bool isMorePostLoading = false;
  bool isMoreQuestionsLoading = false;
  bool isMoreResourcesLoading = false;
  bool isMoreTopicsLoading = false;
  Map<String, dynamic> posts = {};
  Map<String, dynamic> questions = {};
  Map<String, dynamic> resources = {};
  Map<String, dynamic> topics = {};
  Map<String, dynamic> userData = {};
  List<dynamic> postList = [];
  List<dynamic> questionList = [];
  List<dynamic> resourceList = [];
  List<dynamic> topicList = [];
  int postPage = 1;
  int questionPage = 1;
  int resourcePage = 1;
  int topicPage = 1;
  ScrollController postController = ScrollController();
  ScrollController questionsController = ScrollController();
  ScrollController resourcesController = ScrollController();
  ScrollController topicsController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUser();
      if (tabController?.index == 0) {
        if (posts.isEmpty) getPosts(context);
      } else if (tabController?.index == 1) {
        if (questions.isEmpty) getQuestions(context);
      } else if (tabController?.index == 2) {
        if (resources.isEmpty) getResources(context);
      } else if (tabController?.index == 3) {
        if (topics.isEmpty) getCommunityTopics(context);
      }
      tabController?.addListener(() {
        if (tabController?.index == 0) {
          if (posts.isEmpty) getPosts(context);
        } else if (tabController?.index == 1) {
          if (questions.isEmpty) getQuestions(context);
        } else if (tabController?.index == 2) {
          if (resources.isEmpty) getResources(context);
        } else if (tabController?.index == 3) {
          if (topics.isEmpty) getCommunityTopics(context);
        }
      });
      postController.addListener(() {
        if (postController.position.pixels ==
            postController.position.maxScrollExtent) {
          if (postList.length < posts['total']) {
            postPage++;
            getPosts(context, moreData: true);
          }
        }
      });
      questionsController.addListener(() {
        if (questionsController.position.pixels ==
            questionsController.position.maxScrollExtent) {
          if (questionList.length < questions['total']) {
            // questionPage++;
            // getQuestions(context, moreData: true);
          }
        }
      });
      resourcesController.addListener(() {
        if (resourcesController.position.pixels ==
            resourcesController.position.maxScrollExtent) {
          if (resourceList.length < resources['total']) {
            resourcePage++;
            getResources(context, moreData: true);
          }
        }
      });
      topicsController.addListener(() {
        if (topicsController.position.pixels ==
            topicsController.position.maxScrollExtent) {
          if (topicList.length < topics['total']) {
            topicPage++;
            getCommunityTopics(context, moreData: true);
          }
        }
      });
    });
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    userData = await getCommunity(context, widget.content["name"], "", 1);
    log(userData.toString());
    setState(() {
      isLoading = false;
    });
  }

  follow() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (widget.content["followers"].contains(userModel.id)) {
      setState(() {
        widget.content["followers"].remove(userModel.id);
      });
      followUnfollowCommunity(
          context, widget.content["name"], {"action": "unfollow"});
      userModel.setUpdatedResult(true);
    } else {
      setState(() {
        widget.content["followers"].add(userModel.id);
      });
      followUnfollowCommunity(
          context, widget.content["name"], {"action": "follow"});
      userModel.setUpdatedResult(true);
    }
  }

  getPosts(BuildContext context, {bool moreData = false}) async {
    // debugPrint(
        // "=================================+> Gettinng posts ${DateTime.now()}");
    if (moreData == false) {
      setState(() {
        isPostLoading = true;
      });
    } else {
      setState(() {
        // debugPrint("=====================More Data=====================");
        isMorePostLoading = true;
      });
    }
    posts =
        await getCommunity(context, widget.content["name"], "posts", postPage);
    if (moreData == true) {
      postList.addAll(posts["data"]);
    } else {
      postList = posts["data"];
    }
    setState(() {
      isPostLoading = false;
      isMorePostLoading = false;
    });
  }

  getQuestions(BuildContext context, {bool moreData = false}) async {
    // debugPrint(
        // "=================================+> Gettinng questions ${DateTime.now()}");
    if (moreData == false) {
      setState(() {
        isQuestionsLoading = true;
      });
    } else {
      setState(() {
        isMoreQuestionsLoading = true;
      });
    }
    questions = await getCommunity(
        context, widget.content["name"], "questions", questionPage);
    questionList.addAll(questions["data"]);
    if (moreData == true) {
      questionList.addAll(questions["data"]);
    } else {
      questionList = questions["data"];
    }
    setState(() {
      isQuestionsLoading = false;
      isMoreQuestionsLoading = false;
    });
  }

  getResources(BuildContext context, {bool moreData = false}) async {
    // debugPrint(
        // "=================================+> Gettinng resources ${DateTime.now()}");
    if (moreData == false) {
      setState(() {
        isResourcesLoading = true;
      });
    } else {
      setState(() {
        isMoreResourcesLoading = true;
      });
    }
    resources = await getCommunity(
        context, widget.content["name"], "resources", resourcePage);
    if (moreData == true) {
      resourceList.addAll(resources["data"]);
    } else {
      resourceList = resources["data"];
    }
    // resourceList.toSet().addAll(resources["data"]);
    // resourceList = resourceList.toList();
    setState(() {
      isResourcesLoading = false;
      isMoreResourcesLoading = false;
    });
  }

  getCommunityTopics(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isTopicsLoading = true;
      });
    } else {
      setState(() {
        isMoreTopicsLoading = true;
      });
    }
    topics = await getCommunity(
        context, widget.content["name"], "topics", topicPage);
    //  print(topics);
    if (moreData == true) {
      topicList.addAll(topics["data"]);
    } else {
      topicList = topics["data"];
    }
    //  print(topicList);
    setState(() {
      isTopicsLoading = false;
      isMoreTopicsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Quick Action",
        mini: false,
        backgroundColor: colors.blueColorOne,
        onPressed: () {
          setState(() {
            // showFAB = false;
            quickActionModalBottomSheet2(context);
          });
        },
        child: Center(
          child: Icon(Icons.add, size: 35),
        ),
      ),
      body: isLoading
          ? loaderMain(context, status: true, color: colors.paddygreen)
          : DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder: (context, value) {
                  return [
                    SliverAppBar(
                      // iconTheme: IconThemeData(color: Colors.black),
                      pinned: true,
                      floating: true,
                      snap: false,
                      backgroundColor: colors.backgroundWhite,
                      expandedHeight: getSize(context, 450),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: getSize(context, 200),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          widget.content["communityPicture"] ??
                                              userData["data"]
                                                  ["communityPicture"] ??
                                              ""),
                                      fit: BoxFit.cover)),
                            ),
                            SizedBox(height: getSize(context, 30)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: getSize(context, 40),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: textControl(
                                            widget.content["name"], context,
                                            size: 16,
                                            fontWeight: FontWeight.w800)),
                                    SizedBox(width: getSize(context, 5)),
                                    GestureDetector(
                                      onTap: () => Share.share(
                                          "$baseUrl/topics/${widget.content["name"].toString().replaceAll(" ", "%20")}"),
                                      child: SvgPicture.asset(
                                          "assets/svgs/curved_arrow.svg"),
                                    ),
                                    SizedBox(width: getSize(context, 20)),
                                    CustomButton(
                                      text: widget.content["followers"] != null
                                          ? widget.content["followers"]
                                                  .contains(userModel.id)
                                              ? "Following"
                                              : "Follow"
                                          : userData["data"]["followers"]
                                                  .contains(userModel.id)
                                              ? "Following"
                                              : "Follow",
                                      onPressed: () => follow(),
                                      width: 80,
                                      height: 30,
                                      textSize: 12,
                                      buttonType:
                                          widget.content["followers"] != null
                                              ? widget.content["followers"]
                                                      .contains(userModel.id)
                                                  ? ButtonType.one
                                                  : ButtonType.two
                                              : userData["data"]["followers"]
                                                      .contains(userModel.id)
                                                  ? ButtonType.one
                                                  : ButtonType.two,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: getSize(context, 20)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: textControl(
                                widget.content["description"] ?? "",
                                context,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: getSize(context, 20)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  textControl(
                                      userData["data"]["contributorslen"]
                                          .toString(),
                                      context),
                                  // SizedBox(width: getSize(context, 5)),
                                  InkWell(
                                    onTap: () {
                                      pushNewScreen(context,
                                          screen: ContributorsPage(
                                              name: widget.content["name"]),
                                          withNavBar: false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: textControl(
                                          userData["data"]["contributorslen"] ==
                                                  1
                                              ? "Contributor"
                                              : "Contributors",
                                          context,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(width: getSize(context, 15)),
                                  textControl(
                                      userData["data"]["followersLen"]
                                          .toString(),
                                      context),
                                  // SizedBox(width: getSize(context, 5)),
                                  InkWell(
                                    onTap: () {
                                      pushNewScreen(context,
                                          screen: CommunityFollowers(
                                              community:
                                                  widget.content["name"]),
                                          withNavBar: false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: textControl(
                                          userData["data"]["followersLen"] == 1
                                              ? "Followers"
                                              : "Followers",
                                          context,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        collapseMode: CollapseMode.pin,
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
                              Tab(text: "Posts"),
                              Tab(text: "Q & A"),
                              Tab(text: "Resources"),
                              Tab(text: "Topics"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(controller: tabController, children: [
                  isPostLoading
                      ? ShimmerWidget(count: 3)
                      : postList.length < 1
                          ? EmptyState()
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: postController,
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
                                    : Container(),
                              ],
                            ),
                  isQuestionsLoading
                      ? ShimmerWidget(count: 3)
                      : questionList.length < 1
                          ? EmptyState()
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: questionsController,
                                    //physics: BouncingScrollPhysics(),
                                    itemCount: questionList.length,
                                    itemBuilder: (context, index) {
                                      // debugPrint(questionList[0].toString(),
                                          // wrapWidth: 500);
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getSize(context, 20),
                                            vertical: 10),
                                        child: Column(
                                          children: [
                                            questionList[index]["type"] ==
                                                    "Question"
                                                ? QuestionWidget(
                                                    content:
                                                        questionList[index])
                                                : AnswerWidget(
                                                    content:
                                                        questionList[index]),
                                            SizedBox(height: 10),
                                            divider(context)
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                isMoreQuestionsLoading
                                    ? loaderMain(context,
                                        status: true,
                                        size: getSize(context, 20),
                                        height: 50)
                                    : Container(),
                              ],
                            ),
                  isResourcesLoading
                      ? ShimmerWidget(count: 3)
                      : resourceList.length < 1
                          ? EmptyState()
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: resourcesController,
                                    //physics: BouncingScrollPhysics(),
                                    itemCount: resourceList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getSize(context, 20),
                                            vertical: 10),
                                        child: Column(
                                          children: [
                                            ResourceWidget(
                                                content: resourceList[index]),
                                            SizedBox(height: 10),
                                            divider(context)
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                isMoreResourcesLoading
                                    ? loaderMain(context,
                                        status: true,
                                        size: getSize(context, 20),
                                        height: 50)
                                    : Container(),
                              ],
                            ),
                  isTopicsLoading
                      ? ShimmerWidget(count: 3)
                      : topicList.length < 1
                          ? EmptyState()
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: topicsController,
                                    //physics: BouncingScrollPhysics(),
                                    itemCount: topicList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getSize(context, 20),
                                            vertical: 10),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            TopicWidget(
                                                content: topicList[index]),
                                            divider(context)
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                isMoreTopicsLoading
                                    ? loaderMain(context,
                                        status: true,
                                        size: getSize(context, 20),
                                        height: 50)
                                    : Container(),
                              ],
                            ),
                ]),
              ),
            ),
    );
  }
}
