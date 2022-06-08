import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/modal_sheet_bar.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/auth_screens/login_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  bool checkEnabled(context) {
    if (emailController.text.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  resetPassword(BuildContext context) async {
    bool res =
        await resetUserPassword(context, {"email": emailController.text});
    if (res) {
      Navigator.pop(context);
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => BackToLogin());
    }
  }

  validateData() {
    closeKeyboard();
    if (!validateEmail(emailController.text)) {
      toastError('Please enter a valid email', context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.concealer,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: getHeight(context) * 0.85,
          child: Column(
            children: [
              ModalSheetBar(text: 'Forgot Password'),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Enter your email address and we would send you a link so you can reset your password'),
                    SizedBox(height: 25),
                    CustomTextField(
                        header: 'Email Address',
                        hintText: "johndoe@example.com",
                        onChanged: (value) => setState(() {
                              emailController.text = value;
                            })),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                          enabled: checkEnabled(context),
                          text: 'CONFIRM',
                          onPressed: () {
                            validateData();
                            resetPassword(context);
                          }),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class BackToLogin extends StatelessWidget {
  final bool verification;
  BackToLogin({this.verification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.concealer,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: getHeight(context) * 0.85,
          child: Column(
            children: [
              ModalSheetBar(
                  text: 'Back to Login', extension: true, page: LoginScreen()),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verification
                        ? Text(
                            'A verification link has been sent to pde@gmail.com. Please click on the link to verify your email, then come back and login with your credentials.')
                        : Text(
                            'An email has been sent to pde@gmail.com. Please follow the instructions in the mail'),
                    SizedBox(height: 40),
                    Center(
                      child: Container(
                          child:
                              SvgPicture.asset('assets/svgs/paddy_smiley.svg')),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class ForgotPasswordScreen1 extends StatefulWidget {
  const ForgotPasswordScreen1({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreen1State createState() => _ForgotPasswordScreen1State();
}

class _ForgotPasswordScreen1State extends State<ForgotPasswordScreen1> {
  TextEditingController emailController = TextEditingController();

  validateData(BuildContext context) async {
    closeKeyboard();
    if (emailController.text.isEmpty) {
      toastError("Please provide your email address", context);
      return;
    } else if (!validateEmail(emailController.text.trim())) {
      toastError('Please enter a valid email address', context);
      return;
    }
    bool res = await resetUserPassword(
        context, {"email": emailController.text.trim()});
    if (res) {
      Get.off(() => PasswordConfirmation(emailController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: getSize(context, 70)),
              Center(
                  child: textControl("Forgot Password", context,
                      size: 26, fontWeight: FontWeight.w900, spacing: 2)),
              SizedBox(height: getSize(context, 20)),
              textControl(
                  "Please input your email below and wait for a verification mail.",
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center),
              SizedBox(height: getSize(context, 50)),
              CustomTextField(
                borderRadius: 3,
                header: 'Email',
                hintText: "Email",
                controller: emailController,
              ),
              SizedBox(height: getSize(context, 70)),
              CustomButton(
                  borderRadius: 3,
                  text: "Confirm",
                  onPressed: () {
                    validateData(context);
                  },
                  width: getWidth(context)),
            ],
          )),
    );
  }
}

class PasswordConfirmation extends StatefulWidget {
  final String email;
  PasswordConfirmation(this.email);

  @override
  _PasswordConfirmationState createState() => _PasswordConfirmationState();
}

class _PasswordConfirmationState extends State<PasswordConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: getSize(context, 70)),
            Center(
                child: textControl("Password Confirmation", context,
                    size: 26, fontWeight: FontWeight.w900, spacing: 2)),
            SizedBox(height: getSize(context, 50)),
            textControl(
                "An email has been successfully sent to ${widget.email.trim()}, please follow the instructions given in the mail.",
                context,
                size: 18,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
