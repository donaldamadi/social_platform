import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/inputFields.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup3.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class AddAFile extends StatefulWidget {
  const AddAFile({Key? key}) : super(key: key);

  @override
  _AddAFileState createState() => _AddAFileState();
}

class _AddAFileState extends State<AddAFile> {
  List<String> topics = [];
  bool addTopic = false;
  List<Communities> commList = [];
  List<String> communitiesPicked = [];
  bool topicExpanded = false;
  int charCount = 0;
  String? filePath;
  bool isLoading = false;
  Map<String, dynamic>? uploadResponse;
  TextEditingController captionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  String? topic;
  File? file;
  bool uploadLoading = false;

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

  uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result.files.single.path!);
      int sizeInBytes = file!.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 50) {
        toastMessage("File size should be less than 50MB", context);
      } else {
        setState(() {
          isLoading = true;
        });
        uploadResponse = await upload(context, file!.path);
        setState(() {
          isLoading = false;
        });
      }
    } else {
    }
  }

  uploadFileOnline(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    if (topic == null || topic!.isEmpty) {
      toastMessage("Please add a topic", context);
    } else if (captionController.text.isEmpty) {
      toastMessage("Caption cannot be left empty", context);
    } else if (isLoading) {
      toastMessage("Your file is still uploading", context);
    } else if (uploadResponse == null || uploadResponse!["success"] != true) {
      toastMessage("Please re-upload your file", context);
    } else {
      setState(() {
        isLoading = true;
      });
      bool res = await addResource(
        context,
        addTopic
            ? {
                "path": uploadResponse!["data"]["path"],
                "title": captionController.text,
                "topic": topic,
                "community": communitiesPicked,
                "mimetype": uploadResponse!["data"]["mimeType"].toString()
              }
            : {
                "path": uploadResponse!["data"]["path"],
                "title": captionController.text,
                "topic": topic,
                "mimetype": uploadResponse!["data"]["mimeType"].toString()
              },
      );
      if (res) {
        toastSuccess("Your file has been uploaded", context);
        userModel.setUpdatedResult(true);
        controlModel.setUpdateTopicList(true);
        Navigator.pop(context);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, "Upload a File"),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              //physics: BouncingScrollPhysics(),
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
                          text: "Upload",
                          onPressed: () => uploadFileOnline(context),
                          height: 30,
                          width: 65),
                      // GestureDetector(onTap: () => uploadFileOnline(context), child: textControl("Upload", context, color: colors.paddygreen)),
                    ],
                  ),
                ),
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
                              backgroundImage: NetworkImage(
                                  userModel.userData!["data"]["profilepic"])),
                          // SizedBox(width: getSize(context, 10)),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Image.asset("assets/pngs/grad_cap.png",
                                        height: 10),
                                    SizedBox(width: getSize(context, 7)),
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
                  child: Row(children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: addTopic
                            ? CustomTextField(
                                maxLength: 50,
                                maxLines: null,
                                header: "",
                                hintText: "Type in new topic",
                                borderColor: colors.blueColorOne,
                                height: 70,
                                onChanged: (value) {
                                  topic = value;
                                })
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
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
                        });
                      },
                      icon: Icon(Icons.add_circle, size: 34),
                      color: colors.blueColorOne,
                      padding: EdgeInsets.only(left: 10),
                    )
                  ]),
                ),
                SizedBox(height: getSize(context, 30)),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: CustomTextField(
                //     hintText: "",
                //     controller: titleController,
                //     header: "Title (Optional)",
                //     headerTextColor: colors.textBlue,
                //     headerTextSize: 18,
                //     border: false,
                //     multiline: true,
                //   ),
                // ),
                // SizedBox(height: getSize(context, 20)),
                addTopic
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  topicExpanded = !topicExpanded;
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  textControl(
                                      "Tag Associated Community ", context,
                                      size: 12, color: colors.paddygreen),
                                  topicExpanded
                                      ? Transform.rotate(
                                          angle: 4.65,
                                          child: Icon(Icons.keyboard_arrow_down,
                                              size: 18,
                                              color: colors.paddygreen))
                                      : Icon(Icons.keyboard_arrow_down,
                                          size: 18, color: colors.paddygreen),
                                ],
                              ),
                            ),
                            SizedBox(height: getSize(context, 15)),
                            topicExpanded
                                ? Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children:
                                        List.generate(commList.length, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          commList[index].isChosen =
                                              !commList[index].isChosen!;
                                          if (commList[index].isChosen!) {
                                            communitiesPicked.add(
                                                commList[index].community!);
                                          } else {
                                            communitiesPicked.remove(
                                                commList[index].community);
                                          }
                                          //  print(communitiesPicked);
                                          setState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: commList[index].isChosen!
                                                  ? colors.paddygreen
                                                  : Colors.transparent,
                                              border: commList[index].isChosen!
                                                  ? Border()
                                                  : Border.all()),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: textControl(
                                                commList[index].community!,
                                                context,
                                                color: commList[index].isChosen!
                                                    ? Colors.white
                                                    : Colors.black
                                                        .withOpacity(0.6)),
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
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          height: getSize(context, 100),
                          width: getSize(context, 200),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: colors.borderGrey.withOpacity(0.5))),
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.topRight,
                                  child: loaderMain(context,
                                      status: isLoading, size: 10)),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.file_copy_outlined,
                                        color: Color(0xFF323232), size: 45),
                                    file != null
                                        ? textControl(
                                            /*"${file!.path}"*/ "File Added",
                                            context,
                                            size: 10,
                                            overflow: true)
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    // SizedBox(width: getSize(context, 20)),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          uploadFile(context);
                        },
                        child: textControl("Add File", context,
                            color: colors.paddygreen),
                      ),
                    ),
                    SizedBox(height: 50)
                  ],
                )
              ],
            ),
            Positioned(
              bottom: getSize(context, 0),
              left: getSize(context, 0),
              child: Column(
                children: [
                  Container(
                    color: colors.backgroundWhite,
                    width: getWidth(context),
                    child: GestureDetector(
                      onTap: () {
                        quickActionModalBottomSheet2(context,
                            extraPop: true, type: QuickActions.file);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            textControl("Upload a File", context,
                                color: colors.paddygreen),
                            SizedBox(width: getSize(context, 5)),
                            Icon(Icons.keyboard_arrow_down_outlined,
                                color: colors.paddygreen, size: 19)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: getWidth(context),
                    decoration: BoxDecoration(
                      color: colors.backgroundWhite,
                      border: Border(
                        top: BorderSide(
                            width: 0.5, color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: captionController,
                            keyboardType: TextInputType.multiline,
                            maxLength: 200,
                            onChanged: (value) {
                              setState(() {
                                charCount = value.length;
                              });
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                hintText: "Caption (Required)",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: colors.textBlue)),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: textControl("$charCount/200", context,
                                color: colors.textGrey))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
