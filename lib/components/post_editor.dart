import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/simpleButton.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../network/requestHandler.dart';

class PostEditor extends StatefulWidget {
  PostEditor({required this.htmlController});

  final HtmlEditorController htmlController;

  @override
  _PostEditorState createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  HtmlEditorController htmlController = HtmlEditorController();
  String? text = "";
  File? file;
  XFile? image;
  bool isImageUploading = false;
  ImagePicker picker = ImagePicker();
  String? profilepic;
  Map<String, dynamic>? uploadResponse;
  String? imageString;
  List<AssetEntity>? assets = [];
  List assetImages = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // getPostText();
    });
  }

  Future<void> pickImages() async {
    assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          requestType: assets!.any((element) => element.duration > 0)
              ? RequestType.video
              : RequestType.image,
          maxAssets: 5,
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

  setPostText(BuildContext context) async {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    await htmlController.getText().then((value) => text = value).then((value) {
      controlModel.setPostAssetList(assets!);
      controlModel.setPostController(htmlController);
      //  print(text);
      controlModel.setPostText(text ?? "");
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Container(
              height: getSize(context, 60),
              padding: EdgeInsets.symmetric(horizontal: getSize(context, 30)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  simpleButton("Load Draft", context,
                      fontSize: 15,
                      padH: 100,
                      padV: 40,
                      borderRadius: 30,
                      backColor: colors.blueColorOne,
                      onTap: () => getPostText()),
                  isImageUploading
                      ? SpinKitThreeBounce(
                          size: 20,
                          color: colors.paddygreen,
                        )
                      : SizedBox(),
                  simpleButton("submit", context,
                      fontSize: 15,
                      padH: 100,
                      padV: 40,
                      borderRadius: 30,
                      backColor: colors.paddygreen,
                      onTap: () => setPostText(context)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                      hint: "Your text here",
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
                              ? EdgeInsets.only(left: 16, right: 5)
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
                                    image: FileImage(File(assetImages[index])),
                                  ))),
                        );
                      },
                    ),
                  ),
            SizedBox(
              height: getSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}
