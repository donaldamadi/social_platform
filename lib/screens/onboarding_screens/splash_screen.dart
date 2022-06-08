import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/main.dart';
import 'package:student_paddy_mobile/network/data.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/navigatorPage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? loaderController;
  var loaderTween = Tween(begin: Offset.zero, end: Offset(2, 0));
  String? token;

  Future<void> getOpenedFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(userToken) != null) {
      setState(() {
        token = prefs.getString(userToken);
      });
      bool res = await getUserDetails(context, token!, showError: false);
      if (res) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavigatorPage()));
      } else {
        Navigator.of(context).pushReplacementNamed(MyApp.onboardingScreen);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(MyApp.onboardingScreen);
    }
  }

  @override
  void initState() {
    super.initState();
    loaderController =
        AnimationController(vsync: this, duration: Duration(seconds: 0))
          ..forward().then((value) => proceed());
  }

  @override
  void dispose() {
    loaderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/pngs/sp_logo.png',
            //   height: 140,
            // ),
            // SizedBox(height: 40),
            Container(
              height: getSize(context, 30),
              child: loaderMain(context,
                  size: 50, status: true, color: colors.paddygreen),
            ),
          ],
        ),
      ),
    );
  }

  void proceed() {
    getOpenedFromSharedPref();
  }
}
