import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup3.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

import '../../../components/inputFields.dart';

class DubsFilter extends StatefulWidget {
  const DubsFilter({Key? key}) : super(key: key);

  @override
  _DubsFilterState createState() => _DubsFilterState();
}

enum Sort { newest, oldest, recentActivity }

class Topics {
  String name;
  String id;

  Topics({required this.name, required this.id});
}

class _DubsFilterState extends State<DubsFilter> {
  Sort? sort;
  List<Communities> commList = [];
  List<String> communitiesPicked = [];
  bool filterByExpanded = false;
  bool filterByTopicExpanded = false;
  List<String> topics = [];
  List<Topics> topicsList = [];
  String? topic;
  String topicId = "";

  @override
  void initState() {
    super.initState();
    getTopics(context);
    populateOptions(context);
    populateCommunities(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  getTopics(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    for (var i in userModel.topics) {
      topics.add(i["name"]);
      topicsList.add(Topics(name: i["name"], id: i["_id"]));
    }
  }

  populateOptions(BuildContext context) {
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    if (userModel.isQuestionSelected) {
      //  print(userModel.questionSort);
      //  print(userModel.questionFilter);
      sort = userModel.questionSort;
      communitiesPicked = userModel.questionFilter;
      //  print(communitiesPicked);
    } else {
      //  print(userModel.resourceSort);
      //  print(userModel.resourceFilter);
      sort = userModel.resourceSort;
      communitiesPicked = userModel.resourceFilter;
      //  print(communitiesPicked);
    }
    setState(() {});
  }

  populateCommunities(BuildContext context) {
    UserOnBoardChangeNotifierModel userOnBoardModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    //  print(userOnBoardModel.communities);
    for (var i in userOnBoardModel.communities) {
      commList.add(Communities(
          community: i["name"],
          isChosen: communitiesPicked.contains(i["name"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserChangeNotifierModel userModel =
        Provider.of<UserChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, "Filter"),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              if (topicId.isNotEmpty) {
                                debugPrint("topicId: $topicId");
                                userModel.setQuestionTopicId(topicId);
                              } else {
                                userModel.setQuestionTopicId("");
                              }
                              if (userModel.isQuestionSelected) {
                                userModel.setQuestionSort(
                                    sort ?? Sort.recentActivity);
                                userModel.setQuestionFilter(communitiesPicked);
                              } else {
                                if (topicId.isNotEmpty) {
                                  debugPrint("topicId: $topicId");
                                  userModel.setResourceTopicId(topicId);
                                } else {
                                  userModel.setResourceTopicId("");
                                }
                                userModel.setResourceSort(
                                    sort ?? Sort.recentActivity);
                                userModel.setResourceFilter(communitiesPicked);
                              }
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: textControl("Save", context,
                                  color: colors.paddyLightGreen,
                                  size: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getSize(context, 30)),
                      textControl("Sort by", context,
                          size: 18, fontWeight: FontWeight.w800),
                      SizedBox(height: getSize(context, 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textControl("Newest", context,
                              fontWeight: FontWeight.w500),
                          Radio(
                            value: Sort.newest,
                            groupValue: sort,
                            onChanged: (Sort? value) {
                              setState(() {
                                sort = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textControl("Oldest", context,
                              fontWeight: FontWeight.w500),
                          Radio(
                            value: Sort.oldest,
                            groupValue: sort,
                            onChanged: (Sort? value) {
                              setState(() {
                                sort = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textControl("Recent activity", context,
                              fontWeight: FontWeight.w500),
                          Radio(
                            value: Sort.recentActivity,
                            groupValue: sort,
                            onChanged: (Sort? value) {
                              setState(() {
                                sort = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: getSize(context, 50)),
                      textControl("Filter by", context,
                          size: 18, fontWeight: FontWeight.w800),
                      SizedBox(height: getSize(context, 20)),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              filterByExpanded = !filterByExpanded;
                            }),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                textControl("Community", context,
                                    color: colors.paddygreen),
                                SizedBox(width: getSize(context, 5)),
                                Icon(
                                    filterByExpanded
                                        ? Icons.keyboard_arrow_down_outlined
                                        : Icons.chevron_right,
                                    color: colors.paddygreen,
                                    size: 18),
                              ],
                            ),
                          ),
                          SizedBox(height: getSize(context, 30)),
                          filterByExpanded
                              ? Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children:
                                      List.generate(commList.length, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        commList[index].isChosen =
                                            !commList[index].isChosen!;
                                        if (commList[index].isChosen!) {
                                          communitiesPicked
                                              .add(commList[index].community!);
                                        } else {
                                          communitiesPicked.remove(
                                              commList[index].community);
                                        }
                                        // if (userModel.isQuestionSelected) {
                                        //   userModel.setQuestionFilter(communitiesPicked);
                                        // } else {
                                        //   userModel.setResourceFilter(communitiesPicked);
                                        // }
                                        //  print(communitiesPicked);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: commList[index].isChosen!
                                                ? colors.paddygreen
                                                : Colors.transparent,
                                            border: commList[index].isChosen!
                                                ? Border()
                                                : Border.all()),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: textControl(
                                              commList[index].community!,
                                              context,
                                              color: commList[index].isChosen!
                                                  ? Colors.white
                                                  : Colors.black
                                                      .withOpacity(0.6)),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              : SizedBox(),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              filterByTopicExpanded = !filterByTopicExpanded;
                            }),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                textControl("Topic", context,
                                    color: colors.paddygreen),
                                SizedBox(width: getSize(context, 5)),
                                Icon(
                                    filterByTopicExpanded
                                        ? Icons.keyboard_arrow_down_outlined
                                        : Icons.chevron_right,
                                    color: colors.paddygreen,
                                    size: 18),
                              ],
                            ),
                          ),
                          SizedBox(height: getSize(context, 30)),
                          filterByTopicExpanded
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                    border: Border.all(
                                      color: colors.blueColorOne,
                                      style: BorderStyle.solid,
                                      width: 1,
                                    ),
                                  ),
                                  child: inputSelectFieldTwo(
                                    context,
                                    itemList: topics,
                                    icon: false,
                                    placeholder: "Search for topic",
                                    noBorder: true,
                                    fontSize: 16,
                                    onSelect: (value) {
                                      for (var i in topicsList) {
                                        if (i.name == value) {
                                          topicId = i.id;
                                          debugPrint(topicId);
                                        }
                                      }
                                      topic = value;
                                    },
                                    padding: 0,
                                  ))
                              : SizedBox(),
                        ],
                      ),
                      SizedBox(height: 40)
                    ]),
              ))),
    );
  }
}
