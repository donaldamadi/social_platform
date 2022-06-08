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
import 'package:student_paddy_mobile/network/data.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

import '../../components/answer_widget.dart';

class SingleTopic extends StatefulWidget {
  @override
  _SingleTopicState createState() => _SingleTopicState();

  final Map<String, dynamic> content;
  SingleTopic({required this.content});
}

class _SingleTopicState extends State<SingleTopic>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  bool isLoading = false;
  bool isPostLoading = true;
  bool isQuestionLoading = true;
  bool isResourcesLoading = true;
  bool isContributorsLoading = true;
  bool isMorePostLoading = false;
  bool isMoreQuestionsLoading = false;
  bool isMoreResourcesLoading = false;
  bool isMoreContributorsLoading = false;
  bool isMoreTopicsLoading = false;
  Map<String, dynamic> posts = {};
  Map<String, dynamic> questions = {};
  Map<String, dynamic> resources = {};
  Map<String, dynamic> contributors = {};
  Map<String, dynamic> topicDetails = {};
  List<dynamic> postList = [];
  List<dynamic> questionList = [];
  List<dynamic> resourceList = [];
  List<dynamic> contributorList = [];
  int postPage = 1;
  int questionPage = 1;
  int resourcePage = 1;
  int contributorsPage = 1;
  ScrollController postController = ScrollController();
  ScrollController questionsController = ScrollController();
  ScrollController resourceController = ScrollController();
  ScrollController contributorController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    getDetailsOfTopic();
    // tabController.addListener(height);
    log(widget.content.toString());
    widget.content["followers"] = widget.content["followers"] ?? [];
    //  print(widget.content["name"]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getUser();
      if (tabController?.index == 0) {
        if (posts.isEmpty) getPosts(context);
      } else if (tabController?.index == 1) {
        if (questions.isEmpty) getQuestions(context);
      } else if (tabController?.index == 2) {
        if (resources.isEmpty) getResources(context);
      } else if (tabController?.index == 3) {
        if (contributors.isEmpty) getContributors(context);
      }
      tabController?.addListener(() {
        if (tabController!.indexIsChanging) {
          if (tabController?.index == 0) {
            if (posts.isEmpty) getPosts(context);
          } else if (tabController?.index == 1) {
            if (questions.isEmpty) getQuestions(context);
          } else if (tabController?.index == 2) {
            if (resources.isEmpty) getResources(context);
          } else if (tabController?.index == 3) {
            if (contributors.isEmpty) getContributors(context);
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
            } else if (tabController?.index == 3) {
              if (contributors.isEmpty) getContributors(context);
            }
          }
        });
      postController.addListener(() {
        if (postController.position.pixels ==
            postController.position.maxScrollExtent) {
          if (postList.length < posts["total"]) {
            postPage++;
            getPosts(context, moreData: true);
          }
        }
      });
      questionsController.addListener(() {
        if (questionsController.position.pixels ==
            questionsController.position.maxScrollExtent) {
          if (questionList.length < questions["total"]) {
            questionPage++;
            getQuestions(context, moreData: true);
          }
        }
      });
      resourceController.addListener(() {
        if (resourceController.position.pixels ==
            resourceController.position.maxScrollExtent) {
          if (resourceList.length < resources["total"]) {
            resourcePage++;
            getResources(context, moreData: true);
          }
        }
      });
      contributorController.addListener(() {
        if (contributorController.position.pixels ==
            contributorController.position.maxScrollExtent) {
          if (contributorList.length < contributors["total"]) {
            contributorsPage++;
            getContributors(context, moreData: true);
          }
        }
      });
    });
  }

  getDetailsOfTopic() async {
    setState(() {
      isLoading = true;
    });
    topicDetails = await getTopicDetails(context, widget.content["name"]);
    setState(() {
      isLoading = false;
    });
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
    posts = await getTopic(context, widget.content["name"], "posts", postPage);
    postList.addAll(posts["data"]);
    setState(() {
      isMorePostLoading = false;
      isPostLoading = false;
    });
  }

  getQuestions(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isQuestionLoading = true;
      });
    } else {
      setState(() {
        isMoreQuestionsLoading = true;
      });
    }
    questions = await getTopic(
        context, widget.content["name"], "questions", questionPage);
    questionList.addAll(questions["data"]);
    setState(() {
      isMoreQuestionsLoading = false;
      isQuestionLoading = false;
    });
  }

  getResources(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isResourcesLoading = true;
      });
    } else {
      setState(() {
        isMoreResourcesLoading = true;
      });
    }
    resources = await getTopic(
        context, widget.content["name"], "resources", resourcePage);
    resourceList.addAll(resources["data"]);
    //  print(resourceList.length);
    setState(() {
      isResourcesLoading = false;
      isMoreResourcesLoading = false;
    });
  }

  getContributors(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isContributorsLoading = true;
      });
    } else {
      setState(() {
        isMoreTopicsLoading = true;
      });
    }
    contributors = await getTopic(
        context, widget.content["name"], "contributors", contributorsPage);
    contributorList.addAll(contributors["data"]);
    //  print(contributorList.length);
    setState(() {
      isMoreContributorsLoading = false;
      isContributorsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      body: isLoading
          ? loaderMain(context, status: true, size: 40)
          : SafeArea(
              child: Container(
                color: colors.backgroundWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textControl(widget.content["name"], context,
                                  size: 15),
                              Row(
                                children: [
                                  textControl("Followers", context,
                                      color: colors.textBlue,
                                      fontWeight: FontWeight.w400,
                                      size: 13),
                                  SizedBox(width: getSize(context, 5)),
                                  textControl(
                                      widget.content["followers"] != null
                                          ? widget.content["followers"].length
                                              .toString()
                                          : topicDetails["data"]["followersLen"]
                                              .toString(),
                                      context,
                                      fontWeight: FontWeight.w500,
                                      size: 13)
                                ],
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                            onTap: () => Share.share(
                                "$baseUrl/topics/${topicDetails["data"]["name"].toString().replaceAll(" ", "%20")}"),
                            child: SvgPicture.asset(
                                "assets/svgs/curved_arrow.svg")),
                        SizedBox(width: getSize(context, 20)),
                        CustomButton(
                          text: widget.content["followers"] != null
                              ? widget.content["followers"]
                                      .contains(userModel.id)
                                  ? "Following"
                                  : "Follow"
                              : [].contains(userModel.id)
                                  ? "Following"
                                  : "Follow",
                          onPressed: () {
                            setState(() {
                              if (widget.content["followers"]
                                  .contains(userModel.id)) {
                                widget.content["followers"]
                                    .remove(userModel.id);
                                followUnfollowTopic(
                                    context,
                                    widget.content["name"],
                                    {"action": "unfollow"});
                                quickUserData(context);
                              } else {
                                widget.content["followers"].add(userModel.id);
                                followUnfollowTopic(
                                    context,
                                    widget.content["name"],
                                    {"action": "follow"});
                                quickUserData(context);
                              }
                            });
                          },
                          width: 80,
                          height: 30,
                          textSize: 12,
                          buttonType: widget.content["followers"] != null
                              ? widget.content["followers"]
                                      .contains(userModel.id)
                                  ? ButtonType.one
                                  : ButtonType.two
                              : [].contains(userModel.id)
                                  ? ButtonType.one
                                  : ButtonType.two,
                        )
                      ]),
                    ),
                    SizedBox(height: getSize(context, 20)),
                    Container(
                      height: 45,
                      child: PreferredSize(
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
                              Tab(text: "Questions"),
                              Tab(text: "Resources"),
                              Tab(text: "Contributors"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: getSize(context, 10)),
                    Expanded(
                      child: TabBarView(
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
                                            controller: postController,
                                            //physics: BouncingScrollPhysics(),
                                            itemCount: postList.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        getSize(context, 20),
                                                    vertical: 10),
                                                child: Column(
                                                  children: [
                                                    PostWidget(
                                                        content:
                                                            postList[index]),
                                                    SizedBox(
                                                        height: getSize(
                                                            context, 10)),
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
                          isQuestionLoading
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
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        getSize(context, 20),
                                                    vertical: 10),
                                                child: Column(
                                                  children: [
                                                    questionList[index]
                                                                ["type"] ==
                                                            "Question"
                                                        ? QuestionWidget(
                                                            content:
                                                                questionList[
                                                                    index])
                                                        : AnswerWidget(
                                                            content:
                                                                questionList[
                                                                    index]),
                                                    SizedBox(
                                                        height: getSize(
                                                            context, 10)),
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
                                            controller: resourceController,
                                            //physics: BouncingScrollPhysics(),
                                            itemCount: resourceList.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        getSize(context, 20),
                                                    vertical:
                                                        getSize(context, 10)),
                                                child: Column(
                                                  children: [
                                                    ResourceWidget(
                                                        content: resourceList[
                                                            index]),
                                                    SizedBox(
                                                        height: getSize(
                                                            context, 10)),
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
                          isContributorsLoading
                              ? ShimmerWidget(count: 3)
                              : contributorList.length < 1
                                  ? EmptyState()
                                  : Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              controller: contributorController,
                                              //physics: BouncingScrollPhysics(),
                                              itemCount: contributorList.length,
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> data =
                                                    contributorList[index];
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 15),
                                                  child: Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => pushNewScreen(
                                                            context,
                                                            screen: data["userId"]
                                                                        [
                                                                        "_id"] ==
                                                                    userModel.id
                                                                ? ProfilePage()
                                                                : OtherProfilePage(
                                                                    content:
                                                                        data)),
                                                        child: Container(
                                                          width:
                                                              getWidth(context),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          data["userId"]
                                                                              [
                                                                              "profilepic"]),
                                                                  radius: 20),
                                                              SizedBox(
                                                                  width: getSize(
                                                                      context,
                                                                      10)),
                                                              Expanded(
                                                                  child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  textControl(
                                                                      "${data["userId"]["firstname"]} ${data["userId"]["lastname"]}",
                                                                      context,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                  Row(
                                                                      children: [
                                                                        textControl(
                                                                            "Contributions",
                                                                            context,
                                                                            size:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: colors.textBlue),
                                                                        SizedBox(
                                                                            width:
                                                                                getSize(context, 5)),
                                                                        textControl(
                                                                            ((data["posts"] ?? 0) + (data["questions"] ?? 0) + (data["resources"] ?? 0) + (data["answers"] ?? 0))
                                                                                .toString(),
                                                                            context,
                                                                            size:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ])
                                                                ],
                                                              )),
                                                              // CustomButton(text: "Follow", onPressed: () {}, width: 80, height: 30, textSize: 12, fontWeight: FontWeight.w100)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: getSize(
                                                              context, 15)),
                                                      divider(context)
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                        isMoreContributorsLoading
                                            ? loaderMain(context,
                                                status: true,
                                                size: getSize(context, 20),
                                                height: 50)
                                            : Container(),
                                      ],
                                    ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
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
    );
  }
}
