import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/expandable_text.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/comment.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnswerWidget extends StatefulWidget {
  AnswerWidget(
      {required this.content,
      this.onTap = true,
      this.isOnProfilePage = false,
      this.onThread = false});

  final Map<String, dynamic> content;
  final bool isOnProfilePage;
  final bool onTap;
  final bool onThread;

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  List<dynamic> comments = [];
  List<dynamic> downvotes = [];
  bool isQuestionLoading = true;
  int? lenComments;
  Map<String, dynamic> question = {};
  List<dynamic> reposters = [];
  List<dynamic> upvotes = [];
  bool showMore = true;
  double? contentHeight;
  Offset? contentPosition;
  GlobalKey contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    upvotes = widget.content['upvotes'];
    downvotes = widget.content['downvotes'];
    reposters = widget.content['reposter'];
    comments = widget.content['comments'];
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.addListener(() {
      if (controlModel.actionUpdate == true) {
        //  print("From here");
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Upvote") {
          if (mounted)
            setState(() {
              downvotes.remove(controlModel.actionStream!["paddyId"]);
              upvotes = controlModel.actionStream!["upvotes"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Downvote") {
          if (mounted)
            setState(() {
              upvotes.remove(controlModel.actionStream!["paddyId"]);
              downvotes = controlModel.actionStream!["downvotes"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Repost") {
          if (mounted)
            setState(() {
              reposters = controlModel.actionStream!["reposter"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Comment") {
          if (mounted)
            setState(() {
              lenComments = controlModel.actionStream!["comments"];
            });
          controlModel.setActionUpdate(false);
        }
      }
      if (controlModel.commentOrAnswerUpdate == true) {
        // if (controlModel.commentOrAnswerpaddyId) {
        if (controlModel.commentOrAnswerpaddyId == widget.content["_id"]) {
          if (mounted)
            setState(() {
              widget.content['comments'] = comments + [{}];
              lenComments = comments.length + 1;
              comments = comments + [{}];
            });
          controlModel.setCommentOrAnswerMade(false);
        }
      }
    });
    getQuestion();
  }

  getQuestion() async {
    setState(() {
      isQuestionLoading = true;
    });
    question = await getQuestionById(
        context,
        widget.content["question"] is Map
            ? widget.content["question"]["_id"]
            : widget.content["question"]);
    //  print("QUESTION: $question");
    setState(() {
      isQuestionLoading = false;
    });
  }

  upvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (upvotes.contains(userModel.id)) {
      setState(() {
        upvotes.remove(userModel.id);
      });
      await upvoteAnswer(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        upvotes.add(userModel.id);
        downvotes.remove(userModel.id);
      });
      await upvoteAnswer(context, widget.content["_id"], {"action": "upvote"});
    }
  }

  downvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (downvotes.contains(userModel.id)) {
      setState(() {
        downvotes.remove(userModel.id);
      });
      await downvoteAnswer(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        downvotes.add(userModel.id);
        upvotes.remove(userModel.id);
      });
      await downvoteAnswer(
          context, widget.content["_id"], {"action": "downvote"});
    }
  }

  repostContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (reposters.contains(userModel.id)) {
      setState(() {
        reposters.remove(userModel.id);
      });
      await repost(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        reposters.add(userModel.id);
      });
      await repost(context, widget.content["_id"], {"action": "repost"});
      toastMessage("This content has been reposted", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
      // color: colors.backgroundWhite,
      width: getWidth(context),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap)
            pushNewScreen(context,
                screen: ThreadScreen(content: widget.content),
                withNavBar: false);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () => pushNewScreen(context,
                        screen: SingleTopic(content: {
                          "name": widget.content["topic"]["name"],
                          "followers": null
                        }),
                        withNavBar: false),
                    child: textControl(
                        widget.content["topic"] is Map
                            ? widget.content["topic"]["name"]
                            : "",
                        context,
                        fontWeight: FontWeight.w400,
                        size: 12,
                        color: colors.textBlue))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          widget.content["createdBy"]["_id"] == userModel.id
                              ? pushNewScreen(context,
                                  screen: ProfilePage(), withNavBar: false)
                              : pushNewScreen(context,
                                  screen:
                                      OtherProfilePage(content: widget.content),
                                  withNavBar: false);
                        },
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                widget.content["createdBy"]["profilepic"]),
                            radius: 20)),
                    SizedBox(width: getSize(context, 15)),
                    GestureDetector(
                      onTap: () {
                        widget.content["createdBy"]["_id"] == userModel.id
                            ? pushNewScreen(context,
                                screen: ProfilePage(), withNavBar: false)
                            : pushNewScreen(context,
                                screen:
                                    OtherProfilePage(content: widget.content),
                                withNavBar: false);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: getWidth(context) - 125,
                            child: Row(
                              children: [
                                Flexible(
                                  child: textControl(
                                      widget.content["createdBy"]
                                                  ["firstname"] !=
                                              null
                                          ? "${widget.content["createdBy"]["firstname"] + " " + widget.content["createdBy"]["lastname"]}"
                                          : "",
                                      context,
                                      fontWeight: FontWeight.w800,
                                      overflow: true),
                                ),
                                SizedBox(width: getSize(context, 5)),
                                textControl(
                                    "@" +
                                        widget.content["createdBy"]["username"],
                                    context,
                                    size: 10,
                                    fontWeight: FontWeight.w500),
                                SizedBox(width: getSize(context, 5)),
                                textControl(
                                    timeago.format(
                                        DateTime.parse(
                                            widget.content["createdAt"]),
                                        locale: "en_short",
                                        allowFromNow: true),
                                    context,
                                    size: 10,
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ),
                          SizedBox(height: getSize(context, 5)),
                          SizedBox(
                            width: getWidth(context) - 125,
                            child: Row(
                              children: [
                                Image.asset("assets/pngs/grad_cap.png",
                                    height: 12, width: 10),
                                SizedBox(width: getSize(context, 3)),
                                textControl(
                                    widget.content["createdBy"]
                                            ["institution"] ??
                                        "",
                                    context,
                                    fontWeight: FontWeight.w900,
                                    size: 10,
                                    color: colors.textBlue.withOpacity(0.7)),
                                // Expanded(child: SizedBox(width: 10)),
                                Spacer(),
                                textControl("Answer", context,
                                    size: 13, color: colors.paddygreen)
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: getSize(context, 5)),
                widget.content["title"] == "" || widget.content["title"] == null
                    ? SizedBox()
                    : textControl(widget.content["title"], context,
                        fontWeight: FontWeight.w800, size: 15),
                SizedBox(height: getSize(context, 5)),
                widget.content["body"] == null
                    ? SizedBox()
                    : ExpandableText(
                        text: widget.content["body"] ?? "",
                        onTap: widget.onTap,
                        images:
                            List<String>.from(widget.content["extras"] ?? []),
                      ),
                SizedBox(height: getSize(context, 10)),
                // Align(alignment: Alignment.topRight, child: textControl("Question", context, size: 13, color: colors.paddygreen)),
                SizedBox(height: getSize(context, 5)),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                                "assets/svgs/question_answered.svg",
                                height: 15,
                                width: 15),
                            onPressed: () => pushNewScreen(context,
                                screen: CommentScreen(content: widget.content),
                                withNavBar: false),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: getSize(context, 5)),
                          textControl(
                              lenComments != null
                                  ? lenComments!.toString()
                                  : comments.length.toString(),
                              context,
                              size: 12,
                              color: colors.textBlue),
                        ],
                      ),
                      Row(children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.arrow_upward,
                              size: 20,
                              color: upvotes.contains(userModel.id)
                                  ? colors.paddygreen
                                  : colors.textBlue),
                          onPressed: () async {
                            upvoteContent(context);
                          },
                        ),
                        SizedBox(width: getSize(context, 4)),
                        textControl(upvotes.length.toString(), context,
                            size: 9,
                            color: upvotes.contains(userModel.id)
                                ? colors.paddygreen
                                : colors.textBlue)
                      ]),
                      Row(children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.arrow_downward,
                                size: 20,
                                color: downvotes.contains(userModel.id)
                                    ? colors.paddygreen
                                    : colors.textBlue),
                            onPressed: () {
                              downvoteContent(context);
                            }),
                        SizedBox(width: getSize(context, 4)),
                        textControl(downvotes.length.toString(), context,
                            size: 9,
                            color: downvotes.contains(userModel.id)
                                ? colors.paddygreen
                                : colors.textBlue)
                      ]),
                      Row(
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: SvgPicture.asset("assets/svgs/refresh.svg",
                                  height: 15,
                                  width: 15,
                                  color: reposters.contains(userModel.id)
                                      ? colors.paddygreen
                                      : colors.textBlue),
                              onPressed: () {
                                repostContent(context);
                              }),
                          SizedBox(width: getSize(context, 4)),
                          textControl(
                              widget.content["reposter"].length.toString(),
                              context,
                              size: 9,
                              color: widget.content["reposter"]
                                      .contains(userModel.id)
                                  ? colors.paddygreen
                                  : colors.textBlue)
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              //  print("pressed");
                              quickActionModalBottomSheet(
                                  context, widget.content,
                                  id: widget.content["_id"],
                                  type: "answer",
                                  isProfile: widget.isOnProfilePage);
                            });
                          },
                          icon: Icon(Icons.more_horiz,
                              size: 20, color: colors.blueColorOne),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints())
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: getSize(context, 10)),
            /* widget.content["isAnswer"]
                ?  */
            // isQuestionLoading
            widget.onTap
                ? /* SizedBox()
                :  */
                widget.content["question"] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.onThread
                              ? SizedBox()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: SizedBox(
                                          height: getSize(context, 15),
                                          child: VerticalDivider(
                                              color: Colors.black)),
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                            onTap: () => pushNewScreen(context,
                                                screen: SingleTopic(content: {
                                                  "name": widget
                                                      .content["topic"]["name"],
                                                  "followers": null
                                                }),
                                                withNavBar: false),
                                            child: textControl(
                                                widget.content["topic"] is Map
                                                    ? widget.content["topic"]
                                                        ["name"]
                                                    : "",
                                                context,
                                                fontWeight: FontWeight.w400,
                                                size: 12,
                                                color: colors.textBlue))),
                                  ],
                                ),
                          widget.content["question"] is Map
                              ? QuestionWidget(
                                  content: widget.content["question"],
                                  answerExtension: true)
                              : SizedBox(),
                        ],
                      )
                    : SizedBox()
                : isQuestionLoading
                    ? loaderMain(context, status: true, size: 20)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: SizedBox(
                                    height: getSize(context, 15),
                                    child:
                                        VerticalDivider(color: Colors.black)),
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                      onTap: () => pushNewScreen(context,
                                          screen: SingleTopic(content: {
                                            "name": widget.content["topic"]
                                                ["name"],
                                            "followers": null
                                          }),
                                          withNavBar: false),
                                      child: textControl(
                                          widget.content["topic"] is Map
                                              ? widget.content["topic"]["name"]
                                              : "",
                                          context,
                                          fontWeight: FontWeight.w400,
                                          size: 12,
                                          color: colors.textBlue))),
                            ],
                          ),
                          QuestionWidget(
                              content: question, answerExtension: true),
                        ],
                      )
          ],
        ),
      ),
    );
  }
}
