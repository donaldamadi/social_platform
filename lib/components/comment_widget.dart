import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/expandable_text.dart';
import 'package:student_paddy_mobile/components/measure_widget_size.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/multi_image_viewer.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/comment.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/thread_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentWidget extends StatefulWidget {
  CommentWidget({required this.content, this.onTap = true});

  final Map<String, dynamic> content;
  final bool onTap;

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  StreamSubscription<bool>? colorStreamSub;
  List<dynamic> comments = [];
  double? contentHeight;
  GlobalKey contentKey = GlobalKey();
  Offset? contentPosition;
  List<dynamic> downvotes = [];
  // EventBus eventBus = EventBus();
  int? lenComments;
  List<Widget> list = [];
  Map<String, dynamic>? parent;
  List<Map<String, dynamic>> parentPaddiesList = [];
  List<dynamic> reposters = [];
  // ScrollController scrollController = ScrollController();
  bool showMore = true;
  Size childSize = Size.zero;

  List<dynamic> upvotes = [];

  @override
  void initState() {
    super.initState();
    upvotes = widget.content['upvotes'];
    downvotes = widget.content['downvotes'];
    reposters = widget.content['reposter'];
    comments = widget.content['comments'];
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    // list = [];
    controlModel.addListener(() {
      if (controlModel.actionUpdate == true) {
        //  print("From here");
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] && controlModel.actionStream!["type"] == "Upvote") {
          if (mounted)
            setState(() {
              downvotes.remove(controlModel.actionStream!["paddyId"]);
              upvotes = controlModel.actionStream!["upvotes"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] && controlModel.actionStream!["type"] == "Downvote") {
          if (mounted)
            setState(() {
              upvotes.remove(controlModel.actionStream!["paddyId"]);
              downvotes = controlModel.actionStream!["downvotes"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] && controlModel.actionStream!["type"] == "Repost") {
          if (mounted)
            setState(() {
              reposters = controlModel.actionStream!["reposter"];
            });
          controlModel.setActionUpdate(false);
        }
        if (controlModel.actionStream!["paddyId"] == widget.content["_id"] && controlModel.actionStream!["type"] == "Comment") {
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
    // if (!widget.onTap) loadNewComments();
    controlModel.eventBus.on<bool>().singleWhere((event) {
      loadParent();
      return true;
    });
    // scrollController.addListener(() {
    //   if (!widget.onTap) {
    //     debugPrint(scrollController.position.pixels.toString());
    // if (scrollController.position.atEdge) {
    //   bool isTop = scrollController.position.pixels == 0;
    //   if (isTop) {
    //     loadNewComments();
    //   }
    // }
    //   }
    // });
  }

  loadNewComments() async {
    if (widget.content["parentPaddy"] != widget.content["_id"]) {
      parent = await getPostsOrResourcesById(Get.context!, widget.content["parentPaddy"]);
      parentPaddiesList.insert(0, parent ?? {});
      setState(() {});
    }
  }

  loadParent() async {
    debugPrint("ParentPaddy: ++++++++++=================++>>>> ${widget.content["parentPaddy"]}");
    debugPrint("Parent: ++++++++++=================++>>>> ${widget.content["parent"]}");
    debugPrint("widget.content[id]: ++++++++++=================++>>>> ${widget.content["_id"]}");
    if (parentPaddiesList.isNotEmpty) {
      if ((parentPaddiesList[0]["parentpaddy"] != null && parentPaddiesList[0]["parent"] != null) &&
          parentPaddiesList[0]["parentpaddy"] == parentPaddiesList[0]["parent"]) {
        parent = await getPostsOrResourcesById(Get.context!, parentPaddiesList[0]["parentpaddy"]);
        parentPaddiesList = [parent ?? {}, ...parentPaddiesList];
        parentPaddiesList = parentPaddiesList.toSet().toList();
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parentpaddy"]}");
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parent"]}");
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy == Parent ${parentPaddiesList.length}");
        setState(() {});
      } else if (parentPaddiesList[0]["parentpaddy"] == null && parentPaddiesList[0]["paddy"] != null) {
        parent = await getPostsOrResourcesById(Get.context!, parentPaddiesList[0]["parent"]);
        parentPaddiesList = [parent ?? {}, ...parentPaddiesList];
        parentPaddiesList = parentPaddiesList.toSet().toList();
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parentpaddy"]}");
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parent"]}");
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy != Parent ${parentPaddiesList.length}");
        setState(() {});
      } else if ((parentPaddiesList[0]["parentpaddy"] != null && parentPaddiesList[0]["parent"] != null) &&
          parentPaddiesList[0]["parentpaddy"] != parentPaddiesList[0]["parent"]) {
        parent = await getPostsOrResourcesById(Get.context!, parentPaddiesList[0]["parentpaddy"]);
        parentPaddiesList = [parent ?? {}, ...parentPaddiesList];
        parentPaddiesList = parentPaddiesList.toSet().toList();
        debugPrint("++++++++++===========+++++++++++>> ParentPaddy != Parent ${parentPaddiesList.length}");
        setState(() {});
      }
    } else if (widget.content["parentPaddy"] != widget.content["_id"]) {
      parent = await getPostsOrResourcesById(Get.context!, widget.content["parent"]);
      parentPaddiesList = [parent ?? {}, ...parentPaddiesList];
      debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parentpaddy"]}");
      debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList[0]["parent"]}");
      parentPaddiesList = parentPaddiesList.toSet().toList();
      // parentPaddiesList.insert(0, parent ?? {});
      debugPrint("++++++++++===========+++++++++++>> ParentPaddy ${parentPaddiesList.length}");
      setState(() {});
    }
  }

  upvoteContent(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
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
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
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
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
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
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !widget.onTap
            ? SizedBox(
                height: childSize.height * parentPaddiesList.length,
                // height: 500,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: parentPaddiesList.length,
                    itemBuilder: (context, index) {
                      if (parent!["type"] == "Post") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MeasureSize(
                              onChange: (size) {
                                childSize = size;
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                child: PostWidget(content: parentPaddiesList[index]),
                              ),
                            ),
                          ],
                        );
                      } else if (parent!["type"] == "Question") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: QuestionWidget(content: parentPaddiesList[index]),
                            ),
                          ],
                        );
                      } else if (parent!["type"] == "Resource") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: ResourceWidget(content: parentPaddiesList[index]),
                            ),
                          ],
                        );
                      } else if (parent!["type"] == "Answer") {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                          child: AnswerWidget(content: parentPaddiesList[index], onThread: true),
                        );
                      } else if (parent!["type"] == "Comment") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: CommentWidget(content: parentPaddiesList[index], onTap: false),
                            ),
                          ],
                        );
                      } else {
                        return SelectableText("hey");
                        // return SizedBox(height: 0);
                      }
                    }),
              )
            : SizedBox(),
        // parent == null
        //     ? SizedBox()
        //     : parent!["type"] == "Post"
        //         ? Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        //             child: PostWidget(content: parent!),
        //           )
        //         : parent!["type"] == "Question"
        //             ? Padding(
        //                 padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        //                 child: QuestionWidget(content: parent!),
        //               )
        //             : parent!["type"] == "Resource"
        //                 ? Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        //                     child: ResourceWidget(content: parent!),
        //                   )
        //                 : parent!["type"] == "Answer"
        //                     ? Padding(
        //                         padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        //                         child: AnswerWidget(content: parent!, onThread: true),
        //                       )
        //                     : parent!["type"] == "Comment"
        //                         ? Padding(
        //                             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        //                             child: CommentWidget(content: parent!),
        //                           )
        //                         : SizedBox(height: 0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.onTap)
              parent == null
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(height: getSize(context, 15), child: VerticalDivider(color: Colors.black)),
                    ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () {
                      widget.content["createdBy"]["_id"] == userModel.id
                          ? pushNewScreen(context, screen: ProfilePage(), withNavBar: false)
                          : pushNewScreen(context, screen: OtherProfilePage(content: widget.content), withNavBar: false);
                    },
                    child: CircleAvatar(backgroundImage: NetworkImage(widget.content["createdBy"]["profilepic"]), radius: 20)),
                SizedBox(width: getSize(context, 15)),
                GestureDetector(
                  onTap: () {
                    widget.content["createdBy"]["_id"] == userModel.id
                        ? pushNewScreen(context, screen: ProfilePage(), withNavBar: false)
                        : pushNewScreen(context, screen: OtherProfilePage(content: widget.content), withNavBar: false);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: getWidth(context) - 115,
                        child: Row(
                          children: [
                            Flexible(
                              child: textControl(
                                  widget.content["createdBy"]["firstname"] != null
                                      ? "${widget.content["createdBy"]["firstname"] + " " + widget.content["createdBy"]["lastname"]}"
                                      : "",
                                  context,
                                  fontWeight: FontWeight.w800,
                                  overflow: true),
                            ),
                            SizedBox(width: getSize(context, 5)),
                            textControl("@" + widget.content["createdBy"]["username"], context, size: 10, fontWeight: FontWeight.w500),
                            SizedBox(width: getSize(context, 5)),
                            textControl(timeago.format(DateTime.parse(widget.content["createdAt"]), locale: "en_short", allowFromNow: true), context,
                                size: 10, fontWeight: FontWeight.w500)
                          ],
                        ),
                      ),
                      SizedBox(height: getSize(context, 5)),
                      Row(
                        children: [
                          Image.asset("assets/pngs/grad_cap.png", height: 12, width: 10),
                          SizedBox(width: getSize(context, 3)),
                          textControl(widget.content["createdBy"]["institution"] ?? "", context,
                              fontWeight: FontWeight.w900, size: 10, color: colors.textBlue.withOpacity(0.7)),
                          SizedBox(width: getSize(context, 10)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
        SizedBox(height: getSize(context, 5)),
        GestureDetector(
          onTap: () {
            if (widget.onTap) pushNewScreen(context, screen: ThreadScreen(content: widget.content), withNavBar: false);
          },
          child: Container(
            width: getWidth(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.content["title"] == "" || widget.content["title"] == null
                    ? SizedBox()
                    : textControl(widget.content["title"], context, fontWeight: FontWeight.w800),
                SizedBox(height: getSize(context, 5)),
                widget.content["body"] != null ? ExpandableText(text: markdownToHtml(widget.content["body"] ?? ""), onTap: widget.onTap) : SizedBox(),
                // if (widget.content["extras"] != null && widget.content["extras"].length > 1)SizedBox(height: getSize(context, 5)),
                multiImageViewer(context, List<String>.from(widget.content["extras"] ?? []))
              ],
            ),
          ),
        ),
        SizedBox(height: getSize(context, 5)),
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/svgs/question_answered.svg", height: 15, width: 15),
                    onPressed: () => pushNewScreen(context, screen: CommentScreen(content: widget.content), withNavBar: false),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: getSize(context, 4)),
                  textControl(lenComments != null ? lenComments!.toString() : comments.length.toString(), context, size: 9, color: colors.textBlue)
                ],
              ),
              Row(children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.arrow_upward, size: 20, color: upvotes.contains(userModel.id) ? colors.paddygreen : colors.textBlue),
                  onPressed: () async {
                    upvoteContent(context);
                  },
                ),
                SizedBox(width: getSize(context, 4)),
                textControl(upvotes.length.toString(), context, size: 9, color: upvotes.contains(userModel.id) ? colors.paddygreen : colors.textBlue)
              ]),
              Row(children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.arrow_downward, size: 20, color: downvotes.contains(userModel.id) ? colors.paddygreen : colors.textBlue),
                    onPressed: () {
                      downvoteContent(context);
                    }),
                SizedBox(width: getSize(context, 4)),
                textControl(downvotes.length.toString(), context,
                    size: 9, color: downvotes.contains(userModel.id) ? colors.paddygreen : colors.textBlue)
              ]),
              Row(
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: SvgPicture.asset("assets/svgs/refresh.svg",
                          height: 15, width: 15, color: reposters.contains(userModel.id) ? colors.paddygreen : colors.textBlue),
                      onPressed: () {
                        repostContent(context);
                      }),
                  SizedBox(width: getSize(context, 4)),
                  textControl(reposters.length.toString(), context,
                      size: 9, color: reposters.contains(userModel.id) ? colors.paddygreen : colors.textBlue)
                ],
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      //  print("pressed");
                      quickActionModalBottomSheet(context, widget.content, id: widget.content["_id"], type: "comment");
                    });
                  },
                  icon: Icon(Icons.more_horiz, size: 20, color: colors.blueColorOne),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints())
            ],
          ),
        ),
        SizedBox(width: getSize(context, 20)),
        // divider(context)
      ],
    );
  }
}
