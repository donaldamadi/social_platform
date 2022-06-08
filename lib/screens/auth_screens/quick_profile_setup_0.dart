import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup_1.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class QuickProfileScreenZero extends StatefulWidget {
  const QuickProfileScreenZero({Key? key}) : super(key: key);

  @override
  _QuickProfileScreenZeroState createState() => _QuickProfileScreenZeroState();
}

class _QuickProfileScreenZeroState extends State<QuickProfileScreenZero> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: getSize(context, 100)),
                Center(
                    child: textControl("Quick Profile Set up", context,
                        size: 25,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center)),
                SizedBox(height: getSize(context, 30)),
                textControl(
                    "Hi there, kindly set up your profile page so you can see related data that concerns you",
                    context,
                    size: 18,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center),
                Spacer(),
                CustomButton(
                    borderRadius: 3,
                    text: "Get Started",
                    onPressed: () {
                      Get.to(() => QuickProfileOne());
                    },
                    width:
                        constraints.maxWidth > 500 ? 500 : getWidth(context)),
                SizedBox(height: getSize(context, 30)),
                // CustomButton(
                //     text: "Skip",
                //     onPressed: () async {
                //       SharedPreferences prefs = await SharedPreferences.getInstance();
                //       prefs.clear();
                //     },
                //     width: constraints.maxWidth > 500 ? 500 : getWidth(context),
                //     buttonType: ButtonType.two),
                SizedBox(height: getSize(context, 40)),
              ],
            ),
          );
        },
      ),
    );
  }
}
