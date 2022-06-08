import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/web_view.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/add_a_file.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/make_a_post.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/share_a_link.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

import '../screens/navigator_screens/actions_screen/add_a_question.dart';

quickActionModalBottomSheet(BuildContext context, Map<String, dynamic> content,
    {String? id, String? type, String link = "", bool isProfile = false}) {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  ControlChangeNotifierModel controlModel =
      Provider.of<ControlChangeNotifierModel>(context, listen: false);
  showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      context: context,
      builder: (context) {
        return Wrap(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(height: getSize(context, 30)),
            Container(
                width: getWidth(context),
                child: Center(
                    child: Container(
                        width: getSize(context, 100),
                        height: getSize(context, 10),
                        decoration: BoxDecoration(
                            color: colors.blueColorOne,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))))),
            SizedBox(height: getSize(context, 50)),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/share.svg"),
              title: textControl("Share", context),
              onTap: () {
                Navigator.pop(context);
                Share.share(content["deepPath"]);
                // Share.share("$baseUrl/${type?.toLowerCase()}/$id");
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/bookmark.svg"),
              title: textControl(
                  userModel.userData!["data"]["bookmarks"]
                          .contains(content["_id"])
                      ? "Remove from Bookmarks"
                      : "Add to Bookmarks",
                  context),
              onTap: () async {
                Navigator.pop(context);
                userModel.userData!["data"]["bookmarks"]
                        .contains(content["_id"])
                    ? await addBookmark(context, {
                        "action": "undo",
                        "paddyId": content["_id"]
                      }).then((value) {
                        userModel.userData!["data"]["bookmarks"]
                            .remove(content["_id"]);
                        toastSuccess("Removed from Bookmarks", Get.context!);
                      })
                    : await addBookmark(
                        context,
                        {"action": "bookmark", "paddyId": content["_id"]},
                      ).then((value) {
                        userModel.userData!["data"]["bookmarks"]
                            .add(content["_id"]);
                        toastSuccess("Added to Bookmarks", Get.context!);
                      });
              },
            ),
            if (content["createdBy"]["_id"] == userModel.id &&
                isProfile == true)
              ListTile(
                contentPadding: EdgeInsets.only(left: getSize(context, 25)),
                leading: SvgPicture.asset("assets/svgs/delete.svg"),
                title: textControl("Delete", context),
                onTap: () {
                  // toastMessage("Coming Soon", context, seconds: 2);
                  // Navigator.pop(context);
                  Alert(
                      context: context,
                      title: "Delete Content",
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          textControl("Are you sure", context)
                        ],
                      ),
                      buttons: [
                        DialogButton(
                          height: getSize(context, 50),
                          // width: getSize(context, 1),
                          onPressed: () async {
                            Navigator.pop(context);
                            deleteContent(context, content["_id"],
                                content["type"].toString().toLowerCase());
                            controlModel.setDeletedPaddyData({
                              "paddyId": content["_id"],
                              "type": content["type"].toString().toLowerCase()
                            });
                            controlModel.setDeletePaddy(true);
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          },
                          color: Color(0xFFE31E1E),
                          child: Text(
                            "YES, DELETE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ]).show();
                },
              ),
            // ListTile(
            //   contentPadding: EdgeInsets.only(left: getSize(context, 25)),
            //   leading: SvgPicture.asset("assets/svgs/block_user.svg"),
            //   title: textControl("Block User", context),
            //   onTap: () async {
            //     toastMessage("Coming Soon", context, seconds: 2);
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/report_content.svg"),
              title: textControl("Report Content", context),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MyWebView(
                        title: 'Report Content',
                        selectedUrl: 'https://studentpaddy.com/report/$id}')));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/unfollow_user.svg"),
              title: textControl(
                  userModel.userData!["data"]["following"]
                          .contains(content["createdBy"]["_id"])
                      ? "Unfollow User"
                      : "Follow User",
                  context),
              onTap: () async {
                Navigator.pop(context);
                userModel.userData!["data"]["following"]
                        .contains(content["createdBy"]["_id"])
                    ? await followUser(context, {"action": "undo"}, content["createdBy"]["_id"])
                        .then((value) => userModel.userData!["data"]
                                ["following"]
                            .remove(content["createdBy"]["_id"]))
                    : await followUser(context, {"action": "follow"},
                            content["createdBy"]["_id"])
                        .then((value) => userModel.userData!["data"]
                                ["following"]
                            .add(content["createdBy"]["_id"]));
                // userModel.setUpdatedResult(true);
              },
            ),
            SizedBox(height: getSize(context, 50)),
            Container(height: getSize(context, 30)),
          ],
        );
      });
}

