import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/inputFields.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup3.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
// import 'package:flutter_summernote/flutter_summernote.dart';

class MakeAPost extends StatefulWidget {
  @override
  _MakeAPostState createState() => _MakeAPostState();
}

class _MakeAPostState extends State<MakeAPost> {
  bool addTopic = false;
  List assetImages = [];
  List<AssetEntity>? assets = [];
  TextEditingController bodyController = TextEditingController();
  List<Communities> commList = [];
  List<String> communitiesPicked = [];
  GlobalKey contentKey = GlobalKey();
  File? file;
  HtmlEditorController htmlController = HtmlEditorController();
  XFile? image;
  String? imageString;
  bool isImageUploading = false;
  bool isLoading = false;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        populateCommunities(context);
        getTopics(context);
      });
    });
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

  getPostText() async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    htmlController.setText(controlModel.postText ?? "");
    assets = controlModel.postAssetList;
    getImages();
    setState(() {});
  }

  Future<void> setPostText(BuildContext context) async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    text = await htmlController.getText();
    text = await htmlController.getText();
    controlModel.setPostAssetList(assets!);
    controlModel.setPostController(htmlController);
    print(text);
    controlModel.setPostText(text ?? "");
  }

  populateCommunities(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    //  print(userModel.communities);
    for (var i in userModel.communities) {
      commList.add(Communities(community: i["name"], isChosen: false));
    }
  }

  getTopics(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    for (var i in userModel.topics) {
      topics.add(i["name"]);
    }
  }

  post() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(Get.context!, listen: false);
    await setPostText(context);
    // text = await keyEditor.currentState!.getText();
    // text = await keyEditor.currentState!.getText();
    if (topic == null || topic!.isEmpty) {
      toastMessage("Please add a topic", context);
    } else if (controlModel.postText == null ||
        controlModel.postText!.isEmpty) {
      toastMessage("Body cannot be left empty", context);
    } else {
      controlModel.makePost(
          addTopic, titleController, topic ?? "", communitiesPicked);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, "Add Post"),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                          text: "Post",
                          onPressed: () => post(),
                          height: 30,
                          width: 60),
                      // GestureDetector(
                      //     onTap: () => post(),
                      //     child: textControl("Post", context,
                      //         color: colors.paddygreen)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    //physics: BouncingScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: getSize(context, 20)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: getSize(context, 40),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                        radius: getSize(context, 40),
                                        backgroundImage: NetworkImage(userModel
                                            .userData!["data"]["profilepic"])),
                                    SizedBox(width: getSize(context, 10)),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                textControl(
                                                    "${userModel.userData!["data"]["firstname"].toString().capitalizeString()} ${userModel.userData!["data"]["lastname"].toString().capitalizeString()} ",
                                                    context,
                                                    fontWeight: FontWeight.w800,
                                                    size: 13),
                                                textControl(
                                                    "@${userModel.userData!["data"]["username"]}",
                                                    context,
                                                    size: 10,
                                                    fontWeight: FontWeight.w500)
                                              ],
                                            ),
                                            Row(children: [
                                              Image.asset(
                                                  "assets/pngs/grad_cap.png",
                                                  height: 10),
                                              SizedBox(
                                                  width: getSize(context, 7)),
                                              textControl(
                                                  userModel.userData!["data"]
                                                      ["institution"],
                                                  context,
                                                  size: 10,
                                                  color: colors.blueColorOne),
                                            ])
                                          ]),
                                    )
                                  ]),
                            ),
                          ),
                          SizedBox(height: getSize(context, 20)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: addTopic
                                          ? CustomTextField(
                                              maxLines: null,
                                              maxLength: 50,
                                              header: "",
                                              hintText: "Type in new topic",
                                              borderColor: colors.blueColorOne,
                                              height: 70,
                                              onChanged: (value) {
                                                topic = value;
                                              })
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: colors.blueColorOne,
                                                  style: BorderStyle.solid,
                                                  width: 1,
                                                ),
                                              ),
                                              child: inputSelectFieldTwo(
                                                context,
                                                itemList: topics,
                                                icon: false,
                                                placeholder:
                                                    "Search for topic or click on the '+' icon",
                                                noBorder: true,
                                                fontSize: 16,
                                                onSelect: (value) {
                                                  //  print(value);
                                                  topic = value;
                                                },
                                                padding: 0,
                                              )),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        addTopic = !addTopic;
                                        topic = "";
                                      });
                                    },
                                    icon: Icon(Icons.add_circle, size: 34),
                                    color: colors.blueColorOne,
                                    padding: EdgeInsets.only(left: 10),
                                  )
                                ]),
                          ),
                          SizedBox(height: getSize(context, 20)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CustomTextField(
                              maxLength: 200,
                              maxLines: null,
                              controller: titleController,
                              hintText: "",
                              header: "Title (Optional)",
                              headerTextColor: colors.textBlue,
                              headerTextSize: 18,
                              border: false,
                              multiline: true,
                            ),
                          ),
                          SizedBox(height: getSize(context, 20)),
                          addTopic
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topicExpanded = !topicExpanded;
                                          });
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            textControl(
                                                "Tag Associated Community ",
                                                context,
                                                size: 12,
                                                color: colors.paddygreen),
                                            topicExpanded
                                                ? Transform.rotate(
                                                    angle: 4.65,
                                                    child: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 18,
                                                        color:
                                                            colors.paddygreen))
                                                : Icon(
                                                    Icons.keyboard_arrow_down,
                                                    size: 18,
                                                    color: colors.paddygreen),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: getSize(context, 15)),
                                      topicExpanded
                                          ? Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: List.generate(
                                                  commList.length, (index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    commList[index].isChosen =
                                                        !commList[index]
                                                            .isChosen!;
                                                    if (commList[index]
                                                        .isChosen!) {
                                                      communitiesPicked.add(
                                                          commList[index]
                                                              .community!);
                                                    } else {
                                                      communitiesPicked.remove(
                                                          commList[index]
                                                              .community);
                                                    }
                                                    //  print(communitiesPicked);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: commList[index]
                                                                .isChosen!
                                                            ? colors.paddygreen
                                                            : Colors
                                                                .transparent,
                                                        border: commList[index]
                                                                .isChosen!
                                                            ? Border()
                                                            : Border.all()),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: textControl(
                                                          commList[index]
                                                              .community!,
                                                          context,
                                                          color: commList[index]
                                                                  .isChosen!
                                                              ? Colors.white
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.6)),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            )
                                          : textControl(
                                              "${communitiesPicked.length} communities picked",
                                              context,
                                              color: colors.textBlue,
                                              size: 11),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(height: getSize(context, 20)),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 20),
                          //   child: textControl("Type your post here", context,
                          //       color: colors.lightGrey, size: 16),
                          // ),
                          // SizedBox(height: getSize(context, 20)),
                          Container(
                            height: getSize(context, 300),
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: HtmlEditor(
                                  controller: htmlController,
                                  htmlToolbarOptions: HtmlToolbarOptions(
                                    toolbarPosition:
                                        ToolbarPosition.belowEditor,
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
                                    hint: "Type your post here...",
                                    shouldEnsureVisible: true,
                                  ),
                                )),
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
                                            ? EdgeInsets.only(
                                                left: 16, right: 5)
                                            : index == assets!.length - 1
                                                ? EdgeInsets.only(
                                                    right: 16, left: 5)
                                                : EdgeInsets.symmetric(
                                                    horizontal: 5),
                                        child: Container(
                                            height: 70,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: colors.blueColorOne,
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: FileImage(
                                                      File(assetImages[index])),
                                                ))),
                                      );
                                    },
                                  ),
                                ),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 20),
                          //   child: Container(
                          //     height: 300,
                          //     width: getWidth(context),
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(14),
                          //       border: Border.all(
                          //         color: colors.borderGrey.withOpacity(0.7),
                          //         style: BorderStyle.solid,
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: InkWell(
                          //       borderRadius: BorderRadius.circular(14),
                          //       onTap: () {
                          //         //  print("tapped");
                          //         pushNewScreen(context,
                          //             screen: PostEditor(
                          //                 htmlController: htmlController),
                          //             withNavBar: false);
                          //       },
                          //       child: SingleChildScrollView(
                          //         child: Padding(
                          //           padding: EdgeInsets.all(8.0),
                          //           child: Html(
                          //             key: contentKey,
                          //             data: (controlModel.postText == null ||
                          //                     controlModel.postText == "")
                          //                 ? "Start typing here..."
                          //                 : controlModel.postText,
                          //             style: {
                          //               'html':
                          //                   Style(textAlign: TextAlign.start),
                          //               "body": Style(
                          //                 margin: EdgeInsets.zero,
                          //                 padding: EdgeInsets.zero,
                          //                 textAlign: TextAlign.start,
                          //                 fontSize:
                          //                     FontSize(getSize(context, 13)),
                          //                 fontFamily: fonts.avenir,
                          //                 letterSpacing: 0.1,
                          //                 color: Colors.black,
                          //                 fontWeight: FontWeight.w400,
                          //                 wordSpacing: 0.4,
                          //               )
                          //             },
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: getSize(context, 70))
                        ]),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: getSize(context, 0),
              left: getSize(context, 0),
              child: Container(
                color: colors.backgroundWhite,
                width: getWidth(context),
                child: GestureDetector(
                  onTap: () {
                    quickActionModalBottomSheet2(context,
                        extraPop: true, type: QuickActions.post);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        textControl("Add Post", context,
                            color: colors.paddygreen),
                        SizedBox(width: getSize(context, 5)),
                        Icon(Icons.keyboard_arrow_down_outlined,
                            color: colors.paddygreen, size: 19)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
