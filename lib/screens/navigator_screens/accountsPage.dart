import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/content_and_privacy.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/login_and_security.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/notification_settings.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/messages_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: colors.backgroundWhite,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getSize(context, 30)),
              textControl("User", context,
                  size: 22, fontWeight: FontWeight.w800),
              SizedBox(height: getSize(context, 20)),
              settingsWidget(context, "Profile", onTap: () {
                pushNewScreen(context,
                    screen: ProfilePage(), withNavBar: false);
              }),
              settingsWidget(context, "Messages", onTap: () {
                pushNewScreen(context,
                    screen: MessagesScreen(), withNavBar: false);
              }),
              SizedBox(height: getSize(context, 60)),
              textControl("Settings", context,
                  size: 22, fontWeight: FontWeight.w800),
              SizedBox(height: getSize(context, 20)),
              settingsWidget(context, "Login & Security", onTap: () {
                pushNewScreen(context,
                    screen: LoginAndSecurityPage(), withNavBar: false);
              }),
              settingsWidget(context, "Content and privacy", onTap: () {
                pushNewScreen(context,
                    screen: ContentAndPrivacyPage(), withNavBar: false);
              }),
              settingsWidget(context, "Notifications Settings", onTap: () {
                pushNewScreen(context,
                    screen: NotificationSettingsPage(), withNavBar: false);
              }),
              settingsWidget(context, "About Student paddy",
                  onTap: () => launchURL("https://studentpaddy.com/v1/about")),
              SizedBox(height: 80),
              Center(
                  child: InkWell(
                onTap: () async {
                  UserOnBoardChangeNotifierModel useronBoardModel =
                      Provider.of<UserOnBoardChangeNotifierModel>(context,
                          listen: false);

                  final res = await showOkCancelAlertDialog(
                      context: context,
                      title: "Log out",
                      message: "Do you want to log out from this device?",
                      okLabel: Platform.isAndroid ? "OK" : "ok",
                      cancelLabel: Platform.isAndroid ? "CANCEL" : "cancel");
                  if (res != OkCancelResult.ok) return;
                  logoutUser(context, useronBoardModel.token!);
                },
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_outlined,
                          color: Color(0xFFE31E1E), size: 20),
                      SizedBox(width: getSize(context, 5)),
                      textControl(
                        "Logout",
                        context,
                        color: Color(0xFFE31E1E),
                      )
                    ]),
              )),
              SizedBox(height: getSize(context, 50)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget settingsWidget(BuildContext context, String text,
    {VoidCallback? onTap}) {
  return Container(
    height: getSize(context, 50),
    child: SizedBox.expand(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textControl(text, context, fontWeight: FontWeight.w500, size: 14),
            IconButton(
                onPressed: onTap, icon: Icon(Icons.chevron_right, size: 24))
          ],
        ),
      ),
    ),
  );
}
