import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_dropdown_field.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/three_circles.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup_2.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class QuickProfileOne extends StatefulWidget {
  const QuickProfileOne({Key? key}) : super(key: key);

  @override
  _QuickProfileOneState createState() => _QuickProfileOneState();
}

class _QuickProfileOneState extends State<QuickProfileOne> {
  String? academicStatus;
  TextEditingController firstNameController = TextEditingController();
  String? keyword = "";
  TextEditingController lastNameController = TextEditingController();
  Map<String, dynamic> profileData = {};
  TextEditingController skillSetController = TextEditingController();
  List<dynamic> skillSets = [];
  List<dynamic> skillsList = [];
  List<dynamic> skillsNameList = [];
  Map<String, dynamic>? userMap;
  TextEditingController userNameController = TextEditingController();
  bool userNameExists = false;
  bool isLoading = false;
  TextEditingController institutionController = TextEditingController();
  List<dynamic> schoolsList = [];
  List<dynamic> schoolNameList = [];

  @override
  void initState() {
    super.initState();
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    //  print(userModel.userData);
    userNameController.text = userModel.userData!["username"] ??
        userModel.userData!["data"]["username"];
  }

  searchSchools(keyword) async {
    schoolsList = await getSchools(context, keyword);
    schoolNameList.clear();
    for (var i in schoolsList) {
      schoolNameList.add(i["name"]);
    }
    setState(() {});
  }

  searchSkills(String keyword) async {
    skillsList = await getSkills(context, keyword);
    skillsNameList.clear();
    for (var i in skillsList) {
      skillsNameList.add(i["name"]);
    }
    setState(() {});
  }

  checkUser(String keyword) async {
    userMap = await checkUsername(context, keyword);
    //  print(userMap!["data"]);
    userNameExists = userMap!["data"];
    setState(() {});
    return userMap!["data"];
  }

  next() async {
    if (firstNameController.text.isEmpty || firstNameController.text == "") {
      toastError("Fill in your first name", context);
    } else if (lastNameController.text.isEmpty ||
        lastNameController.text == "") {
      toastError("Fill in your last name", context);
    } else if (institutionController.text.isEmpty ||
        institutionController.text.trim() == "") {
      toastError("Please fill in your institution", context);
    } else if (academicStatus == null) {
      toastError("Choose your academic status", context);
    } else {
      //  print(skillSets);
      profileData = {
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        /* "username": userNameController.text.trim(), */
        "academic_status": academicStatus!.toLowerCase(),
        "institution": institutionController.text.trim(),
        // "skill_sets": skillSets
      };
      //  print(profileData);
      setState(() {
        isLoading = true;
      });
      bool res = await updateUserProfile(context, profileData);
      await activateAccount(context, {"active": true});
      setState(() {
        isLoading = false;
      });
      if (res) Get.to(() => QuickProfileTwo(data: profileData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(context, "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getSize(context, 20)),
              isLoading
                  ? SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    )
                  : SizedBox(),
              CustomTextField(
                  header: "First Name",
                  hintText: "First Name",
                  controller: firstNameController),
              SizedBox(height: getSize(context, 30)),
              CustomTextField(
                  header: "Last Name",
                  hintText: "Last Name",
                  controller: lastNameController),
              SizedBox(height: getSize(context, 30)),
              CustomTextField(
                  enabled: false,
                  header: "Username",
                  hintText: "Username",
                  controller: userNameController,
                  onChanged: (val) {
                    keyword = val;
                    setState(() {
                      if (val.isNotEmpty) {
                        checkUser(val);
                      } else {
                        userMap = null;
                      }
                    });
                  }),
              userMap != null
                  ? userNameExists
                      ? textControl("Username exists", context,
                          color: colors.red, size: 12)
                      : SizedBox()
                  : SizedBox(),
              SizedBox(height: getSize(context, 30)),
              CustomDropDown(
                dropdownlist: ["Undergraduate", "Graduate", "Postgraduate"],
                onChanged: (val) {
                  academicStatus = val.toString();
                },
                header: "Academic Status",
                hintText: "E.g Undergraduate",
              ),
              SizedBox(height: getSize(context, 30)),
              CustomTextField(
                  header: "Your Higher Institution",
                  hintText: "e.g University of Lagos",
                  controller: institutionController,
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      searchSchools(val);
                    }
                  }),
              schoolNameList.isNotEmpty
                  ? ListView.builder(
                      itemCount: schoolNameList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            institutionController.text = schoolNameList[index];
                            schoolNameList.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: textControl(schoolNameList[index], context),
                          ),
                        );
                      })
                  : SizedBox(),
              SizedBox(height: getSize(context, 50)),
              Center(
                  child: CustomButton(
                      text: "Next",
                      onPressed: () => next(),
                      buttonType: ButtonType.one)),
              SizedBox(height: getSize(context, 50)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [threeCircles(1, context)],
              ),
              SizedBox(height: getSize(context, 30)),
            ],
          ),
        ),
      ),
    );
  }
}
