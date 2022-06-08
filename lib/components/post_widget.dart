import 'package:eventify/eventify.dart' as eventify;
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
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/comment.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final bool onTap;
  final bool isOnProfilePage;

  PostWidget(
      {required this.content, this.onTap = true, this.isOnProfilePage = false});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  List<dynamic> upvotes = [];
  List<dynamic> downvotes = [];
  List<dynamic> reposters = [];
  List<dynamic> comments = [];
  int? lenComments;
  bool showMore = true;
  eventify.EventEmitter emitter = eventify.EventEmitter();

  @override
  void initState() {
    super.initState();
    //  print(showMore);
    // emitter.on("add", this, (ev, context) {
    //   //  print(ev.eventData);
    // });
    // emitter.emit("change", null, {
    //   "count": 0,
    // });
    //  print("Initializing Post widget");
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
              reposters = controlModel.actionStream!["reposts"];
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
    if (widget.onTap == false) {
      controlModel.socket.on("paddy-stream", (data) {
        //  print(data);
        setActionState(data);
      });
    }
  }

  /// Real-time update of the number of upvotes, downvotes, e.t.c.
  setActionState(dynamic data) {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.setActionStream(data);
    controlModel.setActionUpdate(true);
  }

  upvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (upvotes.contains(userModel.id)) {
      setState(() {
        upvotes.remove(userModel.id);
        emitter.emit("change", null, {
          "count": upvotes.length,
        });
      });
      await upvote(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        upvotes.add(userModel.id);
        downvotes.remove(userModel.id);
      });
      await upvote(context, widget.content["_id"], {"action": "upvote"});
    }
  }

  downvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (downvotes.contains(userModel.id)) {
      setState(() {
        downvotes.remove(userModel.id);
      });
      await downvote(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        downvotes.add(userModel.id);
        upvotes.remove(userModel.id);
      });
      await downvote(context, widget.content["_id"], {"action": "downvote"});
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                  onTap: () => pushNewScreen(context,
                      screen: SingleTopic(content: {
                        "name": widget.content["topic"]["name"],
                        "followers": []
                      }),
                      withNavBar: false),
                  child: textControl(widget.content["topic"] is Map ? widget.content["topic"]["name"] : "", context,
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
                    children: <Widget>[
                      widget.content["title"] == "" ||
                              widget.content["title"] == null
                          ? SizedBox()
                          : textControl(widget.content["title"], context,
                              fontWeight: FontWeight.w900, size: 16),
                      SizedBox(height: getSize(context, 5)),
                      ExpandableText(
                        text: widget.content["body"] ?? "",
                        onTap: widget.onTap,
                        images:
                            List<String>.from(widget.content["extras"] ?? []),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: getSize(context, 10)),
              Container(
                height: getSize(context, 40),
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
                        textControl(reposters.length.toString(), context,
                            size: 9,
                            color: reposters.contains(userModel.id)
                                ? colors.paddygreen
                                : colors.textBlue)
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            //  print("pressed");
                            quickActionModalBottomSheet(context, widget.content,
                                id: widget.content["_id"],
                                type: "post",
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
          SizedBox(width: getSize(context, 20)),
          // divider(context)
        ],
      ),
    );
  }
}
