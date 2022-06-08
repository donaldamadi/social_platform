import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/components/three_circles.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup3.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/navigatorPage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class QuickProfileTwo extends StatefulWidget {
  final Map<String, dynamic> data;
  QuickProfileTwo({required this.data});

  @override
  _QuickProfileTwoState createState() => _QuickProfileTwoState();
}

class _QuickProfileTwoState extends State<QuickProfileTwo> {
  TextEditingController institutionController = TextEditingController();
  TextEditingController facultyController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  List<dynamic> schoolsList = [];
  List<dynamic> schoolNameList = [];
  String? yearOfGrad;
  Map<String, dynamic> profileData = {};
  DateTime? currentDate;
  bool isLoading = false;
  DateTime? selectedDate;
  List<dynamic> skillSets = [];
  List<dynamic> skillsList = [];
  List<dynamic> skillsNameList = [];
  TextEditingController skillSetController = TextEditingController();

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

  // skip() async {}

  next() async {
    if (facultyController.text.isEmpty || facultyController.text == "") {
      toastError("Please fill in your faculty", context);
    } else if (departmentController.text.isEmpty ||
        departmentController.text == "") {
      toastError("Please fill in your department", context);
    } else if (yearOfGrad == null) {
      toastError("Please pick a graduation year", context);
    } else {
      profileData = {
        ...widget.data,
        "skill_sets": skillSets,
        "faculty": facultyController.text.trim(),
        "department": departmentController.text.trim(),
        "graduation_year": yearOfGrad,
      };
      //  print(profileData);
      setState(() {
        isLoading = true;
      });
      bool res = await updateUserProfile(context, profileData);
      // await activateAccount(context, {"active": true});
      setState(() {
        isLoading = false;
      });
      if (res) Get.to(() => QuickProfileThree(data: profileData));
    }
  }

  Future<void> selectDate(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (yearOfGrad != null && yearOfGrad != "null")
          ? DateTime.parse(yearOfGrad!.toString() + "01" + "01")
          : DateTime(DateTime.now().year),
      firstDate: userModel.userData!["academic_status"] == "graduate"
          ? DateTime(1940)
          : DateTime(DateTime.now().year),
      lastDate: userModel.userData!["academic_status"] == "graduate"
          ? DateTime(DateTime.now().year)
          : DateTime(2050),
    );
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        yearOfGrad = currentDate?.year.toString();
      });
    //  print(currentDate?.year.toString());
  }

  Future<void> selectYear(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Year"),
          content: Container(
            // Need to use container to add size constraint.
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: widget.data["academic_status"] == "graduate"
                  ? DateTime(1940)
                  : DateTime(DateTime.now().year),
              lastDate: widget.data["academic_status"] == "graduate"
                  ? DateTime(DateTime.now().year)
                  : DateTime(2050),
              initialDate: DateTime.now(),
              // save the selected date to _selectedDate DateTime variable.
              // It's used to set the previous selected date when
              // re-showing the dialog.
              selectedDate: selectedDate ?? DateTime.now(),
              onChanged: (DateTime dateTime) {
                // close the dialog when year is selected.
                setState(() {
                  currentDate = dateTime;
                  yearOfGrad = currentDate?.year.toString();
                });
                Navigator.pop(context);
                // Do something with the dateTime selected.
                // Remember that you need to use dateTime.year to get the year
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, 'Profile'),
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
                header: "Skill Set",
                hintText: "Skill Set",
                controller: skillSetController,
                onChanged: (val) {
                  setState(() {
                    if (val.isNotEmpty) {
                      searchSkills(val);
                    }
                  });
                },
              ),
              skillsList.isNotEmpty
                  ? ListView.builder(
                      itemCount: skillsList.length <= 5 ? skillsList.length : 5,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // skillSetController.text = skillsList[index]["name"];
                            skillSets.add(skillsList[index]["name"]);
                            skillsList.clear();
                            skillSetController.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: textControl(skillsNameList[index], context),
                          ),
                        );
                      })
                  : skillSetController.text.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            skillSets.add(skillSetController.text.trim());
                            skillsList.clear();
                            skillSetController.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child:
                                textControl(skillSetController.text, context),
                          ),
                        )
                      : SizedBox(),
              Wrap(
                  spacing: 5,
                  children: skillSets.map((skill) {
                    return Chip(
                      label: textControl(skill, context, color: colors.white),
                      backgroundColor: colors.paddygreen,
                      deleteIcon: Icon(Icons.cancel, color: colors.white),
                      onDeleted: () {
                        setState(() {
                          skillSets.remove(skill);
                        });
                      },
                    );
                  }).toList()),
              SizedBox(height: getSize(context, 30)),
              CustomTextField(
                  header: "Your Faculty", controller: facultyController),
              SizedBox(height: getSize(context, 30)),
              CustomTextField(
                  header: "Your Department", controller: departmentController),
              SizedBox(height: getSize(context, 30)),
              CustomContainer(
                  header: widget.data["academic_status"] == "graduate"
                      ? "Year of graduation"
                      : "Expected year of graduation",
                  child: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: textControl(
                            yearOfGrad == null
                                ? widget.data["academic_status"] == "graduate"
                                    ? "Select your year of graduation"
                                    : "Select an expected year of graduation"
                                : yearOfGrad.toString(),
                            context,
                            size: 15,
                            color: colors.textBlack),
                      ),
                      onTap: () => selectYear(context))),
              SizedBox(height: getSize(context, 50)),
              Center(
                child: CustomButton(
                    text: "Next",
                    onPressed: () => next(),
                    buttonType: ButtonType.one),
              ),
              SizedBox(height: getSize(context, 30)),
              Center(
                child: CustomButton(
                    text: "Skip",
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      bool result =
                          await getUserDetails(context, userModel.token!);
                      if (result) {
                        setState(() {
                          isLoading = false;
                        });
                        Get.offAll(NavigatorPage());
                      }
                    },
                    buttonType: ButtonType.two),
              ),
              SizedBox(height: getSize(context, 60)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [threeCircles(2, context)],
              ),
              SizedBox(height: getSize(context, 30)),
            ],
          ),
        ),
      ),
    );
  }
}
