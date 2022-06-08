import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_summernote/flutter_summernote.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup3.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AnswerQuestion extends StatefulWidget {
  AnswerQuestion({required this.content});

  final Map<String, dynamic> content;

  @override
  _AnswerQuestionState createState() => _AnswerQuestionState();
}

class _AnswerQuestionState extends State<AnswerQuestion> {
  TextEditingController answerController = TextEditingController();
  GlobalKey contentKey = GlobalKey();
  HtmlEditorController htmlController = HtmlEditorController();
  // String? text;
  bool isLoading = false;
  bool addTopic = false;
  List assetImages = [];
  List<AssetEntity>? assets = [];
  TextEditingController bodyController = TextEditingController();
  List<Communities> commList = [];
  List<String> communitiesPicked = [];
  File? file;
  XFile? image;
  String? imageString;
  bool isImageUploading = false;
  ImagePicker picker = ImagePicker();
  String? profilepic;
  List<String> tempAssets = [];
  // HtmlEditorController htmlController = HtmlEditorController();
  String? text = "";

  TextEditingController titleController = TextEditingController();
  String? topic;
  TextEditingController topicController = TextEditingController();
  bool topicExpanded = false;
  List<String> topics = [];
  Map<String, dynamic>? uploadResponse;

  sendAnswer() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    await setAnswerText(context);
    // text = await keyEditor.currentState!.getText();
    // text = await keyEditor.currentState!.getText();
    // htmlController.getText().then((value) => text = value);
    //  print(text);
    if (controlModel.answerText == null || controlModel.answerText == "") {
      toastError("Please input a valid answer", context);
    } else {
      controlModel.answerQuestion(widget.content["_id"]);
    }
  }

  Future<void> pickImages() async {
    assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          requestType: assets!.any((element) => element.duration > 0)
              ? RequestType.video
              : RequestType.image,
          maxAssets: 4,
          selectedAssets: assets,
          filterOptions: FilterOptionGroup(
              videoOption: FilterOption(
                  durationConstraint: DurationConstraint(
            max: Duration(seconds: 10),
          )))),
    );
    print(assets);
    getImages();
  }

  getImages() async {
    List tempAssets = [];
    if (assets != null)
      for (var i in assets!) {
        String path = "";
        i.file.then((value) {
          print(value?.path);
          path = value!.path;
          tempAssets.add(path);
        });
      }
    assetImages = tempAssets;
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {});
    });
  }

  getAnswerText() async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    htmlController.setText(controlModel.answerText ?? "");
    assets = controlModel.answerAssetList;
    getImages();
    setState(() {});
  }

  Future<void> setAnswerText(BuildContext context) async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    text = await htmlController.getText();
    text = await htmlController.getText();
    controlModel.setAnswerAssetList(assets!);
    controlModel.setAnswerController(htmlController);
    print(text);
    controlModel.setAnswerText(text ?? "");
  }

  clearAnswer() async {}

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        controlModel.clearAnswerText();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: customAppBar(context, "Answer", onPressed: () {
          controlModel.clearAnswerText();
          Navigator.pop(context);
        }),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
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
                            child: CircularProgressIndicator(
                                color: colors.paddygreen))
                        : SizedBox(),
                    CustomButton(
                        text: "Answer",
                        onPressed: () => sendAnswer(),
                        height: 30,
                        width: 80),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: getSize(context, 124),
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
                            height: getSize(context, 65),
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
                              widget.content["createdBy"]["firstname"] == null
                                  ? SizedBox()
                                  : textControl(
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
                                      DateTime.parse(
                                          widget.content["createdAt"]),
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
                                  widget.content["createdBy"]["institution"] ??
                                      "",
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
                                : textControl(
                                    parseHtmlString(widget.content["body"]),
                                    context,
                                    size: 12,
                                    overflow: true),
                            // SizedBox(height: getSize(context, 25)),
                            textControl(
                                "Answering @${widget.content["createdBy"]["username"]}",
                                context,
                                size: 14,
                                color: colors.paddygreen)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                CircleAvatar(
                    backgroundImage:
                        NetworkImage(userModel.userData!["data"]["profilepic"]),
                    radius: 20),
                SizedBox(height: getSize(context, 20)),
                Container(
                  height: getSize(context, 300),
                  child: HtmlEditor(
                    controller: htmlController,
                    htmlToolbarOptions: HtmlToolbarOptions(
                      toolbarPosition: ToolbarPosition.belowEditor,
                      customToolbarButtons: [
                        IconButton(
                          tooltip: "Upload Image",
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.image_outlined),
                          onPressed: () => pickImages(),
                        ),
                      ],
                      defaultToolbarButtons: [
                        StyleButtons(),
                        // FontSettingButtons(fontSizeUnit: false),
                        FontButtons(clearAll: false),
                        ColorButtons(),
                        ListButtons(listStyles: false),
                        ParagraphButtons(
                            textDirection: false,
                            lineHeight: false,
                            caseConverter: false),
                        InsertButtons(
                          picture: false,
                          video: false,
                          audio: false,
                          table: false,
                          hr: false,
                          otherFile: false,
                        )
                      ],
                    ),
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: "Type your answer here...",
                      shouldEnsureVisible: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: getSize(context, 20),
                ),
                assetImages.length < 1
                    ? SizedBox()
                    : SizedBox(
                        height: getSize(context, 120),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: assetImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: index == 0
                                  ? EdgeInsets.only(right: 5)
                                  : index == assetImages.length - 1
                                      ? EdgeInsets.only(left: 5)
                                      : index == assets!.length - 1
                                          ? EdgeInsets.only(right: 16, left: 5)
                                          : EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                  height: 70,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: colors.blueColorOne,
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image:
                                            FileImage(File(assetImages[index])),
                                      ))),
                            );
                          },
                        ),
                      ),
                // Container(
                //   height: 300,
                //   width: getWidth(context),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(14),
                //     border: Border.all(
                //       color: colors.borderGrey.withOpacity(0.7),
                //       style: BorderStyle.solid,
                //       width: 1,
                //     ),
                //   ),
                //   child: InkWell(
                //     borderRadius: BorderRadius.circular(14),
                //     onTap: () {
                //       //  print("tapped");
                //       pushNewScreen(context,
                //           screen: AnswerEditor(htmlController: htmlController),
                //           withNavBar: false);
                //     },
                //     child: SingleChildScrollView(
                //       child: Padding(
                //         padding: EdgeInsets.all(8.0),
                //         child: Html(
                //           key: contentKey,
                //           data: (controlModel.answerText == null ||
                //                   controlModel.answerText == "")
                //               ? "Start typing here..."
                //               : controlModel.answerText,
                //           style: {
                //             'html': Style(textAlign: TextAlign.start),
                //             "body": Style(
                //               margin: EdgeInsets.zero,
                //               padding: EdgeInsets.zero,
                //               textAlign: TextAlign.start,
                //               fontSize: FontSize(getSize(context, 13)),
                //               fontFamily: fonts.avenir,
                //               letterSpacing: 0.1,
                //               color: Colors.black,
                //               fontWeight: FontWeight.w400,
                //               wordSpacing: 0.4,
                //             )
                //           },
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: getSize(context, 40))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
