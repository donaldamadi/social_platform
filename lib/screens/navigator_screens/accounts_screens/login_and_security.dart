import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/change_password.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/delete_account.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/notification_settings.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class LoginAndSecurityPage extends StatefulWidget {
  const LoginAndSecurityPage({Key? key}) : super(key: key);

  @override
  _LoginAndSecurityPageState createState() => _LoginAndSecurityPageState();
}

class _LoginAndSecurityPageState extends State<LoginAndSecurityPage> {
  String username = "";
  String email = "";
  String password = "qwerty123";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDetails(context);
    });
  }

  getDetails(BuildContext context) async {
    Map<String, dynamic> details = await getLoginAndSecurity(context);
    username = details["data"]["username"];
    email = details["data"]["email"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerWidget(context, "Login & Security"),
                      SizedBox(height: getSize(context, 50)),
                      Row(
                        children: [
                          Container(
                            width: getSize(context, 120),
                            child: textControl("Username", context, size: 12),
                          ),
                          Expanded(
                            child: Container(
                              child: textControl("@$username", context, color: colors.lightGrey, size: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: getSize(context, 20)),
                      Row(
                        children: [
                          Container(
                            width: getSize(context, 120),
                            child: textControl("Email", context, size: 12),
                          ),
                          Expanded(
                            child: Container(
                              child: textControl("$email", context, color: colors.lightGrey, size: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: getSize(context, 20)),
                      Row(
                        children: [
                          Container(
                            width: getSize(context, 120),
                            child: textControl("Password", context, size: 12),
                          ),
                          Expanded(
                            child: Container(
                              child: textControl("*"*password.length, context, color: colors.lightGrey, size: 12),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                pushNewScreen(context, screen: ChangePasswordPage(), withNavBar: false);
                              },
                              child: textControl("Change", context, color: colors.red, fontWeight: FontWeight.w500)),
                          SizedBox(height: getSize(context, 30)),
                        ],
                      ),
                      SizedBox(height: getSize(context, 20)),
                      GestureDetector(onTap: ()=> pushNewScreen(context, screen: DeleteAccount(), withNavBar: false), child: textControl("Delete Account", context, color: colors.red, size: 12, fontWeight: FontWeight.w500))
                    ],
                  )))),
    );
  }
}
