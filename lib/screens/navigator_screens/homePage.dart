import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_requery/flutter_requery.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/shimmer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> feedData = [];

  /// define data and cache key
  final List<String> data = ["Hello"];
  final String cacheKey = 'strKey';
  bool loading = false;
  bool isLoading = false;
  int page = 1;
  ScrollController scrollController = ScrollController();
  Map<String, dynamic> newData = {};
  Timer? timer;
  Future loadData(BuildContext context, bool initial, {bool updating = false}) async {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (updating == false) {
      setState(() {
        loading = initial ? true : false;
        isLoading = initial ? false : true;
      });
    }
    newData = await getHomeFeed(context, updating ? 1 : page);
    feedData = newData['data'];
    initial ? userModel.setHomeFeed(feedData) : userModel.addToHomeFeed(feedData);
    setState(() {
      loading = false;
      isLoading = false;
    });
  }

  void invalidate() async {
    queryCache.invalidateQueries(cacheKey);
  }

  @override
  void initState() {
    super.initState();
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    userModel.addListener(() {
      if (userModel.updatedResult == true) {
        loadData(context, true, updating: true);
        userModel.setUpdatedResult(false);
      }
    });
    controlModel.addListener(() {
      if (controlModel.goToFeedTop == true) {
        scrollToTop();
      }
    });
    scrollController.addListener(() {
      UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
      if (scrollController.position.pixels == (scrollController.position.maxScrollExtent)) {
        if (newData["total"] > userModel.homeFeed.length) {
          page++;
          loadData(context, false);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    });
  }

  dispose() {
    super.dispose();
    scrollController.dispose();
  }

  scrollToTop() async {
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeOut);
    setState(() {});
    controlModel.setGoToFeedTop(false);
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return RefreshIndicator(
      onRefresh: () async => loadData(context, true, updating: true),
      child: Material(
        color: Colors.transparent,
        child: loading
            ? ShimmerWidget(count: 3)
            : userModel.homeFeed.length == 0
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        SvgPicture.asset(
                          'assets/svgs/paddy_smiley.svg',
                          height: 150,
                          width: 150,
                          color: colors.paddygreen,
                        ),
                        SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: textControl("You have no feed yet. Follow Topics, Communities or other users to get some feed", context,
                              size: 17, color: colors.paddygreen, textAlign: TextAlign.center),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: userModel.homeFeed.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            userModel.homeFeed[index]["type"] == "Post"
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: PostWidget(content: userModel.homeFeed[index]),
                                  )
                                : userModel.homeFeed[index]["type"] == "Question"
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        child: QuestionWidget(content: userModel.homeFeed[index]),
                                      )
                                    : userModel.homeFeed[index]["type"] == "Resource"
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            child: ResourceWidget(content: userModel.homeFeed[index]),
                                          )
                                        : userModel.homeFeed[index]["type"] == "Answer"
                                            ? Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                child: AnswerWidget(content: userModel.homeFeed[index]),
                                              )
                                            : userModel.homeFeed[index]["type"] == "Comment"
                                                ? SizedBox()
                                                : SizedBox(height: 0),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: userModel.homeFeed[index]["type"] == "Comment" ? SizedBox() : divider(context),
                            ),
                            index + 1 == userModel.homeFeed.length
                                ? isLoading
                                    ? Center(
                                        child:
                                            loaderMain(context, status: isLoading, size: 20, height: isLoading ? 20 : 0, width: isLoading ? null : 0),
                                      )
                                    : SizedBox()
                                : SizedBox()
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
