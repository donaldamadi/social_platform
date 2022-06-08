import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/autocomplete.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../components/flutter_mentions.dart' as mentions;

class CommentScreen extends StatefulWidget {
  // final VoidCallback onBack;
  CommentScreen({required this.content /* , required this.onBack */});

  final Map<String, dynamic> content;

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Map<String, dynamic>> autoCompleteList = [];
  String comment = "";
  TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  bool isSearching = false;
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  List<String> tagList = [];
  bool tagListVisible = false;
  String visibleComment = "";

  @override
  initState() {
    key.currentState?.controller?.addListener(() {});
    super.initState();
  }

  String getText() {
    return key.currentState!.controller!.text;
  }

  sendComment() async {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    // String text = getText();
    // print(text);
    // if (commentController.text.isEmpty || commentController.text == "") {
    if (comment.isEmpty || comment == "") {
      toastError("Please make a comment", context);
      // if (text.isEmpty) {
      //   toastError("Please make a comment", context);
      // }
    } else {
      setState(() {
        isLoading = true;
      });
      bool res = await addComment(context, {"body": comment}, widget.content["_id"]);
      if (res) {
        toastSuccess("You have made your comment", context);
        // userModel.setUpdatedResult(true);
        controlModel.setCommentOrPaddyId(widget.content["_id"]);
        controlModel.setCommentOrAnswerMade(true);
        Navigator.pop(context);
      }
    }
  }

  getSuggestedUsers(String key) async {
    autoCompleteList = await autoComplete(context, key);
    // debugPrint(autoCompleteList.toString(), wrapWidth: 1024);
    // .then((value) => customAutocompleteSheet(context, value));
    setState(() {
      tagListVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, "Comment"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isLoading ? Container(height: 20, width: 20, child: CircularProgressIndicator(color: colors.paddygreen)) : SizedBox(),
                  CustomButton(text: "Comment", onPressed: () => sendComment(), height: 30, width: 90),
                  // InkWell(
                  //     onTap: () => sendComment(),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: textControl("Comment", context, color: colors.paddygreen),
                  //     )),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: getSize(context, 143),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(backgroundImage: NetworkImage(widget.content["createdBy"]["profilepic"]), radius: 20),
                        Container(
                          height: getSize(context, 88),
                          width: getSize(context, 1),
                          color: Colors.black.withOpacity(0.3),
                        )
                      ],
                    ),
                    SizedBox(width: getSize(context, 10)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            tagListVisible = false;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              textControl(
                                  "${widget.content["createdBy"]["firstname"] + " " + widget.content["createdBy"]["lastname"] + " "}", context,
                                  fontWeight: FontWeight.w800),
                              textControl("@" + widget.content["createdBy"]["username"] + ".  ", context),
                              textControl(
                                  timeago.format(DateTime.parse(widget.content["createdAt"]), locale: "en_short", allowFromNow: true), context,
                                  size: 10, fontWeight: FontWeight.w500),
                            ]),
                            Row(children: [
                              Image.asset("assets/pngs/grad_cap.png", height: getSize(context, 12), width: getSize(context, 10)),
                              SizedBox(width: getSize(context, 3)),
                              textControl(widget.content["createdBy"]["institution"], context,
                                  fontWeight: FontWeight.w800, size: 10, color: colors.textBlue.withOpacity(0.7)),
                              SizedBox(width: getSize(context, 10)),
                              textControl(widget.content["type"], context, fontWeight: FontWeight.w800, size: 10, color: colors.paddygreen),
                            ]),
                            SizedBox(height: getSize(context, 5)),
                            widget.content["title"] == null
                                ? SizedBox()
                                : textControl(widget.content["title"], context, fontWeight: FontWeight.w800, size: 12),
                            widget.content["body"] == null
                                ? SizedBox()
                                : Container(
                                    height: getSize(context, 20),
                                    child: textControl(parseHtmlString(widget.content["body"]), context, size: 12, overflow: true),
                                  ),
                            SizedBox(height: getSize(context, 20)),
                            textControl("Commenting @${widget.content["createdBy"]["username"]}", context, size: 14, color: colors.paddygreen)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(backgroundImage: NetworkImage(userModel.userData!["data"]["profilepic"]), radius: 20),
                  SizedBox(width: getSize(context, 10)),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: getSize(context, 10)),
                        SizedBox(
                          height: getSize(context, 100),
                          child: mentions.FlutterMentions(
                            keyboardType: TextInputType.multiline,
                            onMarkupChanged: (val) {
                              comment = val;
                              print("val: $val");
                            },
                            onChanged: (val) {
                              visibleComment = val;
                              debugPrint(visibleComment);
                              debugPrint(comment);
                            },
                            onMentionAdd: (val) {
                              setState(() {
                                tagListVisible = false;
                              });
                              print("===> $val");
                            },
                            enableInteractiveSelection: true,
                            expands: true,
                            hideSuggestionList: false,
                            suggestionPosition: SuggestionPosition.Bottom,
                            key: key,
                            maxLines: null,
                            enableSuggestions: true,
                            decoration: InputDecoration.collapsed(hintText: ""),
                            onSearchChanged: (text, text2) {
                              debugPrint(text2);
                              getSuggestedUsers(text2);
                            },
                            mentions: [
                              Mention(
                                suggestionBuilder: (data) {
                                  return ListTile(
                                    tileColor: Colors.transparent,
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(data["profilepic"]),
                                      radius: 20,
                                    ),
                                    title: textControl("${data["firstname"].toString().trim()} ${data["lastname"].toString().trim()}", context,
                                        fontWeight: FontWeight.w800),
                                    subtitle: textControl(data["display"], context, fontWeight: FontWeight.w800),
                                  );
                                },
                                markupBuilder: (_, id, display) {
                                  return "@{{${display},${id}}}";
                                },
                                trigger: "@",
                                style: TextStyle(color: colors.paddygreen, fontWeight: FontWeight.w800),
                                data: usersList,
                              )
                            ],
                          ),
                          // child: TextField(
                          //   style: TextStyle(fontSize: getSize(context, 15)),
                          //   controller: commentController,
                          //   decoration: InputDecoration.collapsed(hintText: ""),
                          //   maxLines: null,
                          //   keyboardType: TextInputType.multiline,
                          // ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
              // tagListVisible
              //     ? Expanded(child: SizedBox()
              //         // child: ListView.builder(
              //         //   itemCount: autoCompleteList.length,
              //         //   itemBuilder: (context, index) {
              //         //     return ListTile(
              //         //       leading: CircleAvatar(
              //         //         backgroundImage: NetworkImage(
              //         //             autoCompleteList[index]["profilepic"]),
              //         //         radius: 20,
              //         //       ),
              //         //       title: textControl(
              //         //           "${autoCompleteList[index]["firstname"]} ${autoCompleteList[index]["lastname"]}",
              //         //           context,
              //         //           fontWeight: FontWeight.w800),
              //         //       subtitle: textControl(
              //         //           autoCompleteList[index]["username"], context,
              //         //           fontWeight: FontWeight.w800),
              //         //       onTap: () {
              //         //         print(autoCompleteList[index]["display"]);
              //         //         setState(() {});
              //         //       },
              //         //     );
              //         //   },
              //         // ),
              //         )
              //     : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
