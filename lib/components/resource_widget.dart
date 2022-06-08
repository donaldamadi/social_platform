import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/image_viewer.dart';
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
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ResourceWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final bool onTap;
  final bool isOnProfilePage;

  ResourceWidget(
      {required this.content, this.onTap = true, this.isOnProfilePage = false});

  @override
  _ResourceWidgetState createState() => _ResourceWidgetState();
}

class _ResourceWidgetState extends State<ResourceWidget> {
  List<dynamic> upvotes = [];
  List<dynamic> downvotes = [];
  List<dynamic> reposters = [];
  List<dynamic> comments = [];
  int? lenComments;
  VideoPlayerController controller = VideoPlayerController.network("");
  BetterPlayerController? betterPlayerController;
  var previewData;
  TextStyle? textStyle = TextStyle(
    fontSize: 13,
    fontFamily: fonts.avenir,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.5,
  );

  @override
  void initState() {
    super.initState();
    upvotes = widget.content['upvotes'];
    downvotes = widget.content['downvotes'];
    reposters = widget.content['reposter'];
    comments = widget.content['comments'];
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    controlModel.addListener(() {
      if (controlModel.actionUpdate == true) {
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
        if (controlModel.commentOrAnswerpaddyId == widget.content["_id"]) {
          if (mounted)
            setState(() {
              widget.content['comments'] = comments + [{}];
              lenComments = comments.length + 1;
              comments.add({});
            });
          setState(() {});
          controlModel.setCommentOrAnswerMade(false);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UserOnBoardChangeNotifierModel userModel =
          Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
      if (widget.content["resource"] != null) {
        if (widget.content["resourceType"] == "Video") {
          controller = VideoPlayerController.network(
              widget.content["resource"]["path"] ?? "")
            ..initialize().then((_) {
              if (userModel.userData!["data"]["settings"]["videoAutoplays"] ==
                  true) {
                controller.play();
              }
              setState(() {});
            });
        }
      }
    });
    if (widget.content["resourceType"] == "Video") {
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.content["resource"]["path"]);
      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: userModel.userData!["data"]["settings"]["videoAutoplays"],
          fit: BoxFit.contain,
          aspectRatio: 1,
          autoDetectFullscreenDeviceOrientation: true,
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    }
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  upvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (upvotes.contains(userModel.id)) {
      setState(() {
        upvotes.remove(userModel.id);
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
        // widget.content['reposter'].remove(userModel.id);
      });
      await repost(context, widget.content["_id"], {"action": "undo"});
    } else {
      setState(() {
        reposters.add(userModel.id);
        // widget.content['reposter'].add(userModel.id);
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
                        widget.content["topic"] is String
                            ? ""
                            : widget.content["topic"]["name"],
                        context,
                        fontWeight: FontWeight.w400,
                        size: 12,
                        color: colors.textBlue))),
            SizedBox(width: getSize(context, 15)),
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
                SizedBox(height: getSize(context, 20)),
                // textControl("", context, size: 15, fontWeight: FontWeight.w700),
                textControl(
                    widget.content["resource"] != null
                        ? widget.content["resource"]["caption"]
                        : widget.content["link"] == null
                            ? ""
                            : widget.content["link"]["title"],
                    context,
                    size: 16,
                    fontWeight: FontWeight.w900),
                SizedBox(height: getSize(context, 15)),
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
                      children: [
                        widget.content["resourceType"] == "Image"
                            ? GestureDetector(
                                onTap: () => pushNewScreen(context,
                                    screen: ImageViewer(
                                        imageUrl: widget.content["resource"]
                                                ["path"] ??
                                            ""),
                                    withNavBar: false),
                                child: Container(
                                    height: getSize(context, 205),
                                    width: getWidth(context),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      // color: colors.paddygreen,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      image: DecorationImage(
                                          image: NetworkImage(widget
                                              .content["resource"]["path"]),
                                          fit: BoxFit.cover),
                                    )))
                            : widget.content["resourceType"] == "Video"
                                ? GestureDetector(
                                    // onTap: () => pushNewScreen(context, screen: VideoPlayerWidget(videoUrl: widget.content["resource"]["path"])),
                                    child: Container(
                                        height: getSize(context, 205),
                                        width: getWidth(context),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: SizedBox.expand(
                                          // child: GestureDetector(
                                          //   onTap: () => pushNewScreen(context,
                                          //       screen: VideoPlayerWidget(videoUrl: widget.content["resource"]["path"]), withNavBar: false),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: BetterPlayer(
                                              controller:
                                                  betterPlayerController!,
                                            ),
                                          ),
                                          // ),
                                        )),
                                  )
                                : widget.content["resourceType"] == "Link"
                                    ? GestureDetector(
                                        onTap: () {
                                          if (widget.onTap) {
                                            pushNewScreen(context,
                                                screen: ThreadScreen(
                                                    content: widget.content),
                                                withNavBar: false);
                                          } else {
                                            launchURL(
                                                widget.content["link"]["url"]);
                                          }
                                        },
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: getSize(context, 150),
                                              width: getWidth(context),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                // color: colors.paddygreen,
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        widget.content["link"]
                                                            ["img"]),
                                                    fit: BoxFit.cover),
                                                // borderRadius: BorderRadius.all(Radius.circular(14)),
                                              ),
                                            ),
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      getSize(context, 90)),
                                              padding: EdgeInsets.all(8),
                                              child: SizedBox(
                                                child: textControl(
                                                    widget.content["link"]
                                                        ["description"],
                                                    context,
                                                    size: 12),
                                              ),
                                              width: getWidth(context),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF0F0F0),
                                                // image: DecorationImage(image: NetworkImage(widget.content["link"]["img"]), fit: BoxFit.cover),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                              ),
                                            ),
                                            SizedBox(
                                                height: getSize(context, 10)),
                                            textControl(
                                                widget.content["link"]["url"],
                                                context,
                                                color: colors.paddygreen)
                                          ],
                                        )),
                                      )
                                    : widget.content["resourceType"] == "File"
                                        ? Container(
                                            height: getSize(context, 205),
                                            width: getWidth(context),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                // color: colors.paddygreen,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: SizedBox.expand(
                                              child: GestureDetector(
                                                onTap: () => launchURL(
                                                    widget.content["resource"]
                                                        ["path"]),
                                                child: Center(
                                                  child: Stack(
                                                    children: [
                                                      widget.content["resource"][
                                                                  "mimetype"] ==
                                                              "application/pdf"
                                                          ? Center(
                                                              child: Image.asset(
                                                                  "assets/pngs/pdf.png",
                                                                  height: 100))
                                                          : (widget.content["resource"][
                                                                      "mimetype"] ==
                                                                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
                                                              ? Center(
                                                                  child: Image.asset(
                                                                      "assets/pngs/word.png",
                                                                      height:
                                                                          100))
                                                              : Center(
                                                                  child: Icon(
                                                                      Icons.insert_drive_file,
                                                                      size: 100,
                                                                      color: colors.paddygreen)),
                                                      // Center(child: textControl(widget.content["resource"]["mimetype"].toString(), context))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))
                                        : Container(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getSize(context, 5)),
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
                              quickActionModalBottomSheet(
                                  context, widget.content,
                                  id: widget.content["_id"],
                                  type: "resource",
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
            // divider(context)
          ],
        ),
      ),
    );
  }
}
