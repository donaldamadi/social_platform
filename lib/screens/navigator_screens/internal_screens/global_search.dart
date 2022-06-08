import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/people_widget.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/topic_widget.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/notification_settings.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/community_screens/single_community.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/messages_screen.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class GlobalSearch extends StatefulWidget {
  const GlobalSearch({Key? key}) : super(key: key);

  @override
  _GlobalSearchState createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<GlobalSearch> {
  String keyword = "";
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool activeSearch = false;
  bool searchPeople = false;
  bool searchTopic = false;
  bool searchPost = false;
  bool searchQuestion = false;
  bool searchResource = false;
  bool searchCommunity = false;
  bool searchPaddy = false;
  Map<String, dynamic> fullSearchResult = {};
  List<dynamic> searchResult = [];
  List<dynamic> people = [];
  List<dynamic> topics = [];
  List<dynamic> post = [];
  List<dynamic> question = [];
  List<dynamic> resource = [];
  List<dynamic> community = [];
  bool isSearching = false;

  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          activeSearch = false;
        });
      }
    });
    super.initState();
  }

  searchKeyword(BuildContext context, String keyword) async {
    setState(() {
      isSearching = true;
    });
    fullSearchResult = await search(context, keyword);
    //  print(fullSearchResult);
    searchResult = fullSearchResult["everything"];
    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          SizedBox(height: getSize(context, 10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getSize(context, 20)),
            child: headerWidget(context, "Search"),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: getSize(context, 20)),
              child: SizedBox(
                  width: getWidth(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          height: getSize(context, 50),
                          autoFocus: true,
                          focusNode: focusNode,
                          controller: searchController,
                          header: "",
                          icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SvgPicture.asset("assets/svgs/search_icon.svg"),
                          ),
                          hintText: "Search here at student paddy...",
                          onChanged: (value) {
                            setState(() {
                              keyword = value;
                              if (keyword.isNotEmpty) searchKeyword(context, keyword);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: getSize(context, 10)),
                      keyword.isEmpty
                          ? IconButton(
                              onPressed: () {
                                pushNewScreen(context, screen: MessagesScreen(), withNavBar: false);
                              },
                              icon: Icon(Icons.send),
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                              color: colors.paddygreen)
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  keyword = "";
                                  searchController.clear();
                                });
                              },
                              child: textControl(
                                "Cancel",
                                context,
                                color: colors.red,
                              ))
                    ],
                  ))),
          SizedBox(height: getSize(context, 20)),
          focusNode.hasFocus
              ? Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: getSize(context, 20)),
                      child: Container(
                        child: keyword.isNotEmpty
                            ? Column(
                                children: [
                                  isSearching
                                      ? loaderMain(context, size: 30, status: true)
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: searchResult.length,
                                          itemBuilder: (context, index) {
                                            if (searchResult[index].isNotEmpty) {
                                              return searchSections(
                                                  searchResult[index]["label"] ??
                                                      (searchResult[index]["firstname"] != null
                                                          ? searchResult[index]["firstname"] + " " + searchResult[index]["lastname"]
                                                          : null) ??
                                                      searchResult[index]["body"] ??
                                                      searchResult[index][
                                                          "name"] /* ??
                                              (searchResult[index]["skill_sets"] != null ? searchResult[index]["skill_sets"].join(", ") : null) */
                                                  ,
                                                  searchResult[index]["type"],
                                                  searchResult[index]["_id"],
                                                  content: searchResult[index],
                                                  onTap: () {});
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        ),
                                  SizedBox(height: getSize(context, 20)),
                                  divider(context),
                                  SizedBox(height: getSize(context, 20)),
                                  InkWell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: textControl("See all Results", context, size: 15, color: colors.paddygreen),
                                      ),
                                      onTap: () {
                                        focusNode.unfocus();
                                        setState(() {
                                          searchPeople = true;
                                          searchTopic = false;
                                          searchPost = false;
                                          searchQuestion = false;
                                          searchResource = false;
                                          searchCommunity = false;
                                          searchPaddy = false;
                                          people = fullSearchResult["users"];
                                          topics = fullSearchResult["topics"];
                                        });
                                      }),
                                  SizedBox(height: getSize(context, 20)),
                                ],
                              )
                            : Container(),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getSize(context, 10)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: getSize(context, 10)),
                        child: Wrap(spacing: 10, runSpacing: 10, children: [
                          InkWell(
                            onTap: () {
                              if (!searchPeople)
                                setState(() {
                                  searchPeople = true;
                                  searchTopic = false;
                                  searchPost = false;
                                  searchQuestion = false;
                                  searchResource = false;
                                  searchCommunity = false;
                                  searchPaddy = false;
                                  people = fullSearchResult["users"];
                                });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: searchPeople ? colors.paddygreen : Colors.transparent,
                                    border: searchPeople ? Border() : Border.all(color: colors.paddygreen)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: textControl("People", context, color: searchPeople ? colors.white : colors.paddygreen),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              if (!searchTopic)
                                setState(() {
                                  searchPeople = false;
                                  searchTopic = true;
                                  searchPost = false;
                                  searchQuestion = false;
                                  searchResource = false;
                                  searchCommunity = false;
                                  searchPaddy = false;
                                  topics = fullSearchResult["topics"];
                                });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: searchTopic ? colors.paddygreen : Colors.transparent,
                                    border: searchTopic ? Border() : Border.all(color: colors.paddygreen)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: textControl("Topic", context, color: searchTopic ? colors.white : colors.paddygreen),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              if (!searchPost) {
                                post = [];
                                for (var i in fullSearchResult["paddies"]) {
                                  if (i["type"] == "Post" && !post.contains(i)) {
                                    post.add(i);
                                  }
                                }
                                setState(() {});
                              }
                              setState(() {
                                searchPeople = false;
                                searchTopic = false;
                                searchPost = true;
                                searchQuestion = false;
                                searchResource = false;
                                searchCommunity = false;
                                searchPaddy = false;
                                // post = fullSearchResult["paddies"];
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: searchPost ? colors.paddygreen : Colors.transparent,
                                    border: searchPost ? Border() : Border.all(color: colors.paddygreen)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: textControl("Post", context, color: searchPost ? colors.white : colors.paddygreen),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              if (!searchQuestion) {
                                for (var i in fullSearchResult["paddies"]) {
                                  if (i["type"] == "Question" && !question.contains(i)) {
                                    question.add(i);
                                  }
                                }
                                //  print(question);
                                setState(() {
                                  searchPeople = false;
                                  searchTopic = false;
                                  searchPost = false;
                                  searchQuestion = true;
                                  searchResource = false;
                                  searchCommunity = false;
                                  searchPaddy = false;
                                });
                              }
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: searchQuestion ? colors.paddygreen : Colors.transparent,
                                    border: searchQuestion ? Border() : Border.all(color: colors.paddygreen)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: textControl("Question", context, color: searchQuestion ? colors.white : colors.paddygreen),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              if (!searchResource) {
                                for (var i in fullSearchResult["paddies"]) {
                                  if (i["type"] == "Resource" && !resource.contains(i)) {
                                    resource.add(i);
                                  }
                                }
                                //  print(resource);
                                setState(() {
                                  searchPeople = false;
                                  searchTopic = false;
                                  searchPost = false;
                                  searchQuestion = false;
                                  searchResource = true;
                                  searchCommunity = false;
                                  searchPaddy = false;
                                });
                              }
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: searchResource ? colors.paddygreen : Colors.transparent,
                                    border: searchResource ? Border() : Border.all(color: colors.paddygreen)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: textControl("Resource", context, color: searchResource ? colors.white : colors.paddygreen),
                                )),
                          ),
                        ]),
                      ),
                      SizedBox(height: getSize(context, 20)),
                      Container(
                        width: getWidth(context),
                        height: getSize(context, 1),
                        color: Color(0xFF000000).withOpacity(0.15),
                      ),
                      SizedBox(height: getSize(context, 20)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: getSize(context, 20)),
                        child: textControl(
                            "${searchPeople ? people.length : searchTopic ? topics.length : searchPost ? post.length : searchQuestion ? question.length : searchResource ? resource.length : 0} result(s) found",
                            context,
                            color: colors.paddygreen,
                            size: 15),
                      ),
                      SizedBox(height: getSize(context, 20)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: searchPeople
                                  ? people.length
                                  : searchTopic
                                      ? topics.length
                                      : searchPost
                                          ? post.length
                                          : searchQuestion
                                              ? question.length
                                              : searchResource
                                                  ? resource.length
                                                  : 0,
                              itemBuilder: (context, index) {
                                if (searchPeople) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: PeopleWidget(content: people[index]),
                                  );
                                } else if (searchTopic) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [TopicWidget(content: topics[index]), SizedBox(height: 10), divider(context)],
                                    ),
                                  );
                                } else if (searchQuestion) {
                                  return Column(
                                    children: [QuestionWidget(content: question[index]), SizedBox(height: 10), divider(context)],
                                  );
                                } else if (searchResource) {
                                  return Column(
                                    children: [ResourceWidget(content: resource[index]), SizedBox(height: 10), divider(context)],
                                  );
                                } else if (searchPost) {
                                  return Column(
                                    children: [PostWidget(content: post[index]), SizedBox(height: 10), divider(context)],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    ));
  }

  select(String type) {
    if (type == "user") {
      setState(() {
        searchPeople = true;
      });
    }
  }

  Widget searchSections(String? label, String type, String id, {required Map<String, dynamic> content, required Function onTap}) {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
      height: getSize(context, 50),
      child: InkWell(
        onTap: () {
          setState(() {
            focusNode.unfocus();
          });
          if (type == "user")
            pushNewScreen(context, screen: id == userModel.id ? ProfilePage() : OtherProfilePage(content: content), withNavBar: false)
                .then((value) => setState(() {
                      focusNode.requestFocus();
                    }));
          if (type == "Post")
            pushNewScreen(context, screen: ThreadScreen(content: content), withNavBar: false).then((value) => setState(() {
                  focusNode.requestFocus();
                }));
          if (type == "Resource")
            pushNewScreen(context, screen: ThreadScreen(content: content), withNavBar: false).then((value) => setState(() {
                  focusNode.requestFocus();
                }));
          if (type == "Question")
            pushNewScreen(context, screen: ThreadScreen(content: content), withNavBar: false).then((value) => setState(() {
                  focusNode.requestFocus();
                }));
          if (type == "topic")
            pushNewScreen(context, screen: SingleTopic(content: content), withNavBar: false).then((value) => setState(() {
                  focusNode.requestFocus();
                }));
          if (type == "community")
            pushNewScreen(context, screen: SingleCommunity(content: content), withNavBar: false).then((value) => setState(() {
                  focusNode.requestFocus();
                }));
        },
        child: Row(children: [
          SvgPicture.asset("assets/svgs/search_icon.svg", height: 20),
          SizedBox(width: getSize(context, 15)),
          Flexible(
              child:
                  textControl(label != null && label != "" ? parseHtmlString(label) : keyword, context, fontWeight: FontWeight.w900, overflow: true)),
          SizedBox(width: getSize(context, 5)),
          textControl("in $type", context, fontStyle: FontStyle.italic, size: 13)
        ]),
      ),
    );
  }
}
