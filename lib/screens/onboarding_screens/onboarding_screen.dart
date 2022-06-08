import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/main.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final List<OnboardingDetails> list = [
    OnboardingDetails(
      mainText: "ENHANCE",
      subText: "Interact with learning experiences that can ENHANCE your own\n",
    ),
    OnboardingDetails(
      mainText: "SHARE",
      subText: "SHARE content on Academic, Field, or Career Topics.\n",
    ),
    OnboardingDetails(
      mainText: "CONNECT",
      subText: "CONNECT with other college students locally & globally\n",
    ),
  ];

  PageController pageController = PageController();
  double? currentPageValue = 0.0;

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        currentPageValue = pageController.page;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFFFFFF),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: 3,
                controller: pageController,
                itemBuilder: (context, index) {
                  OnboardingDetails details = list[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        details.mainText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 2),
                      ),
                      SizedBox(height: 20),
                      index == 0
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "Interact with learning experiences that can ",
                                    children: [
                                      TextSpan(
                                        text: "ENHANCE",
                                        style: TextStyle(
                                          color: colors.paddygreen,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " your own\n",
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 1,
                                            color: Color(0xFF000000)
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                    style: TextStyle(
                                        fontSize: 15,
                                        letterSpacing: 1,
                                        color:
                                            Color(0xFF000000).withOpacity(0.8),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            )
                          : index == 1
                              ? RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        // text: "SHARE content on Academic, Field, or Career Topics.\n",
                                        children: [
                                          TextSpan(
                                            text: "SHARE",
                                            style: TextStyle(
                                              color: colors.paddygreen,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                " content on Academic, Field, or Career Topics.\n",
                                            style: TextStyle(
                                                fontSize: 15,
                                                letterSpacing: 1,
                                                color: Color(0xFF000000)
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ],
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 1,
                                            color: Color(0xFF000000)
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          // text: "CONNECT with other college students locally & globally\n",
                                          children: [
                                            TextSpan(
                                              text: "CONNECT",
                                              style: TextStyle(
                                                color: colors.paddygreen,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            TextSpan(
                                                text:
                                                    " with other college students locally & globally\n",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    letterSpacing: 1,
                                                    color: Color(0xFF000000)
                                                        .withOpacity(0.8),
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ])
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: SvgPicture.asset(
                            "assets/svgs/onboarding_${index + 1}.svg",
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    height: 12,
                    width: 12,
                    margin: EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                        color: index <= currentPageValue!.round()
                            ? colors.paddygreen
                            : colors.lightGrey,
                        shape: BoxShape.circle),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
                text: "Log In",
                width: 250,
                borderRadius: 3,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, MyApp.loginScreen);
                }),
            SizedBox(height: getSize(context, 30)),
            CustomButton(
                text: "Sign Up",
                width: 250,
                buttonType: ButtonType.two,
                borderRadius: 3,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, MyApp.signUpScreen);
                }),
          ],
        ),
      ),
    );
  }
}

class OnboardingDetails {
  final String mainText;
  final String subText;
  // final String imagePath;

  OnboardingDetails({required this.mainText, required this.subText});
}
