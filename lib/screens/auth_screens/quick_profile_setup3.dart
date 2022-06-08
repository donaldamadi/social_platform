import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/three_circles.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/navigatorPage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class FavouriteCommunities extends StatefulWidget {
  const FavouriteCommunities({Key? key}) : super(key: key);

  @override
  _FavouriteCommunitiesState createState() => _FavouriteCommunitiesState();
}

class _FavouriteCommunitiesState extends State<FavouriteCommunities> {
  List<Communities> communities = [];
  bool isLoading = false;
  bool isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    populateCommunities();
  }

  populateCommunities() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> tempComm = await getCommunities(context);
    setState(() {
      isLoading = false;
    });
    for (var i in tempComm) {
      communities.add(Communities(community: i["name"], isChosen: false));
    }
  }

  List<String> communitiesPicked = [];

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: getSize(context, 50)),
          Center(
              child: textControl("Follow Your Favorite Community", context,
                  size: 26,
                  fontWeight: FontWeight.w900,
                  spacing: 2,
                  textAlign: TextAlign.center)),
          SizedBox(height: getSize(context, 30)),
          textControl(
              "By Following a community, you will see content based on topics associated with that community.",
              context,
              size: 18,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center),
          SizedBox(height: getSize(context, 50)),
          isLoading
              ? loaderMain(context, status: true, color: colors.paddygreen)
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(communities.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        communities[index].isChosen =
                            !communities[index].isChosen!;
                        if (communities[index].isChosen!) {
                          communitiesPicked.add(communities[index].community!);
                          followUnfollowCommunity(
                              context,
                              communities[index].community!,
                              {"action": "follow"});
                        } else {
                          communitiesPicked
                              .remove(communities[index].community);
                          followUnfollowCommunity(
                              context,
                              communities[index].community!,
                              {"action": "unfollow"});
                        }
                        //  print(communitiesPicked);
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: communities[index].isChosen!
                                ? colors.paddygreen
                                : Colors.transparent,
                            border: communities[index].isChosen!
                                ? Border()
                                : Border.all()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: textControl(
                              communities[index].community!, context,
                              color: communities[index].isChosen!
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.6)),
                        ),
                      ),
                    );
                  }),
                ),
          SizedBox(height: getSize(context, 100)),
          isLoadingNextPage
              ? loaderMain(context,
                  status: true, color: colors.paddygreen, size: 50)
              : CustomButton(
                  borderRadius: 3,
                  text: "Get Started",
                  onPressed: () async {
                    /* if (communitiesPicked.length < 1) {
                      toastError("You have to follow at least one community", context);
                    } else  */
                    {
                      setState(() {
                        isLoadingNextPage = true;
                      });
                      bool result =
                          await getUserDetails(context, userModel.token!);
                      if (result) {
                        Get.off(NavigatorPage());
                      }
                    }
                  },
                  width: getWidth(context)),
          SizedBox(height: getSize(context, 30))
        ],
      ),
    ));
  }
}

class QuickProfileThree extends StatefulWidget {
  final Map<String, dynamic> data;
  QuickProfileThree({required this.data});

  @override
  _QuickProfileThreeState createState() => _QuickProfileThreeState();
}

class _QuickProfileThreeState extends State<QuickProfileThree> {
  TextEditingController aboutMeController = TextEditingController();
  String? profilePic;
  Map<String, dynamic> profileData = {};
  bool isLoading = false;

  ImagePicker picker = ImagePicker();
  XFile? image;
  File? file;

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> uploadResponse =
          await upload(context, pickedFile.path);
      //  print("uploadResponse: $uploadResponse");
      profilePic = uploadResponse["data"]["path"];
      setState(() {
        isLoading = false;
      });
    } else {
      //  print('No image selected.');
    }
  }

  save() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (profilePic == null) {
      profileData = {"bio": aboutMeController.text.trim()};
      //  print(profileData);
      //  print(userModel.token!);
      bool res = await updateUserProfile(context, profileData);
      if (res) {
        Get.to(() => FavouriteCommunities());
      }
      // toastError("Please add an image", context);
    } else if (aboutMeController.text.isEmpty || aboutMeController.text == "") {
      toastError("Please tell us a bit about yourself", context);
    } else {
      profileData = {
        "profilepic": profilePic,
        "bio": aboutMeController.text.trim()
      };
      //  print(profileData);
      //  print(userModel.token!);
      bool res = await updateUserProfile(context, profileData);
      if (res) {
        Get.to(() => FavouriteCommunities());
      }
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    Navigator.of(context).pop();

    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      Map<String, dynamic> uploadResponse =
          await upload(context, pickedFile.path);
      //  print(uploadResponse);
      profilePic = uploadResponse["data"]["path"];
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: customAppBar(context, "Profile"),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: getWidth(context),
                height: getHeight(context) * 0.3,
                decoration: BoxDecoration(
                    color: colors.paddygreen,
                    image: DecorationImage(
                        image: image == null
                            ? NetworkImage("")
                            : FileImage(file!) as ImageProvider,
                        fit: BoxFit.cover)),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 30,
                      right: 30,
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator())
                          : GestureDetector(
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
                    SizedBox(height: getSize(context, 40)),
                    textControl("About Me", context,
                        size: 19, fontWeight: FontWeight.w700),
                    SizedBox(height: getSize(context, 20)),
                    Container(
                      height: 300,
                      padding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                      child: TextField(
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
                    SizedBox(height: getSize(context, 60)),
                    Center(
                        child: CustomButton(
                            text: "Save",
                            onPressed: () => save(),
                            buttonType: ButtonType.two,
                            width: getWidth(context) * 0.75)),
                    SizedBox(height: getSize(context, 60)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: getSize(context, 30)),
                        threeCircles(3, context),
                        GestureDetector(
                            onTap: () async {
                              // Get.to(() => FavouriteCommunities());
                              setState(() {
                                isLoading = true;
                              });
                              bool result = await getUserDetails(
                                  context, userModel.token!);
                              if (result) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                              Get.offAll(NavigatorPage());
                              // UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
                              // bool result = await getUserDetails(context, userModel.token!);
                              // if (result) {
                              //   Get.off(NavigatorPage());
                              // }
                            },
                            child: textControl("Skip", context,
                                size: 17, color: colors.paddygreen))
                      ],
                    ),
                    SizedBox(height: getSize(context, 30)),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class Communities {
  final String? community;
  bool? isChosen;

  Communities({this.community, this.isChosen});
}

List communitiesData = [];
