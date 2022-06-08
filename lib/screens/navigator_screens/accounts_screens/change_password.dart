import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/notification_settings.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  change(BuildContext context) async {
    if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      toastError("Please input password for both fields", context);
    } else {
      bool res = await changePassword(context, {"oldPassword": currentPasswordController.text, "newPassword": newPasswordController.text});
      if (res) {
        toastSuccess("Password changed", context);
        Navigator.pop(context);
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              headerWidget(context, "Change Password"),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: GestureDetector(
                  onTap: () {
                    change(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      textControl("Save", context, color: colors.paddyLightGreen, size: 14, fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: getSize(context, 20)),
              Expanded(
                child: Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: getSize(context, 100)),
                      CustomTextField(header: "Current password", hintText: "Current Password", type: "Password", controller: currentPasswordController),
                      SizedBox(height: getSize(context, 30)),
                      CustomTextField(header: "New Password", hintText: "New password", type: "Password", controller: newPasswordController)
                    ],
                  ),
                ),
              )
            ])),
      ),
    );
  }
}