quickActionModalBottomSheet2(BuildContext context,
    {bool extraPop = false, String? id, QuickActions? type}) {
  showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            Container(height: getSize(context, 30)),
            Container(
                width: getWidth(context),
                child: Center(
                    child: Container(
                        width: getSize(context, 100),
                        height: getSize(context, 10),
                        decoration: BoxDecoration(
                            color: colors.blueColorOne,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))))),
            SizedBox(height: getSize(context, 50)),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: Icon(Icons.add_circle, color: colors.blueColorOne),
              title: textControl("Ask a Question", context),
              onTap: () {
                Navigator.pop(context);
                if (type != QuickActions.question) {
                  if (extraPop) Navigator.pop(context);
                  pushNewScreen(context,
                      screen: AddAQuestion(), withNavBar: false);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: Icon(Icons.add_circle, color: colors.blueColorOne),
              title: textControl("Upload a File", context),
              onTap: () {
                Navigator.pop(context);
                if (type != QuickActions.file) {
                  if (extraPop) Navigator.pop(context);
                  pushNewScreen(context, screen: AddAFile(), withNavBar: false);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: Icon(Icons.add_circle, color: colors.blueColorOne),
              title: textControl("Share a Link", context),
              onTap: () {
                Navigator.pop(context);
                if (type != QuickActions.link) {
                  if (extraPop) Navigator.pop(context);
                  pushNewScreen(context,
                      screen: ShareALink(), withNavBar: false);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: Icon(Icons.add_circle, color: colors.blueColorOne),
              title: textControl("Make a Post", context),
              onTap: () {
                Navigator.pop(context);
                if (type != QuickActions.post) {
                  if (extraPop) Navigator.pop(context);
                  pushNewScreen(context,
                      screen: MakeAPost(), withNavBar: false);
                }
              },
            ),
            SizedBox(height: getSize(context, 50)),
            Container(height: getSize(context, 30)),
          ],
        );
      });
}

quickActionModalBottomSheet3(BuildContext context, {required String id}) {
  showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      context: context,
      builder: (context) {
        return Wrap(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(height: getSize(context, 30)),
            Container(
                width: getWidth(context),
                child: Center(
                    child: Container(
                        width: getSize(context, 100),
                        height: getSize(context, 10),
                        decoration: BoxDecoration(
                            color: colors.blueColorOne,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))))),
            SizedBox(height: getSize(context, 50)),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/block_user.svg"),
              title: textControl("Block User", context),
              onTap: () async {
                blockUser(context, id);
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: getSize(context, 25)),
              leading: SvgPicture.asset("assets/svgs/report_content.svg"),
              title: textControl("Report Content", context),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MyWebView(
                        title: 'Report Content',
                        selectedUrl: 'https://studentpaddy.com/report/$id}')));
              },
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.only(left: getSize(context, 25)),
            //   leading: SvgPicture.asset("assets/svgs/unfollow_user.svg"),
            //   title: textControl("Unfollow User", context),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            SizedBox(height: getSize(context, 50)),
            Container(height: getSize(context, 30)),
          ],
        );
      });
}

enum QuickActions { post, question, link, file }
