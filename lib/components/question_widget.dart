import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/expandable_text.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/answer_question.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class QuestionWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final bool onTap;
  final bool answerExtension;
  final bool fromDubs;
  final bool isOnProfilePage;

  QuestionWidget(
      {required this.content,
      this.onTap = true,
      this.answerExtension = false,
      this.fromDubs = false,
      this.isOnProfilePage = false});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  List<dynamic> reaskers = [];
  List<dynamic> answers = [];
  int? lenAnswers;
  bool showMore = true;
  double? contentHeight;
  Offset? contentPosition;
  GlobalKey contentKey = GlobalKey();

  reaskContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (reaskers.contains(userModel.id)) {
      setState(() {
        reaskers.remove(userModel.id);
        // widget.content["reasker"].remove(userModel.id);
      });
      await reask(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        reaskers.add(userModel.id);
        // widget.content["reasker"].add(userModel.id);
      });
      toastMessage("This question has been re-asked", context);
      await reask(context, widget.content["_id"], {"action": "reask"});
    }
  }

  @override
  void initState() {
    super.initState();
    answers = widget.content["answers"];
    reaskers = widget.content["reasker"];
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.addListener(() {
      if (controlModel.actionUpdate == true) {
        //  print("From here");
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Answer") {
          if (mounted)
            setState(() {
              lenAnswers = controlModel.actionStream!["answers"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] &&
            controlModel.actionStream!["type"] == "Reask") {
          if (mounted)
            setState(() {
              reaskers = controlModel.actionStream!["reasks"];
            });
          controlModel.setActionUpdate(false);
        }
      }
      if (controlModel.commentOrAnswerUpdate == true) {
        if (controlModel.commentOrAnswerpaddyId == widget.content["_id"]) {
          if (mounted)
            setState(() {
              widget.content['answers'] = answers + [{}];
              lenAnswers = answers.length + 1;
              answers = answers + [{}];
            });
          setState(() {});
          controlModel.setCommentOrAnswerMade(false);
        }
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) => getSizes());
  }

  // getSizes() {
  //   //  print("Getting Height");
  //   //  print(widget.content["type"]);
  //   if (contentHeight == null) {
  //     if (contentKey.currentContext != null) {
  //       RenderBox renderBoxRed =
  //           contentKey.currentContext?.findRenderObject() as RenderBox;
  //       final sizeRed = renderBoxRed.size;
  //       contentHeight = sizeRed.height;
  //       contentPosition = renderBoxRed.localToGlobal(Offset.zero);
  //       // //  print(contentHeight);
  //       // //  print(contentPosition);
  //       setState(() {
  //         showMore = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
      // color: colors.backgroundWhite,
      width: getWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.topRight,
              child: widget.answerExtension
                  ? SizedBox()
                  : widget.fromDubs
                      ? SizedBox()
                      : GestureDetector(
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
                              screen: OtherProfilePage(content: widget.content),
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
                                    widget.content["createdBy"]["firstname"] !=
                                            null
                                        ? "${widget.content["createdBy"]["firstname"] + " " + widget.content["createdBy"]["lastname"]}"
                                        : "",
                                    context,
                                    fontWeight: FontWeight.w800,
                                    overflow: true),
                              ),
                              SizedBox(width: getSize(context, 5)),
                              textControl(
                                  "@" + widget.content["createdBy"]["username"],
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
                        Row(
                          children: [
                            Image.asset("assets/pngs/grad_cap.png",
                                height: getSize(context, 12),
                                width: getSize(context, 10)),
                            SizedBox(width: getSize(context, 3)),
                            textControl(
                                widget.content["createdBy"]["institution"] ??
                                    "",
                                context,
                                fontWeight: FontWeight.w900,
                                size: 10,
                                color: colors.textBlue.withOpacity(0.7)),
                            SizedBox(width: getSize(context, 10)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: getSize(context, 5)),
              GestureDetector(
                onTap: () {
                  if (widget.onTap)
                    pushNewScreen(context,
                        screen: ThreadScreen(content: widget.content),
                        withNavBar: false);
                },
                child: Container(
                  width: getWidth(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.content["title"] == "" ||
                              widget.content["title"] == null
                          ? SizedBox()
                          : textControl(widget.content["title"], context,
                              fontWeight: FontWeight.w900, size: 16),
                      SizedBox(height: getSize(context, 5)),
                      widget.content["body"] == null
                          ? SizedBox()
                          : ExpandableText(
                              text: widget.content["body"],
                              onTap: widget.onTap,
                              images: List<String>.from(
                                  widget.content["extras"] ?? []),
                            )
                    ],
                  ),
                ),
              ),
              SizedBox(height: getSize(context, 15)),
              Container(
                  child: Row(
                children: [
                  Expanded(
                    child: Row(children: [
                      IconButton(
                        icon: SvgPicture.asset(
                            "assets/svgs/question_answered.svg"),
                        onPressed: () => pushNewScreen(context,
                            screen: AnswerQuestion(content: widget.content),
                            withNavBar: false),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: getSize(context, 5)),
                      textControl(
                          lenAnswers != null
                              ? lenAnswers.toString()
                              : answers.length.toString(),
                          context,
                          size: 12,
                          color: colors.textBlue),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      IconButton(
                        icon: SvgPicture.asset("assets/svgs/refresh.svg",
                            color: reaskers.contains(userModel.id)
                                ? colors.paddygreen
                                : colors.textBlue),
                        onPressed: () {
                          reaskContent(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: getSize(context, 5)),
                      textControl(reaskers.length.toString(), context,
                          size: 12,
                          color: reaskers.contains(userModel.id)
                              ? colors.paddygreen
                              : colors.textBlue),
                    ]),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          //  print("pressed");
                          quickActionModalBottomSheet(context, widget.content,
                              id: widget.content["_id"],
                              type: "question",
                              isProfile: widget.isOnProfilePage);
                        });
                      },
                      icon: Icon(Icons.more_horiz,
                          size: 20, color: colors.blueColorOne),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: textControl("Question", context,
                            size: 12, color: colors.paddygreen)),
                  )
                ],
              ))
            ],
          ),
          SizedBox(height: getSize(context, 10)),
          // divider(context)
        ],
      ),
    );
  }
}
