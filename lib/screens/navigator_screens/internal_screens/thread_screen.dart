import 'dart:developer';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/comment_widget.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ThreadScreen extends StatefulWidget {
  ThreadScreen({required this.content});

  final Map<String, dynamic> content;

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  List<dynamic> comments = [];
  // EventBus eventBus = EventBus();
  bool isLoading = false;
  bool loading = false;
  Map<String, dynamic> newData = {};
  bool onTap = false;
  int page = 1;
  String? repostCount;
  ScrollController scrollController = ScrollController();
  // pullToRefresh.RefreshController _refreshController = pullToRefresh.RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    debugPrint(widget.content.toString());
    //  print(widget.content["type"]);
    //  print(widget.content["reposter"]);
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadComments(context, true);
    });
    scrollController.addListener(() {
      // debugPrint(scrollController.position.pixels.toStringAsFixed(1));
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (newData["total"] > comments.length) {
          page++;
          loadComments(context, false);
        }
      }
      // if (scrollController.position.pixels == scrollController.position.minScrollExtent) {
      //   controlModel.fetchParent();
      // }
      // if (scrollController.position.pixels < 0) {
      //   controlModel.fetchParent();
      //   debugPrint(controlModel.fetchParentValue.toString());
      // }
      // if (scrollController.position.pixels.toStringAsFixed(1) == "-0.5") {
      //   controlModel.fetchParentValue = true;
      // }
    });
    controlModel.addListener(() {
      if (controlModel.commentOrAnswerUpdate == true) {
        if (controlModel.commentOrAnswerpaddyId == widget.content["_id"]) {
          if (mounted)
            setState(() {
              widget.content["comments"] = comments + ["${DateTime.now()}"];
            });
          reloadComments(context);
          controlModel.setCommentOrAnswerMade(false);
        }
      }
    });
    controlModel.socket.on("paddy-stream", (data) {
      //  print("Data: $data");
      if (data["type"] == "Comment" && data["paddyId"] == widget.content["_id"]) {
        if (mounted)
          setState(() {
            widget.content["comments"] = comments + ["${DateTime.now()}"];
            comments = comments + ["${DateTime.now()}"];
          });
        reloadComments(context);
      } else if (data["type"] == "Repost" && data["paddyId"] == widget.content["_id"]) {
        if (mounted)
          setState(() {
            // widget.content["reposter"] = widget.content["reposter"] + ["${DateTime.now()}"];
            repostCount = data["reposts"].length.toString();
          });
        // reloadComments(context);
      }
    });
  }

  reloadComments(BuildContext context) async {
    //  print("reload Comments");
    if (widget.content["type"] == "Question") {
      newData = await getQuestionAnswers(context, widget.content["_id"], page);
    } else {
      newData = await getComments(context, widget.content["paddyId"] != null ? widget.content["paddyId"]["_id"] : widget.content["_id"], page);
    }
    comments = newData["data"];
    setState(() {
      loading = false;
      isLoading = false;
    });
  }

  loadComments(BuildContext context, bool initial) async {
    setState(() {
      loading = initial ? true : false;
      isLoading = initial ? false : true;
    });
    if (widget.content["type"] == "Question") {
      newData = await getQuestionAnswers(context, widget.content["_id"], page);
    } else {
      newData = await getComments(context, widget.content["paddyId"] != null ? widget.content["paddyId"]["_id"] : widget.content["_id"], page);
    }
    comments.addAll(newData["data"]);
    //  print(comments);
    setState(() {
      loading = false;
      isLoading = false;
    });
  }

  Padding basicDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(width: getWidth(context), height: getSize(context, 0.6), color: Colors.black.withOpacity(0.15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return Scaffold(
        appBar: customAppBar(context, widget.content["type"] ?? ""),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => Future.delayed(Duration(microseconds: 10), () => controlModel.eventBus.fire(true)),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: getSize(context, 15)),
                    child: widget.content["type"] == "Post"
                        ? PostWidget(content: widget.content, onTap: false)
                        : widget.content["type"] == "Question"
                            ? QuestionWidget(content: widget.content, onTap: false)
                            : widget.content["type"] == "Resource"
                                ? ResourceWidget(content: widget.content, onTap: false)
                                : widget.content["type"] == "Answer" /* || widget.content["paddyId"]["type"] == "Answer" */
                                    ? AnswerWidget(content: widget.content, onTap: false)
                                    : widget.content["type"] == "Comment"
                                        ? CommentWidget(content: widget.content, onTap: false)
                                        : SizedBox(height: 0),
                  ),
                  SizedBox(height: getSize(context, 20)),
                  basicDivider(context),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          widget.content["type"] == "Question"
                              ? textControl(widget.content["answers"].length.toString() + " ", context, fontWeight: FontWeight.w800)
                              : textControl(
                                  widget.content["paddyId"] != null
                                      ? widget.content["paddyId"]["comments"].length.toString()
                                      : widget.content["comments"].length.toString() + " ",
                                  context,
                                  fontWeight: FontWeight.w800),
                          widget.content["type"] == "Question"
                              ? textControl(widget.content["answers"].length == 1 ? "answer" : "answers", context, fontWeight: FontWeight.w800)
                              : textControl(
                                  widget.content["paddyId"] != null
                                      ? widget.content["paddyId"]["comments"].length == 1
                                          ? "comment"
                                          : "comments"
                                      : widget.content["comments"].length == 1
                                          ? "comment"
                                          : "comments",
                                  context,
                                  fontWeight: FontWeight.w800),
                          SizedBox(width: getSize(context, 10)),
                          widget.content["type"] == "Question"
                              ? textControl(widget.content["reasker"].length.toString() + " ", context, fontWeight: FontWeight.w800)
                              : textControl(
                                  repostCount ??
                                      (widget.content["paddyId"] != null
                                              ? widget.content["paddyId"]["reposter"].length.toString()
                                              : widget.content["reposter"].length.toString()) +
                                          " ",
                                  context,
                                  fontWeight: FontWeight.w800),
                          widget.content["type"] == "Question"
                              ? textControl(widget.content["reasker"].length != 1 ? "reasks" : "reask", context, fontWeight: FontWeight.w800)
                              : textControl(
                                  widget.content["paddyId"] != null
                                      ? widget.content["paddyId"]["comments"].length != 1
                                          ? "reposts"
                                          : "repost"
                                      : widget.content["reposter"].length != 1
                                          ? "reposts"
                                          : "repost",
                                  context,
                                  fontWeight: FontWeight.w800),
                        ],
                      )),
                  basicDivider(context),
                  loading
                      ? loaderMain(context, status: true)
                      // ? ShimmerWidget(count: 3)
                      : comments.length < 1
                          ? EmptyState()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      child: CommentWidget(content: comments[index]),
                                    ),
                                    basicDivider(context),
                                    index + 1 == comments.length
                                        ? isLoading
                                            ? Center(
                                                child: loaderMain(context,
                                                    status: isLoading, size: 20, height: isLoading ? 20 : 0, width: isLoading ? null : 0),
                                              )
                                            : SizedBox()
                                        : SizedBox()
                                  ],
                                );
                              },
                            )
                ],
              ),
            ),
          ),
        ));
  }
}
