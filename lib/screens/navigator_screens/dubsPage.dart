import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/shimmer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/dubs_filter.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class DubsPage extends StatefulWidget {
  const DubsPage({Key? key}) : super(key: key);

  @override
  _DubsPageState createState() => _DubsPageState();
}

class _DubsPageState extends State<DubsPage>
    with SingleTickerProviderStateMixin {
  bool answeredSelected = true;
  bool filesSelected = false;
  bool isQuestionLoading = true;
  bool moreQuestions = false;
  bool moreResources = false;
  bool isResourceLoading = false;
  bool linkSelected = true;
  int questionPage = 1;
  ScrollController questionScrollController = ScrollController();
  Map<String, dynamic>? questions;
  List<dynamic> questionsList = [];
  int resourcePage = 1;
  ScrollController resourceScrollController = ScrollController();
  Map<String, dynamic>? resources;
  List<dynamic> resourcesList = [];
  TabController? tabController;
  bool unAnsweredSelected = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController!
      ..addListener(() {
        if (tabController!.indexIsChanging) {
          handleTabSelection();
        }
      });
    tabController!.animation
      ?..addListener(() {
        handleTabSelection();
      });
    getResources();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserChangeNotifierModel userModel =
          Provider.of<UserChangeNotifierModel>(context, listen: false);
      userModel.addListener(() {
        if (userModel.questionSort?.index == 0 ||
            userModel.questionSort?.index == 1 ||
            userModel.questionSort?.index == 2) {
          getQuestions();
        }
        if (userModel.resourceSort?.index == 0 ||
            userModel.resourceSort?.index == 1 ||
            userModel.resourceSort?.index == 2) {
          getResources();
        }
      });
      questionScrollController.addListener(() {
        if (questionScrollController.position.pixels ==
            questionScrollController.position.maxScrollExtent) {
          questionPage++;
          getQuestions(moreData: true);
        }
      });
      resourceScrollController.addListener(() {
        if (resourceScrollController.position.pixels ==
            resourceScrollController.position.maxScrollExtent) {
          resourcePage++;
          getResources(moreData: true);
        }
      });
    });
  }

  getQuestions({bool moreData = false, bool initialPage = false}) async {
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isQuestionLoading = true;
      });
      //  print("more questions is true");
    } else {
      setState(() {
        moreQuestions = true;
      });
    }
    //  print("getting questions");
    questions = await getDubsByQuestion(
        context,
        answeredSelected,
        initialPage
            ? 1
            : moreData
                ? questionPage
                : 1,
        sort: userModel.questionSort);
    // //  print(questions);
    if (moreData == true) {
      questionsList.addAll(questions!['data']["dubs"]);
    } else {
      questionsList = questions!['data']["dubs"];
    }
    setState(() {
      isQuestionLoading = false;
      moreQuestions = false;
    });
  }

  getResources({bool moreData = false}) async {
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isResourceLoading = true;
      });
    } else {
      //  print("more Resources is true");
      setState(() {
        moreResources = true;
      });
    }
    //  print("getting Resources");
    resources = await getDubsByResource(
        context, linkSelected, moreData ? resourcePage : 1,
        sort: userModel.resourceSort);
    debugPrint("=====================+>>>>>Gotten data");
    if (moreData == true) {
      resourcesList.addAll(resources!['data']["dubs"]);
    } else {
      resourcesList.clear();
      resourcesList = resources!['data']['dubs'];
      debugPrint(resourcesList.toString());
    }
    setState(() {
      isResourceLoading = false;
      moreResources = false;
    });
  }

  handleTabSelection() {
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    setState(() {
      if (tabController?.index == 0) {
        if (resources == null) {
          debugPrint("===============++> GETTING FROM HANDLE TAB SELECTION");
          getResources();
        }
        // Used to select question for sorting
        userModel.setQuestionSelected(false);
      } else if (tabController?.index == 1) {
        if (questions == null) {
          getQuestions();
        }
        userModel.setQuestionSelected(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: colors.backgroundWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getSize(context, 20)),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: colors.paddygreen.withOpacity(0.5)))),
                    height: 45,
                    width: getSize(context, 260),
                    child: TabBar(
                      isScrollable: true,
                      controller: tabController,
                      labelColor: colors.paddygreen,
                      labelStyle: TextStyle(fontWeight: FontWeight.w800),
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: AutoSizeText("Resources", maxLines: 1))),
                        Tab(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Questions", maxLines: 1))),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: colors.paddygreen
                                          .withOpacity(0.5)))))),
                  Container(
                      height: 45,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: colors.paddygreen.withOpacity(0.5)))),
                      child: IconButton(
                          icon: Icon(Icons.sort),
                          color: colors.blueColorOne,
                          onPressed: () {
                            pushNewScreen(context,
                                screen: DubsFilter(), withNavBar: false);
                          },
                          padding: EdgeInsets.zero))
                ],
              ),
              tabController?.index == 1
                  ? Row(children: [
                      InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, bottom: 10, top: 20, right: 10),
                            child: textControl("Answered", context,
                                fontWeight: FontWeight.w900,
                                color: answeredSelected
                                    ? colors.paddygreen
                                    : colors.textBlack),
                          ),
                          onTap: () {
                            if (answeredSelected) {
                            } else {
                              setState(() {
                                unAnsweredSelected = false;
                                answeredSelected = true;
                              });
                              getQuestions();
                            }
                          }),
                      SizedBox(width: getSize(context, 10)),
                      InkWell(
                          onTap: () {
                            if (unAnsweredSelected) {
                            } else {
                              setState(() {
                                unAnsweredSelected = true;
                                answeredSelected = false;
                              });
                              getQuestions(initialPage: true);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, bottom: 10, top: 20, right: 10),
                            child: textControl("Unanswered", context,
                                fontWeight: FontWeight.w900,
                                color: unAnsweredSelected
                                    ? colors.paddygreen
                                    : colors.textBlack),
                          )),
                    ])
                  : Row(children: [
                      InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, bottom: 10, top: 20, right: 10),
                            child: textControl("Links", context,
                                fontWeight: FontWeight.w900,
                                color: linkSelected
                                    ? colors.paddygreen
                                    : colors.textBlack),
                          ),
                          onTap: () {
                            if (linkSelected) {
                            } else {
                              setState(() {
                                linkSelected = true;
                                filesSelected = false;
                              });
                              getResources();
                            }
                          }),
                      SizedBox(width: getSize(context, 10)),
                      InkWell(
                          onTap: () {
                            if (filesSelected) {
                            } else {
                              setState(() {
                                filesSelected = true;
                                linkSelected = false;
                              });
                              getResources();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, bottom: 10, top: 20, right: 10),
                            child: textControl("Files", context,
                                fontWeight: FontWeight.w900,
                                color: filesSelected
                                    ? colors.paddygreen
                                    : colors.textBlack),
                          )),
                    ]),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    isResourceLoading
                        ? ShimmerWidget(count: 3)
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: getSize(context, 20)),
                            child: resourcesList.length < 1
                                ? EmptyState()
                                : Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            controller:
                                                resourceScrollController,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount: resourcesList.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8),
                                                    child: ResourceWidget(
                                                        content: resourcesList[
                                                            index]),
                                                  ),
                                                  divider(context)
                                                ],
                                              );
                                            }),
                                      ),
                                      // moreResources
                                      //     ? SizedBox(height: 25, width: 25 ,child: CircularProgressIndicator())
                                      //     : Container()
                                    ],
                                  ),
                          ),
                    isQuestionLoading
                        ? ShimmerWidget(count: 3)
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: getSize(context, 20)),
                            child: questionsList.length < 1
                                ? EmptyState()
                                : Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          controller: questionScrollController,
                                          //physics: BouncingScrollPhysics(),
                                          itemCount: questionsList.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8),
                                                    child: questionsList[index]
                                                                ["type"] ==
                                                            "Question"
                                                        ? QuestionWidget(
                                                            content:
                                                                questionsList[
                                                                    index],
                                                            answerExtension:
                                                                false)
                                                        : AnswerWidget(
                                                            content:
                                                                questionsList[
                                                                    index])),
                                                divider(context)
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      // moreQuestions
                                      //     ? SizedBox(height: 25, width: 25 ,child: CircularProgressIndicator())
                                      //     : Container()
                                    ],
                                  ),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: (moreQuestions == true || moreResources == true)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Container(
                      decoration: BoxDecoration(
                          color: colors.backgroundWhite,
                          shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                )
              : Container(),
        )
      ],
    );
  }
}
