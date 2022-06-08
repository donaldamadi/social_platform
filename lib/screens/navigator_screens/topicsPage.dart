import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class TopicsPage extends StatefulWidget {
  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Map<String, dynamic>> defaultList = [];
  List<Map<String, dynamic>> topicsList = [];
  bool loading = false;
  String keyword = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    loadTopics(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ControlChangeNotifierModel controlModel =
          Provider.of<ControlChangeNotifierModel>(context, listen: false);
      controlModel.addListener(() {
        if (controlModel.updateTopicList == true) {
          //  print("Updating List");
          setState(() {
            loadTopics(context, updating: true);
            controlModel.updateTopicList = false;
          });
        }
      });
    });
  }

  Future<void> loadTopics(BuildContext context, {bool updating = false}) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (userModel.topics.isEmpty) {
      setState(() {
        isLoading = true;
      });
      await quickUserData(context);
      setState(() {
        isLoading = false;
      });
    }
    if (updating == true) {
      await quickTopics(context);
    }
    setState(() {
      defaultList = userModel.topics;
      topicsList = defaultList;
      loading = false;
    });
  }

  search(String value) {
    if (value != "") {
      topicsList = [];
      for (var i in defaultList) {
        if (i["name"].toLowerCase().contains(value.toLowerCase())) {
          topicsList.add(i);
        }
      }
      setState(() {});
    } else {
      setState(() {
        topicsList = defaultList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
        color: colors.backgroundWhite,
        child: Column(
          children: [
            SizedBox(height: getSize(context, 20)),
            Center(
                child: textControl("Topics", context,
                    size: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: getSize(context, 20)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                header: "",
                onChanged: (val) => search(val),
                hintText: "Search for topics",
              ),
            ),
            SizedBox(height: getSize(context, 20)),
            Expanded(
              child: loading
                  ? Center(
                      child: loaderMain(context, status: true, size: 40),
                    )
                  : ListView.builder(
                      //physics: BouncingScrollPhysics(),
                      itemCount: topicsList.length,
                      itemBuilder: (context, index) {
                        topicsList[index]["followers"] =
                            topicsList[index]["followers"] ?? [];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox.expand(
                                    child: InkWell(
                                      onTap: () {
                                        pushNewScreen(context,
                                            screen: SingleTopic(
                                                content: topicsList[index]),
                                            withNavBar: false);
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          textControl(
                                              toBeginningOfSentenceCase(
                                                      topicsList[index]["name"]
                                                          .trim()) ??
                                                  "No Topic",
                                              context,
                                              overflow: true),
                                          Row(
                                            children: [
                                              textControl(
                                                  "Contributions", context,
                                                  overflow: true,
                                                  size: 12,
                                                  fontWeight: FontWeight.w300,
                                                  color: colors.textBlue),
                                              SizedBox(
                                                  width: getSize(context, 5)),
                                              textControl(
                                                  "${topicsList[index]["contributions"] ?? 0}",
                                                  context,
                                                  overflow: true,
                                                  fontWeight: FontWeight.w600,
                                                  size: 12),
                                              SizedBox(
                                                  width: getSize(context, 10)),
                                              textControl("Followers", context,
                                                  overflow: true,
                                                  size: 12,
                                                  fontWeight: FontWeight.w300,
                                                  color: colors.textBlue),
                                              SizedBox(
                                                  width: getSize(context, 5)),
                                              textControl(
                                                  "${(topicsList[index]["followers"] ?? []).length}",
                                                  context,
                                                  overflow: true,
                                                  fontWeight: FontWeight.w600,
                                                  size: 12),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                CustomButton(
                                  text: (topicsList[index]["followers"] ?? [])
                                          .contains(userModel.id)
                                      ? "Following"
                                      : "Follow",
                                  onPressed: () async {
                                    // setState(() async {
                                    if (topicsList[index]["followers"]
                                        .contains(userModel.id)) {
                                      setState(() {
                                        topicsList[index]["followers"]
                                            .remove(userModel.id);
                                      });
                                      await followUnfollowTopic(
                                          context,
                                          topicsList[index]["name"],
                                          {"action": "unfollow"});
                                      userModel.setUpdatedResult(true);
                                    } else {
                                      setState(() {
                                        topicsList[index]["followers"]
                                            .add(userModel.id);
                                      });
                                      await followUnfollowTopic(
                                          context,
                                          topicsList[index]["name"],
                                          {"action": "follow"});
                                      userModel.setUpdatedResult(true);
                                    }
                                    // });
                                  },
                                  width: 88,
                                  height: 30,
                                  textSize: 12,
                                  buttonType:
                                      (topicsList[index]["followers"] ?? [])
                                              .contains(userModel.id)
                                          ? ButtonType.one
                                          : ButtonType.two,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
