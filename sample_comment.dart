import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> content;
  // final VoidCallback onBack;
  CommentScreen({required this.content /* , required this.onBack */});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> autoCompleteList = [];
  bool isSearching = false;
  List<String> tagList = [];
  bool active = true;
  RichTextController controller = RichTextController(
    patternMatchMap: {
      //
      //* Returns every Hashtag with red color
      //
      // RegExp(r"\B#[a-zA-Z0-9]+\b"):TextStyle(color:Colors.red),
      //
      //* Returns every Mention with blue color and bold style.
      //
      RegExp(r"\B@[a-zA-Z0-9]+\b"): TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.blue,
      ),
      //
      //* Returns every word after '!' with yellow color and italic style.
      //
      // RegExp(r"\B![a-zA-Z0-9]+\b"):TextStyle(color:Colors.yellow, fontStyle:FontStyle.italic),
      // add as many expressions as you need!
    },
    //* starting v1.2.0
    // Now you have the option to add string Matching!
    //   stringMatchMap: {
    //   "String1":TextStyle(color: Colors.red),
    //   "String2":TextStyle(color: Colors.yellow),
    //  },
    //! Assertion: Only one of the two matching options can be given at a time!

    //* starting v1.1.0
    //* Now you have an onMatch callback that gives you access to a List<String>
    //* which contains all matched strings
    onMatch: (List<String> matches) {
      // Do something with matches.
      //! P.S
      // as long as you're typing, the controller will keep updating the list.
    },
    deleteOnBack: true,
  );

  @override
  initState() {
    controller.addListener(() {
      if (isSearching == true) {
        var pos = controller.text.lastIndexOf("@");
        getSuggestedUsers(controller.text
            .substring(pos, controller.text.length)
            .replaceAll("@", ""));
        debugPrint(controller.text
            .substring(pos, controller.text.length)
            .replaceAll("@", ""));
      }
      if (active == true) {
        if ((controller.text.length == 1 && controller.text == "@") ||
            controller.text /* .trim() */ .endsWith("@") &&
                controller.text.substring(controller.text.length - 2,
                        controller.text.length - 1) ==
                    " ") {
          debugPrint("yess");
          isSearching = true;
          var pos = controller.text.lastIndexOf("@");
          getSuggestedUsers(controller.text
              .substring(pos, controller.text.length - 1)
              .replaceAll("@", ""));
        }
      }
    });
    super.initState();
  }

  getSuggestedUsers(String key) async {
    autoCompleteList = await autoComplete(context, key);
    setState(() {});
    // .then((value) => customAutocompleteSheet(context, value));
  }

  sendComment() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    if (controller.text.isEmpty || controller.text == "") {
      toastError("Please make a comment", context);
    } else {
      setState(() {
        isLoading = true;
      });
      bool res = await addComment(context,
          {"body": controller.text, "tags": tagList}, widget.content["_id"]);
      if (res) {
        toastSuccess("You have made your comment", context);
        // userModel.setUpdatedResult(true);
        controlModel.setCommentOrPaddyId(widget.content["_id"]);
        controlModel.setCommentOrAnswerMade(true);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(context, "Comment"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isLoading
                    ? Container(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(color: colors.paddygreen))
                    : SizedBox(),
                CustomButton(
                    text: "Comment",
                    onPressed: () => sendComment(),
                    height: 30,
                    width: 90),
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
                      CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.content["createdBy"]["profilepic"]),
                          radius: 20),
                      Container(
                        height: getSize(context, 88),
                        width: getSize(context, 1),
                        color: Colors.black.withOpacity(0.3),
                      )
                    ],
                  ),
                  SizedBox(width: getSize(context, 10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          textControl(
                              "${widget.content["createdBy"]["firstname"] + " " + widget.content["createdBy"]["lastname"] + " "}",
                              context,
                              fontWeight: FontWeight.w800),
                          textControl(
                              "@" +
                                  widget.content["createdBy"]["username"] +
                                  ".  ",
                              context),
                          textControl(
                              timeago.format(
                                  DateTime.parse(widget.content["createdAt"]),
                                  locale: "en_short",
                                  allowFromNow: true),
                              context,
                              size: 10,
                              fontWeight: FontWeight.w500),
                        ]),
                        Row(children: [
                          Image.asset("assets/pngs/grad_cap.png",
                              height: getSize(context, 12),
                              width: getSize(context, 10)),
                          SizedBox(width: getSize(context, 3)),
                          textControl(
                              widget.content["createdBy"]["institution"],
                              context,
                              fontWeight: FontWeight.w800,
                              size: 10,
                              color: colors.textBlue.withOpacity(0.7)),
                          SizedBox(width: getSize(context, 10)),
                          textControl(widget.content["type"], context,
                              fontWeight: FontWeight.w800,
                              size: 10,
                              color: colors.paddygreen),
                        ]),
                        SizedBox(height: getSize(context, 5)),
                        widget.content["title"] == null
                            ? SizedBox()
                            : textControl(widget.content["title"], context,
                                fontWeight: FontWeight.w800, size: 12),
                        widget.content["body"] == null
                            ? SizedBox()
                            : Container(
                                height: getSize(context, 20),
                                child: textControl(
                                    parseHtmlString(widget.content["body"]),
                                    context,
                                    size: 12,
                                    overflow: true),
                              ),
                        SizedBox(height: getSize(context, 20)),
                        textControl(
                            "Commenting @${widget.content["createdBy"]["username"]}",
                            context,
                            size: 14,
                            color: colors.paddygreen)
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                    backgroundImage:
                        NetworkImage(userModel.userData!["data"]["profilepic"]),
                    radius: 20),
                SizedBox(width: getSize(context, 10)),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: getSize(context, 10)),
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.newline,
                          onChanged: (val) {
                            // if (val.isNotEmpty) {
                            val.substring(val.length - 1) == " " || val.isEmpty
                                ? setState(() {
                                    autoCompleteList.clear();
                                    isSearching = false;
                                  })
                                : null;
                            // }
                          },
                          style: TextStyle(fontSize: getSize(context, 15)),
                          controller: controller,
                          decoration: InputDecoration.collapsed(hintText: ""),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            autoCompleteList.isNotEmpty
                ? SizedBox(
                    height: 200,
                    width: getWidth(context),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: autoCompleteList.length < 10
                          ? autoCompleteList.length
                          : 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              controller.text = controller.text.substring(
                                  0, controller.text.lastIndexOf('@') + 1);
                              controller.text = controller.text +
                                  "${autoCompleteList[index]["username"]} ";
                              setState(() {
                                active = false;
                                tagList.add(autoCompleteList[index]["_id"]);
                                autoCompleteList.clear();
                                isSearching = false;
                                controller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: controller.text.length));
                                // active = true;
                              });
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        autoCompleteList[index]["profilepic"]),
                                    radius: 20),
                                SizedBox(width: getSize(context, 10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    textControl(
                                        (autoCompleteList[index]["firstname"] ??
                                                "") +
                                            " " +
                                            (autoCompleteList[index]
                                                    ["lastname"] ??
                                                ""),
                                        context),
                                    textControl(
                                        autoCompleteList[index]["username"],
                                        context,
                                        fontWeight: FontWeight.w800),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
