import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/main.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/auth_screens/sign_up_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/navigatorPage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  Map<String, dynamic> userData = {};
  bool loading = false;
  bool isGoogleLoading = false;
  bool isAppleLoading = false;
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  handleAppleLogin() async {
    bool res;
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // print(credential);
    // print(credential.userIdentifier);
    // print(credential.authorizationCode);
    // print(credential.email);
    // print(credential.familyName);
    // print(credential.givenName);
    // print(credential.identityToken);
    // print(credential.state);

    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
    setState(() {
      isAppleLoading = true;
    });
    if (credential.email == null) {
      res = await appleLogin(context, {
        "id": credential.userIdentifier!,
      });
    } else {
      res = await appleLogin(context, {
        "email": credential.email!,
        "firstname": credential.givenName!,
        "lastname": credential.familyName!,
        "id": credential.userIdentifier!,
      });
    }
    setState(() {
      isAppleLoading = false;
    });
    if (res) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NavigatorPage()));
    }
  }

  Future<void> handleSignIn() async {
    Map<String, dynamic> googleData = {};
    try {
      googleSignIn.signOut();
      await googleSignIn.signIn().then((value) async {
        if (value != null) {
          setState(() {
            isGoogleLoading = true;
          });
          // print(value);
          // print(value.serverAuthCode);
          await value.authentication.then((value) {
            // log(value.accessToken.toString());
            // log(value.idToken.toString());
            return value;
          });
          // print(value.displayName?.split(" ")[0]);
          // print(value.displayName
          //     ?.split(" ")[(value.displayName?.split(" ") ?? []).length - 1]);
          // print(value.id);
          // print(value.photoUrl);
          googleData = {
            "email": value.email,
            "firstname": value.displayName?.split(" ")[0],
            "lastname": value.displayName?.split(" ")[(value.displayName?.split(" ") ?? []).length - 1],
            "id": value.id,
            "picture": value.photoUrl,
          };
          // print(googleData);
          bool res = await googleLogin(context, googleData);
          setState(() {
            isGoogleLoading = false;
          });
          if (res) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NavigatorPage()));
          }
        }
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> launchURL(BuildContext context, String url) async {
    final theme = Theme.of(context);
    try {
      await launch(
        'https://accounts.google.com/o/oauth2/v2/auth?redirect_uri=https%3A%2F%2Fstudentpaddy.com%2Fgoogle&client_id=420685507600-6057nei1k7p7vuppkko019qu85hbbj50.apps.googleusercontent.com&access_type=offline&response_type=code&prompt=consent&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&flowName=GeneralOAuthFlow',
        customTabsOption: CustomTabsOption(
          toolbarColor: theme.primaryColor,
          // enableDefaultShare: true,
          // enableUrlBarHiding: true, s
          showPageTitle: true,
          animation: CustomTabsSystemAnimation.slideIn(),
          extraCustomTabs: const <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: theme.primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      // debugPrint(e.toString());
    }
  }

  launchURL2(String url) async => await launcher.canLaunch(url) ? await launcher.launch(url, forceWebView: true) : throw 'Could not launch $url';

  sendData() {
    userData = {"username_or_email": usernameEditingController.text.trim(), "password": passwordEditingController.text};
  }

  // login(BuildContext context) {
  //   UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  // }

  bool validateData() {
    if (usernameEditingController.text.isEmpty || passwordEditingController.text.isEmpty) {
      toastError("Your email/username and password cannot be left empty", context);
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: getSize(context, 100)),
            Center(child: textControl("Login", context, size: 36, fontWeight: FontWeight.w900, spacing: 2)),
            SizedBox(height: getSize(context, 20)),
            textControl("Enter your credentials to login or sign up to join us on Student Paddy.", context,
                size: 18, fontWeight: FontWeight.w300, textAlign: TextAlign.center),
            SizedBox(height: getSize(context, 80)),
            CustomTextField(header: "Username or Email", controller: usernameEditingController, borderRadius: 3),
            SizedBox(height: getSize(context, 30)),
            CustomTextField(header: "Password", controller: passwordEditingController, type: "Password", maxLines: 1, borderRadius: 3),
            SizedBox(height: getSize(context, 70)),
            CustomButton(
                borderRadius: 3,
                enabled: !loading,
                loading: loading,
                text: "Log In",
                onPressed: () async {
                  sendData();
                  // print(userData);
                  bool validation = validateData();
                  if (validation) {
                    setState(() {
                      loading = true;
                    });
                    bool res = await loginUser(context, userData);
                    if (res) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NavigatorPage()));
                    } else {
                      setState(() {
                        loading = false;
                      });
                    }
                  }
                },
                width: getWidth(context)),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, MyApp.forgotPasswordScreen);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                  child: textControl("Forgot Password ?", context, color: Color(0XFF205374), fontWeight: FontWeight.w700, size: 15),
                ),
              ),
            ),
            CustomButton(
                borderRadius: 3,
                text: "Sign Up",
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SignUp()));
                },
                width: getWidth(context),
                buttonType: ButtonType.two),
            SizedBox(height: getSize(context, 35)),
            CustomButton(
              borderRadius: 3,
              enabled: !isGoogleLoading,
              loading: isGoogleLoading,
              text: "Continue with Google",
              onPressed: () => handleSignIn(),
              width: getWidth(context),
              buttonColor: colors.blueColorOne,
              buttonWidget: SvgPicture.asset("assets/svgs/google_icon.svg", height: 17, width: 17),
            ),
            SizedBox(height: getSize(context, 30)),
            if (Platform.isIOS)
              CustomButton(
                enabled: !isAppleLoading,
                loading: isAppleLoading,
                buttonType: ButtonType.two,
                borderRadius: 3,
                text: "Continue with Apple",
                textColor: Colors.black,
                onPressed: () {
                  handleAppleLogin();
                },
                width: getWidth(context),
                buttonColor: Colors.black,
                buttonWidget: SvgPicture.asset("assets/svgs/apple.svg", height: 17, width: 17, color: Colors.black),
              ),
            SizedBox(height: getSize(context, 50)),
          ],
        ),
      ),
    );
  }
}
