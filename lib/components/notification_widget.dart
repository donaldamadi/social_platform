import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/web_view.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/getXController.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationWidget extends StatefulWidget {
  final Map<String, dynamic> content;

  NotificationWidget({required this.content});

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final CounterController counterController = Get.put(CounterController());
  // bool isLoading = false;

  markAsRead(bool isRead) async {
    bool res = await markNotification(context, widget.content["_id"], {"isRead": isRead});
    if (isRead == true) {
      counterController.decrease();
    } else {
      counterController.increment();
    }
    if (res) {
      setState(() {
        widget.content["isRead"] = isRead;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    if (widget.content["personId"] == null) {
      return SizedBox();
    } else {
      return InkWell(
        onTap: () async {
          controlModel.setLoadingNotifications(true);
          //  print(widget.content);
          //  print(widget.content["personId"]["profilepic"]);
          //  print(widget.content["subType"]);
          if (widget.content["subType"] == "Follower") {
            markAsRead(true);
            pushNewScreen(context, screen: OtherProfilePage(content: widget.content["personId"]));
          }
          if (widget.content["subType"] == "Repost") {
            markAsRead(true);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Upvote") {
            markAsRead(true);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Resource") {
            markAsRead(true);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Comment") {
            markAsRead(true);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Post") {
            markAsRead(true);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Reask") {
            markAsRead(true);
            Map<String, dynamic> data = await getQuestionById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Question") {
            markAsRead(true);
            Map<String, dynamic> data = await getQuestionById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          if (widget.content["subType"] == "Answer") {
            //  print(widget.content);
            Map<String, dynamic> data = await getPostsOrResourcesById(context, widget.content["paddyId"]["_id"]);
            pushNewScreen(context, screen: ThreadScreen(content: data), withNavBar: false);
            // markAsRead(true);
            // Map<String, dynamic> data = await getQuestionById(context, widget.content["paddyId"]["_id"]);
            // pushNewScreen(context, screen: ThreadScreen(content: data));
          }
          controlModel.setLoadingNotifications(false);
        },
        child: Container(
          color: widget.content["isRead"] ? Colors.transparent : colors.paddygreen.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        widget.content["subType"] == "Comment" ||
                                widget.content["subType"] == "Question" ||
                                widget.content["subType"] == "Answer" ||
                                widget.content["subType"] == "Resource"
                            ? SvgPicture.asset("assets/svgs/question_answered.svg", color: colors.paddygreen, height: 15)
                            : widget.content["subType"] == "Repost" || widget.content["subType"] == "Reask"
                                ? SvgPicture.asset("assets/svgs/refresh.svg", color: colors.paddygreen, height: 15)
                                : widget.content["subType"] == "Mention"
                                    ? SvgPicture.asset("assets/svgs/at.svg", color: colors.paddygreen, height: 15)
                                    : widget.content["subType"] == "Upvote"
                                        ? Icon(Icons.arrow_upward, color: colors.paddygreen, size: 15)
                                        : widget.content["subType"] == "Follow"
                                            ? SvgPicture.asset("assets/svgs/follow.svg", color: colors.paddygreen, height: 15)
                                            : widget.content["subType"] == "Topic"
                                                ? SvgPicture.asset("assets/svgs/topics_icon.svg", color: colors.paddygreen, height: 15)
                                                : SizedBox(),
                        SizedBox(width: getSize(context, 15)),
                        InkWell(
                          onTap: () => pushNewScreen(context, screen: OtherProfilePage(content: widget.content["personId"]), withNavBar: false),
                          child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.content["personId"] != null ? (widget.content["personId"]["profilePic"] ?? "") : ""),
                              radius: getSize(context, 15)),
                        )
                      ],
                    ),
                    textControl(timeago.format(DateTime.parse(widget.content["createdAt"]), locale: "en_short", allowFromNow: true), context,
                        color: Colors.black.withOpacity(0.4)),
                  ],
                ),
                SizedBox(height: getSize(context, 10)),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: widget.content["personId"] != null ? widget.content["personId"]["username"] : "",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fonts.avenir, letterSpacing: 0.3, color: Colors.black)),
                      TextSpan(
                          text: " " + widget.content["body"], style: TextStyle(fontFamily: fonts.avenir, letterSpacing: 0.3, color: Colors.black)),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: textControl(widget.content["paddyId"] != null ? parseHtmlString(widget.content["paddyId"]["body"] ?? "") : "", context,
                          overflow: true),
                    )),
                    PopupMenuButton(
                      padding: EdgeInsets.zero,
                      child: Icon(Icons.more_horiz_rounded),
                      itemBuilder: (context) => [
                        // PopupMenuItem(
                        //   value: 1,
                        //   child: Row(
                        //     children: <Widget>[
                        //       Padding(
                        //         padding: const EdgeInsets.fromLTRB(2, 2, 12, 2),
                        //         child: SvgPicture.asset(
                        //             "assets/svgs/block_user.svg",
                        //             height: 15),
                        //       ),
                        //       textControl("Remove Notification", context)
                        //     ],
                        //   ),
                        // ),
                        PopupMenuItem(
                          onTap: () {
                            Navigator.pop(context);
                            //  print("Reporttt");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => MyWebView(
                                    title: 'Report Content', selectedUrl: 'https://studentpaddy.com/report/${widget.content["paddyId"]["_id"]}}')));
                          },
                          value: 0,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 2, 12, 2),
                                child: SvgPicture.asset("assets/svgs/report_content.svg", height: 15),
                              ),
                              textControl("Report Content", context)
                            ],
                          ),
                        ),
                        // PopupMenuItem(
                        //   onTap: () => widget.content["isRead"]
                        //       ? markAsRead(false)
                        //       : markAsRead(true),
                        //   value: 2,
                        //   child: Row(
                        //     children: <Widget>[
                        //       Padding(
                        //         padding: const EdgeInsets.fromLTRB(2, 2, 12, 2),
                        //         child: Icon(Icons.check_circle_outline, size: 15),
                        //       ),
                        //       textControl(
                        //           widget.content["isRead"]
                        //               ? "Mark as unread"
                        //               : "Mark as read",
                        //           context)
                        //     ],
                        //   ),
                        // ),
                      ],
                    )
                    // IconButton(icon: Icon(Icons.more_horiz_rounded, size: 15), onPressed: () {}, padding: EdgeInsets.zero, constraints: BoxConstraints()),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
