import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/login_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class VerifySignUp extends StatefulWidget {
  @override
  _VerifySignUpState createState() => _VerifySignUpState();
}

class _VerifySignUpState extends State<VerifySignUp> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: getSize(context, 70)),
          Center(child: textControl("Sign Up Verification", context, size: 26, fontWeight: FontWeight.w900, spacing: 2)),
          SizedBox(height: getSize(context, 50)),
          textControl("A verification mail has been sent your email address.", context,
              size: 18, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          // textControl("Please input your email below and wait for a verificaton mail.", context, size: 18, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          // SizedBox(height: getSize(context, 50)),
          // CustomTextField(
          //   header: 'Email',
          //   hintText: "Email",
          //   controller: emailController,
          // ),
          // SizedBox(height: getSize(context, 70)),
          // CustomButton(
          //     text: "Verify",
          //     onPressed: () {
          //       Navigator.pushAndRemoveUntil(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => FavouriteCommunities(),
          //           ),
          //           (route) => false);
          //     },
          //     width: getWidth(context)),
          SizedBox(height: getSize(context, 50)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Verified your account?  ",
                  style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.textBlack, letterSpacing: 1),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
                      userModel.resetUserDetails();
                      Get.off(() => LoginScreen());
                    },
                  text: "Log In",
                  style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.blueColorOne, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
