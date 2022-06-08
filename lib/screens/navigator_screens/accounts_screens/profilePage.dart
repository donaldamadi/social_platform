import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:student_paddy_mobile/components/answer_widget.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/image_viewer.dart';
import 'package:student_paddy_mobile/components/measure_widget_size.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/post_widget.dart';
import 'package:student_paddy_mobile/components/question_widget.dart';
import 'package:student_paddy_mobile/components/resource_widget.dart';
import 'package:student_paddy_mobile/components/shimmer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/edit_profile.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_communities.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_followers.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/profile_following.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

import '../../../components/comment_widget.dart';
import '../../../components/loader.dart';
// import 'package:sticky_headers/sticky_headers.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Size childSize = Size.zero;
  File? file;
  XFile? image;
  bool isImageUploading = false;
  bool isPostLoading = true;
  bool isQuestionLoading = true;
  bool isResourceLoading = true;
  bool isBookmarkLoading = true;
  bool isMorePostLoading = false;
  bool isMoreQuestionLoading = false;
  bool isMoreResourceLoading = false;
  bool isMoreBookmarkLoading = false;
  ImagePicker picker = ImagePicker();
  List<dynamic> postList = [];
  int postPage = 1;
  ScrollController postScrollController = ScrollController();
  Map<String, dynamic> posts = {};
  String? profilepic;
  int questionPage = 1;
  ScrollController questionScrollController = ScrollController();
  Map<String, dynamic> questions = {};
  List<dynamic> questionsList = [];
  int resourcePage = 1;
  ScrollController resourceScrollController = ScrollController();
  Map<String, dynamic> resources = {};
  List<dynamic> resourcesList = [];
  int bookmarkPage = 1;
  ScrollController bookmarkScrollController = ScrollController();
  Map<String, dynamic> bookmarks = {};
  List<dynamic> bookmarksList = [];
  TabController? tabController;
  Map<String, dynamic>? uploadResponse;
  Map<String, dynamic> userData = {};
  double? contentHeight;
  Offset? contentPosition;
  GlobalKey contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    userData = userModel.userData!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSizes();
      if (tabController?.index == 0) {
        if (posts.isEmpty) getPosts(context);
      } else if (tabController?.index == 1) {
        if (questions.isEmpty) getQuestions(context);
      } else if (tabController?.index == 2) {
        if (resources.isEmpty) getResources(context);
      } else if (tabController?.index == 3) {
        if (bookmarks.isEmpty) getBookmarks(context);
      }
      tabController?.addListener(() {
        if (tabController!.indexIsChanging) {
          if (tabController?.index == 0) {
            if (posts.isEmpty) getPosts(context);
          } else if (tabController?.index == 1) {
            if (questions.isEmpty) getQuestions(context);
          } else if (tabController?.index == 2) {
            if (resources.isEmpty) getResources(context);
          } else if (tabController?.index == 3) {
            if (bookmarks.isEmpty) getBookmarks(context);
          }
        }
      });
      tabController!.animation
        ?..addListener(() {
          if (tabController!.indexIsChanging) {
            if (tabController?.index == 0) {
              if (posts.isEmpty) getPosts(context);
            } else if (tabController?.index == 1) {
              if (questions.isEmpty) getQuestions(context);
            } else if (tabController?.index == 2) {
              if (resources.isEmpty) getResources(context);
            } else if (tabController?.index == 3) {
              if (bookmarks.isEmpty) getBookmarks(context);
            }
          }
        });
      postScrollController.addListener(() {
        if (postScrollController.position.pixels ==
            postScrollController.position.maxScrollExtent) {
          postPage++;
          if (postList.length < posts["total"]) {
            getPosts(context, moreData: true);
          }
        }
      });
      questionScrollController.addListener(() {
        if (questionScrollController.position.pixels ==
            questionScrollController.position.maxScrollExtent) {
          questionPage++;
          if (questionsList.length < questions["total"]) {
            getQuestions(context, moreData: true);
          }
        }
      });
      resourceScrollController.addListener(() {
        if (resourceScrollController.position.pixels ==
            resourceScrollController.position.maxScrollExtent) {
          resourcePage++;
          if (resourcesList.length < resources["total"]) {
            getResources(context, moreData: true);
          }
        }
      });
      bookmarkScrollController.addListener(() {
        if (bookmarkScrollController.position.pixels ==
            bookmarkScrollController.position.maxScrollExtent) {
          bookmarkPage++;
          if (bookmarksList.length < bookmarks["total"]) {
            getBookmarks(context, moreData: true);
          }
        }
      });
      controlModel.addListener(() {
        if (controlModel.deletePaddy == true) {
          //  print("Looking to delete");
          //  print("Deleted data: ${controlModel.deletedPaddyData}");
          // if (tabController?.index == 0) {
          //   getPostAgain(context);
          // } else if (tabController?.index == 1) {
          //   getQuestionAgain(context);
          // } else if (tabController?.index == 2) {
          //   getResourcesAgain(context);
          // }
          getPostAgain(context);
          getQuestionAgain(context);
          getResourcesAgain(context);
          getBookmarksAgain(context);
          controlModel.setDeletePaddy(false);
        }
      });
    });
  }

  getSizes() {
    //  print("Getting Height");
    if (contentHeight == null) {
      if (contentKey.currentContext != null) {
        RenderBox renderBoxRed =
            contentKey.currentContext?.findRenderObject() as RenderBox;
        final sizeRed = renderBoxRed.size;
        contentHeight = sizeRed.height;
        contentPosition = renderBoxRed.localToGlobal(Offset.zero);
        // //  print(contentHeight);
        // //  print(contentPosition);
        setState(() {
          // showMore = false;
        });
      }
    }
  }

  shareProfileLink() {
    Share.share("https://www.instagram.com/p/B_Z-_xgBXZ/?igshid=1hxqzqzqzqzqz");
  }

  Future getImageFromGallery() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      Navigator.of(context).pop();
      setState(() {
        isImageUploading = true;
      });
      uploadResponse = await upload(context, file!.path);
      //  print(uploadResponse);
      if (uploadResponse != null) {
        profilepic = uploadResponse!["data"]["path"];
        bool res =
            await updateUserProfile(context, {"backgroundPic": profilepic});
        if (res) {
          userData["data"]["backgroundPic"] = profilepic;
          // userModel.userData!["data"]["backgroundPic"] = profilepic;
          setState(() {
            isImageUploading = false;
          });
        }
      } else {
        setState(() {
          isImageUploading = false;
        });
      }
    } else {
      //  print('No image selected.');
    }
  }

  Future getImageFromCamera() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = XFile(pickedFile.path);
        file = File(image!.path);
      });
      Navigator.of(context).pop();
      setState(() {
        isImageUploading = true;
      });
      uploadResponse = await upload(context, file!.path);
      //  print(uploadResponse);
      if (uploadResponse != null) {
        profilepic = uploadResponse!["data"]["path"];
        bool res =
            await updateUserProfile(context, {"backgroundPic": profilepic});
        if (res) {
          userData["data"]["backgroundPic"] = profilepic;
          userModel.userData!["data"]["backgroundPic"] = profilepic;
          setState(() {
            isImageUploading = false;
          });
        }
      } else {
        setState(() {
          isImageUploading = false;
        });
      }
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

  getPosts(BuildContext context, {bool moreData = false}) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isPostLoading = true;
      });
    } else {
      setState(() {
        isMorePostLoading = true;
      });
    }
    posts = await getUserPosts(context, {}, userModel.id!, postPage);
    postList.addAll(posts['data']);
    setState(() {
      isPostLoading = false;
      isMorePostLoading = false;
    });
  }

  getQuestions(BuildContext context, {bool moreData = false}) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isQuestionLoading = true;
      });
    } else {
      setState(() {
        isMoreQuestionLoading = true;
      });
    }
    questions =
        await getUserQuestions(context, {}, userModel.id!, questionPage);
    questionsList.addAll(questions['data']);
    setState(() {
      isQuestionLoading = false;
      isMoreQuestionLoading = false;
    });
  }

  getQuestionAgain(BuildContext context) async {
    //  print("Getting question again");
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    questions = await getUserQuestions(context, {}, userModel.id!, 1);
    questionsList = (questions['data']);
    setState(() {
      isQuestionLoading = false;
    });
  }

  getPostAgain(BuildContext context) async {
    //  print("Getting post again");
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    posts = await getUserPosts(context, {}, userModel.id!, 1);
    postList = (posts['data']);
    setState(() {
      isPostLoading = false;
    });
  }

  getResourcesAgain(BuildContext context) async {
    //  print("Getting resource again");
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    resources = await getUserResources(context, {}, userModel.id!, 1);
    resourcesList = (resources['data']);
    setState(() {
      isResourceLoading = false;
    });
  }

  getResources(BuildContext context, {moreData: false}) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isResourceLoading = true;
      });
    } else {
      setState(() {
        isMoreResourceLoading = true;
      });
    }
    resources =
        await getUserResources(context, {}, userModel.id!, resourcePage);
    resourcesList.addAll(resources['data']);
    setState(() {
      isResourceLoading = false;
      isMoreResourceLoading = false;
    });
  }

  getBookmarks(BuildContext context, {moreData: false}) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (moreData == false) {
      setState(() {
        isBookmarkLoading = true;
      });
    } else {
      setState(() {
        isMoreBookmarkLoading = true;
      });
    }
    bookmarks =
        await getUserBookmarks(context, {}, userModel.id!, bookmarkPage);
    bookmarksList.addAll(bookmarks['data']);
    debugPrint(bookmarksList[1].toString(), wrapWidth: 1024);
    setState(() {
      isBookmarkLoading = false;
      isMoreBookmarkLoading = false;
    });
  }

  getBookmarksAgain(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    bookmarks = await getUserBookmarks(context, {}, userModel.id!, 1);
    bookmarksList = (bookmarks['data']);
    setState(() {
      isBookmarkLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Quick Action",
        backgroundColor: colors.blueColorOne,
        onPressed: () {
          quickActionModalBottomSheet2(context);
        },
        child: Icon(Icons.add, size: 35),
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                iconTheme: IconThemeData(color: colors.blueColorOne),
                pinned: true,
                floating: true,
                snap: false,
                backgroundColor: colors.backgroundWhite,
                expandedHeight: childSize.height == 0
                    ? 600
                    : childSize.height +
                        (Platform.isIOS
                            ? 265
                            : (getWidth(context) > 400 ? 285 : 260)),
                shadowColor: colors.paddygreen,
                flexibleSpace: Container(
                  color: Colors.transparent,
                  child: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: getWidth(context),
                          height: getSize(context, 250),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => pushNewScreen(context,
                                    screen: ImageViewer(
                                        imageUrl: userData['data']
                                                ['backgroundPic'] ??
                                            ""),
                                    withNavBar: false),
                                child: Container(
                                  height: getSize(context, 200),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          userData["data"]["backgroundPic"],
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: GestureDetector(
                                  onTap: () => pushNewScreen(context,
                                      screen: ImageViewer(
                                          imageUrl: userData['data']
                                                  ['profilepic'] ??
                                              ""),
                                      withNavBar: false),
                                  child: Container(
                                    clipBehavior: Clip.none,
                                    width: getSize(context, 100),
                                    height: getSize(context, 100),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 5,
                                            color: colors.backgroundWhite),
                                        shape: BoxShape.circle,
                                        image: userData["data"]["profilepic"]
                                                    .substring(
                                                        userData["data"][
                                                                    "profilepic"]
                                                                .toString()
                                                                .lastIndexOf(
                                                                    ".") +
                                                            1,
                                                        userData["data"]
                                                                ["profilepic"]
                                                            .toString()
                                                            .length) ==
                                                "svg"
                                            ? DecorationImage(
                                                image: AssetImage(
                                                    "assets/pngs/profile_icon.png"))
                                            : DecorationImage(
                                                image: NetworkImage(
                                                  userData["data"]
                                                      ["profilepic"],
                                                ),
                                                fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: 10,
                                  bottom: 20,
                                  // alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () => showPicker(context),
                                    child: Container(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                              child: isImageUploading
                                                  ? Container(
                                                      width:
                                                          getSize(context, 30),
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2))
                                                  : Icon(Icons.camera_alt,
                                                      color: colors.white)),
                                        ),
                                        height: getSize(context, 50),
                                        decoration: BoxDecoration(
                                            color: colors.blueColorOne,
                                            shape: BoxShape.circle)),
                                  )),
                            ],
                          ),
                        ),
                        MeasureSize(
                          onChange: (size) {
                            childSize = size;
                            //  print(childSize.height);
                            setState(() {});
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: getSize(context, 20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: getSize(context, 60),
                                    width: getWidth(context),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: textControl(
                                                "${userData["data"]["firstname"] + " " + userData["data"]["lastname"]}",
                                                context,
                                                size: 18,
                                                fontWeight: FontWeight.w700)),
                                        PopupMenuButton(
                                          icon: Icon(
                                            Icons.more_vert,
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              child: Text("Share Profile Link"),
                                              value: 1,
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 1) {
                                              shareProfileLink();
                                            }
                                          },
                                        ),
                                        CustomButton(
                                            text: "Edit",
                                            onPressed: () {
                                              pushNewScreen(context,
                                                  screen: EditProfile(),
                                                  withNavBar: false);
                                            },
                                            width: 70,
                                            height: 30,
                                            textSize: 12,
                                            buttonColor: colors.paddygreen)
                                      ],
                                    ),
                                  ),
                                  textControl(
                                      "@" +
                                          userData["data"]["username"]
                                              .toString(),
                                      context,
                                      fontWeight: FontWeight.w400),
                                  SizedBox(height: getSize(context, 10)),
                                  textControl(
                                      ((userData["data"]["bio"] == null ||
                                                      userData["data"]["bio"] ==
                                                          "")
                                                  ? "No bio"
                                                  : userData["data"]["bio"])
                                              .replaceAll("\n", " ") ??
                                          "",
                                      context,
                                      fontWeight: FontWeight.w400,
                                      spacing: 0,
                                      wordSpacing: 0),
                                  SizedBox(height: getSize(context, 10)),
                                  textControl(
                                      "${userData["data"]["academic_status"].toString().capitalizeString()} '${userData["data"]["graduation_year"] != null ? userData["data"]["graduation_year"].substring(2, 4) : ""}",
                                      context,
                                      color: Color(0xFF205374),
                                      fontWeight: FontWeight.w700,
                                      size: 16),
                                  SizedBox(height: getSize(context, 10)),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Icon(Icons.location_on, size: 14),
                                        // SizedBox(width: getSize(context, 5)),
                                        // textControl("Lagos, Nigeria", context, fontWeight: FontWeight.w500),
                                        // SizedBox(width: getSize(context, 15)),
                                        Image.asset("assets/pngs/grad_cap.png",
                                            height: 14, color: Colors.black),
                                        SizedBox(width: getSize(context, 5)),
                                        textControl(
                                            userData["data"]["institution"] ??
                                                "",
                                            context,
                                            fontWeight: FontWeight.w200),
                                      ]),
                                  SizedBox(height: getSize(context, 10)),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/svgs/book.svg",
                                          height: 12),
                                      SizedBox(width: getSize(context, 5)),
                                      textControl(
                                          "Faculty of ${userData["data"]["faculty"]}",
                                          context,
                                          fontWeight: FontWeight.w200),
                                    ],
                                  ),
                                  SizedBox(height: getSize(context, 10)),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/svgs/book.svg",
                                          height: 12),
                                      SizedBox(width: getSize(context, 5)),
                                      Expanded(
                                          child: textControl(
                                              "Department of ${userData["data"]["department"]}",
                                              context,
                                              fontWeight: FontWeight.w200)),
                                    ],
                                  ),
                                  Container(
                                      height: getSize(context, 60),
                                      width: getWidth(context),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            textControl("Skills  -  ", context,
                                                fontWeight: FontWeight.w800),
                                            Expanded(
                                              child: textControl(
                                                  userData["data"][
                                                                  "skill_sets"] !=
                                                              null &&
                                                          userData["data"]
                                                                  ["skill_sets"]
                                                              .isNotEmpty
                                                      ? userData["data"]
                                                              ["skill_sets"]
                                                          .join(', ')
                                                      : "No skills",
                                                  context,
                                                  color: colors.textBlue
                                                      .withOpacity(0.85),
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ])),
                                  SizedBox(height: getSize(context, 10)),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () => pushNewScreen(context,
                                              screen: ProfileFollowingPage(
                                                  userId: userModel.id!)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                textControl(
                                                    "${userData["data"]["following"].length} ",
                                                    context,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textControl(
                                                    "Following", context,
                                                    fontWeight: FontWeight.w200,
                                                    maxLines: 1),
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => pushNewScreen(context,
                                              screen: ProfileFollowersPage(
                                                  userId: userModel.id!)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                textControl(
                                                    "${userData["data"]["followers"].length} ",
                                                    context,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textControl(
                                                    userData["data"][
                                                                    "followers"]
                                                                .length ==
                                                            1
                                                        ? "Follower"
                                                        : "Followers",
                                                    context,
                                                    fontWeight: FontWeight.w200,
                                                    maxLines: 1),
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => pushNewScreen(context,
                                              screen: ProfileCommunities(
                                                  userId: userModel.id!)),
                                          child: Row(
                                            children: [
                                              textControl(
                                                  "${userData["data"]["community"].length} ",
                                                  context,
                                                  fontWeight: FontWeight.w600),
                                              textControl(
                                                  userData["data"]["community"]
                                                              .length ==
                                                          1
                                                      ? "Community"
                                                      : "Communities",
                                                  context,
                                                  fontWeight: FontWeight.w200,
                                                  maxLines: 1),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    collapseMode: CollapseMode.pin,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size(
                    getx.Get.width,
                    getSize(context, 50),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: colors.paddygreen.withOpacity(0.5)))),
                    child: TabBar(
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      isScrollable: true,
                      controller: tabController,
                      labelColor: colors.paddygreen,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(text: "Post"),
                        Tab(text: "Q & A"),
                        Tab(text: "Resources"),
                        Tab(text: "Bookmarks"),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              isPostLoading
                  ? ShimmerWidget(count: 3)
                  : postList.length < 1
                      ? EmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: postScrollController,
                                ////physics: BouncingScrollPhysics(),
                                itemCount: postList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: getSize(context, 20),
                                        vertical: 10),
                                    child: Column(
                                      children: [
                                        PostWidget(
                                            content: postList[index],
                                            isOnProfilePage: true),
                                        SizedBox(height: 10),
                                        divider(context),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            isMorePostLoading
                                ? loaderMain(context,
                                    status: true,
                                    size: getSize(context, 20),
                                    height: 50)
                                : SizedBox()
                          ],
                        ),
              isQuestionLoading
                  ? ShimmerWidget(count: 3)
                  : questionsList.length < 1
                      ? EmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: questionScrollController,
                                ////physics: BouncingScrollPhysics(),
                                itemCount: questionsList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: getSize(context, 20),
                                        vertical: 10),
                                    child: Column(
                                      children: [
                                        questionsList[index]["type"] ==
                                                "Question"
                                            ? QuestionWidget(
                                                content: questionsList[index],
                                                isOnProfilePage: true)
                                            : questionsList[index]["type"] ==
                                                    "Answer"
                                                ? AnswerWidget(
                                                    content:
                                                        questionsList[index],
                                                    isOnProfilePage: true)
                                                : SizedBox(),
                                        SizedBox(height: 10),
                                        divider(context),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            isMoreQuestionLoading
                                ? loaderMain(context,
                                    status: true,
                                    size: getSize(context, 20),
                                    height: 50)
                                : SizedBox()
                          ],
                        ),
              isResourceLoading
                  ? ShimmerWidget(count: 3)
                  : resourcesList.length < 1
                      ? EmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: resourceScrollController,
                                ////physics: BouncingScrollPhysics(),
                                itemCount: resourcesList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: getSize(context, 20),
                                        vertical: 10),
                                    child: Column(
                                      children: [
                                        ResourceWidget(
                                            content: resourcesList[index],
                                            isOnProfilePage: true),
                                        SizedBox(height: 10),
                                        divider(context)
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            isMoreResourceLoading
                                ? loaderMain(context,
                                    status: true,
                                    size: getSize(context, 20),
                                    height: 50)
                                : SizedBox()
                          ],
                        ),
              isBookmarkLoading
                  ? ShimmerWidget(count: 3)
                  : bookmarksList.length < 1
                      ? EmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: bookmarkScrollController,
                                itemCount: bookmarksList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      children: [
                                        bookmarksList[index]["type"] == "Answer"
                                            ? AnswerWidget(
                                                content: bookmarksList[index],
                                              )
                                            : bookmarksList[index]["type"] ==
                                                    "Post"
                                                ? PostWidget(
                                                    content:
                                                        bookmarksList[index])
                                                : bookmarksList[index]
                                                            ["type"] ==
                                                        "Resource"
                                                    ? ResourceWidget(
                                                        content: bookmarksList[
                                                            index])
                                                    : bookmarksList[index]
                                                                ["type"] ==
                                                            "Question"
                                                        ? QuestionWidget(
                                                            content:
                                                                bookmarksList[
                                                                    index])
                                                        : bookmarksList[index]
                                                                    ["type"] ==
                                                                "Comment"
                                                            ? CommentWidget(
                                                                content:
                                                                    bookmarksList[
                                                                        index],
                                                              )
                                                            : SizedBox(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            isMoreBookmarkLoading
                                ? loaderMain(context,
                                    status: true,
                                    size: getSize(context, 20),
                                    height: 50)
                                : SizedBox()
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
