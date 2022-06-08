import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/main.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/auth_screens/sign_up_verification.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool termsAndConditionsCheck = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List countries = ["Nigeria", "Canada", "England", "South Africa", "Japan", "Portugal", "Ghana"];
  TextStyle textStyle = TextStyle(color: colors.paddygreen, fontWeight: FontWeight.bold);
  Map<String, dynamic>? userData;
  String countryValue = "Nigeria";
  bool loading = false;

  registerData(BuildContext context) {
    //  print(userData);
    userData = {
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "country": countryValue,
      "password": passwordController.text,
      "confirm_password": passwordController.text,
      "accept_terms": true
    };
  }

  launchURL(String url) async => await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  validateData(context) async {
    closeKeyboard();
    if (emailController.text == "") {
      toastError("Email cannot be left empty", context);
      return;
    } else if (usernameController.text == "") {
      toastError("username cannot be left empty", context);
      return;
    } else if (countryValue == "") {
      toastError("Country cannot be left empty", context);
      return;
    } else if (passwordController.text == "") {
      toastError("Please input your password", context);
      return;
    } else if (termsAndConditionsCheck == false) {
      toastError('You have to accept the Terms and Conditions', context);
      return;
    } else if (!GetUtils.isEmail(emailController.text)) {
      // } else if (!validateEmail(emailController.text)) {
      toastError('Please enter a valid email', context);
      return;
    } else if (passwordController.text.length < 6) {
      toastError("Password must be at least 6 characters", context);
      return;
    }
    setState(() {
      loading = true;
    });
    registerData(context);
    if (await registerUser(context, userData!)) {
      Get.off(() => VerifySignUp());
      //  print(true);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          SizedBox(height: getSize(context, 70)),
          Center(child: textControl("Sign Up", context, size: 36, fontWeight: FontWeight.w900, spacing: 2)),
          SizedBox(height: getSize(context, 20)),
          textControl("Put in the following information to join us on Student Paddy.", context,
              size: 18, fontWeight: FontWeight.w300, textAlign: TextAlign.center),
          SizedBox(height: getSize(context, 50)),
          CustomTextField(
            borderRadius: 3,
            type: "Email",
            header: 'Email',
            hintText: "Email",
            onChanged: (val) => setState(() {
              emailController.text = val;
            }),
          ),
          SizedBox(height: 30),
          CustomTextField(
              borderRadius: 3,
              header: 'Username',
              hintText: "Username",
              onChanged: (val) => setState(() {
                    usernameController.text = val;
                  })),
          SizedBox(height: 30),
          CustomContainer(
            borderRadius: 3,
            header: "Country of residence",
            child: Container(
              child: GestureDetector(
                child: Container(
                  child: Row(
                    children: [
                      SizedBox(width: getSize(context, 15)),
                      Expanded(child: textControl(countryValue, context, size: 17, fontWeight: FontWeight.w600)),
                      Icon(Icons.arrow_drop_down, color: colors.paddygreen),
                      SizedBox(width: getSize(context, 10)),
                    ],
                  ),
                ),
                onTap: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (Country country) {
                      //  print(country.name);
                      setState(() {
                        countryValue = country.name;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 30),
          CustomTextField(
              borderRadius: 3,
              hintText: "Password",
              header: 'Password',
              type: "Password",
              onChanged: (val) => setState(() {
                    passwordController.text = val;
                  })),
          SizedBox(height: 30),
          Row(
            children: [
              Theme(
                data: ThemeData(unselectedWidgetColor: colors.paddygreen, primarySwatch: Colors.teal),
                child: Checkbox(
                  value: termsAndConditionsCheck,
                  onChanged: (v) {
                    setState(() {
                      termsAndConditionsCheck = v!;
                    });
                  },
                ),
              ),
              SizedBox(width: 5),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "I have read and accepted student paddy ",
                        style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.textBlack),
                      ),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await launchURL("https://studentpaddy.com/v1/terms");
                          },
                        text: "Terms and Conditions",
                        style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.blueColorOne),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 30),
          CustomButton(
              borderRadius: 3,
              enabled: !loading,
              loading: loading,
              text: "Sign up",
              onPressed: () async {
                validateData(context);
              },
              width: getWidth(context)),
          SizedBox(height: 30),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.textBlack),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacementNamed(context, MyApp.loginScreen);
                    },
                  text: "Log In",
                  style: TextStyle(fontFamily: "Graphik", fontWeight: FontWeight.w600, fontSize: 15, color: colors.blueColorOne),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ]),
      ),
    );
  }
}
