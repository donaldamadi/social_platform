import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/edit_profile_two.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  Map<String, dynamic>? uploadResponse;
  String? profilepic;
  Map<String, dynamic> userData = {};
  String? keyword = "";
  Map<String, dynamic>? userMap;
  bool userNameExists = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    usernameController.text = userModel.userData!["data"]["username"];
    aboutMeController.text = userModel.userData!["data"]["bio"] ?? "";
    profilepic = userModel.userData!["data"]["profilepic"];
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  ImagePicker picker = ImagePicker();
  XFile? image;
  File? file;

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      Navigator.of(context).pop();
      uploadResponse = await upload(context, file!.path);
      //  print(uploadResponse);
      if (uploadResponse != null) profilepic = uploadResponse!["data"]["path"];
    } else {
      //  print('No image selected.');
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      Navigator.of(context).pop();
      uploadResponse = await upload(context, file!.path);
      if (uploadResponse != null) profilepic = uploadResponse!["data"]["path"];
    } else {
      //  print('No image selected.');
    }
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: Icon(Icons.photo_library),
                      title: textControl('Photo Library', context),
                      onTap: () async {
                        await getImageFromGallery();
                        // Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: textControl('Camera', context),
                    onTap: () async {
                      await getImageFromCamera();
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  save() async {
    setState(() {
      isLoading = true;
    });
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    userData = {
      "username": usernameController.text.trim(),
      "profilepic": profilepic,
      "bio": aboutMeController.text.trim(),
    };
    bool res = await updateUserProfile(context, userData);
    if (res) {
      bool result = await getUserDetails(context, userModel.token!);
      if (result) {
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    }
  }

  next() async {
    userData = {
      "username": usernameController.text.trim(),
      "profilepic": profilepic,
      "bio": aboutMeController.text.trim()
    };
    pushNewScreen(context,
        screen: EditProfileTwo(data: userData), withNavBar: false);
  }

  checkUser(String keyword) async {
    userMap = await checkUsername(context, keyword);
    //  print(userMap!["data"]);
    userNameExists = userMap!["data"];
    setState(() {});
    return userMap!["data"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: customAppBar(context, "Edit Profile"),
        body: Column(
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
                        : Container(),
                    GestureDetector(
                        onTap: () => save(),
                        child: textControl("Save", context,
                            color: colors.paddygreen, size: 16)),
                  ]),
            ),
            SizedBox(height: getSize(context, 20)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: getWidth(context),
                      height: getHeight(context) * 0.3,
                      decoration: BoxDecoration(
                          color: colors.paddygreen,
                          image: DecorationImage(
                              image: image == null
                                  ? NetworkImage("$profilepic")
                                  : FileImage(file!) as ImageProvider,
                              fit: BoxFit.cover)),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 30,
                            right: 30,
                            child: GestureDetector(
                                child: Icon(Icons.camera_alt_outlined,
                                    color: Colors.white),
                                onTap: () => showPicker(context)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: getSize(context, 30)),
                          CustomTextField(
                              header: "Username",
                              hintText: "Username",
                              controller: usernameController,
                              onChanged: (val) {
                                keyword = val;
                                setState(() {
                                  if (val.isNotEmpty) {
                                    checkUser(val);
                                  } else {
                                    userMap = null;
                                  }
                                });
                              }),
                          userMap != null
                              ? userNameExists
                                  ? textControl("Username exists", context,
                                      color: colors.red, size: 12)
                                  : SizedBox()
                              : SizedBox(),
                          SizedBox(height: getSize(context, 20)),
                          textControl("About Me", context,
                              size: 19, fontWeight: FontWeight.w700),
                          SizedBox(height: getSize(context, 8)),
                          Container(
                            height: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 13),
                            child: TextField(
                              maxLength: 200,
                              style: TextStyle(fontFamily: "Avenir"),
                              controller: aboutMeController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorHeight: 19.0,
                              decoration: InputDecoration.collapsed(
                                  hintText: "Who am I ? ....."),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Color(0xFF6D6E71).withOpacity(0.6)),
                            ),
                          ),
                          SizedBox(height: getSize(context, 40)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => next(),
                                child: textControl("Next", context,
                                    size: 17, color: colors.paddygreen),
                              ),
                            ],
                          ),
                          SizedBox(height: getSize(context, 30)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
