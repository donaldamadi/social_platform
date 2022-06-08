import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/quickProfileModel.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/sign_up_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  TextEditingController reasonController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(context, "Account Deletion"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              textControl("Please tell us why you want to delete your account?", context, fontWeight: FontWeight.w500, size: 15),
              const SizedBox(height: 20),
              SizedBox(
                height: getSize(context, 200),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                  child: TextField(
                    style: TextStyle(fontFamily: "Avenir"),
                    controller: reasonController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    cursorHeight: 19.0,
                    decoration: InputDecoration.collapsed(hintText: ""),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFF6D6E71).withOpacity(0.6)),
                  ),
                ),
              ),
              SizedBox(height: 40),
              CustomTextField(header: "Confirm Password", type: "Password", controller: passwordController),
              SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                CustomButton(
                  height: getSize(context, 40),
                  width: getSize(context, 100),
                  text: "CONFIRM",
                  onPressed: () {
                    if (reasonController.text.isEmpty) {
                      toastMessage("Please enter your reason", context);
                    } else if (passwordController.text.isEmpty) {
                      toastMessage("Please enter your password", context);
                    } else {
                      pushNewScreen(context, screen: ConfirmDeleteAccount(reason: reasonController.text, password: passwordController.text), withNavBar: false);
                    }
                  },
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmDeleteAccount extends StatefulWidget {
  final String reason;
  final String password;

  ConfirmDeleteAccount({required this.reason, required this.password});

  @override
  _ConfirmDeleteAccountState createState() => _ConfirmDeleteAccountState();
}

class _ConfirmDeleteAccountState extends State<ConfirmDeleteAccount> {
  bool isLoading = false;

  deleteUserAccount() async {
    UserOnBoardChangeNotifierModel useronBoardModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    UserChangeNotifierModel userModel = Provider.of<UserChangeNotifierModel>(context, listen: false);
    QuickProfileChangeNotifierModel quickModel = Provider.of<QuickProfileChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel = Provider.of<ControlChangeNotifierModel>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    bool res = await deleteUser(context, {"reason": widget.reason.trim(), "password": widget.password});
    if (res) {
      useronBoardModel.resetUserDetails();
      userModel.resetUserModeDetails();
      quickModel.resetProfileDetails();
      controlModel.resetControlDetails();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      setState(() {
        isLoading = false;
      });
      Get.offAll(() => SignUp());
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Account Deletion"),
      body: isLoading ? loaderMain(context, status: true, color: colors.paddygreen, size: 40) : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          textControl("Are you sure you want to delete your account?", context, fontWeight: FontWeight.w500, size: 15),
          const SizedBox(height: 30),
          textControl("This action you’re about to take is irreversible and all your data would be lost.", context, fontWeight: FontWeight.w500, size: 14, color: colors.red),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                height: getSize(context, 45),
                width: getSize(context, 250),
                buttonColor: colors.red,
                text: "YES, DELETE ACCOUNT",
                onPressed: () => deleteUserAccount(),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
