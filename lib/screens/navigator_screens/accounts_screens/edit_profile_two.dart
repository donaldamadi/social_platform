import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_dropdown_field.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/edit_profile_three.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class EditProfileTwo extends StatefulWidget {
  final Map<String, dynamic> data;
  EditProfileTwo({required this.data});

  @override
  _EditProfileTwoState createState() => _EditProfileTwoState();
}

class _EditProfileTwoState extends State<EditProfileTwo> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController skillSetController = TextEditingController();
  String? academicStatus;
  List<dynamic> skillSets = [];
  // List<dynamic> initialSkillSets = [];
  bool isLoading = false;
  Map<String, dynamic> userData = {};
  List<dynamic> skillsList = [];
  List<dynamic> skillsNameList = [];

  searchSkills(String keyword) async {
    skillsList = await getSkills(context, keyword);
    skillsNameList.clear();
    for (var i in skillsList) {
      skillsNameList.add(i["name"]);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    //  print(userModel.userData!["data"]["academic_status"]);
    firstNameController.text = userModel.userData!["data"]["firstname"];
    lastNameController.text = userModel.userData!["data"]["lastname"];
    academicStatus = userModel.userData!["data"]["academic_status"];
    skillSets = userModel.userData!["data"]["skill_sets"] ?? [];
    // skillSets = userModel.userData!["data"]["skill_sets"] ?? [];
  }

  next() async {
    userData = {
      ...widget.data,
      "firstname": firstNameController.text.trim(),
      "lastname": lastNameController.text.trim(),
      "academic_status":
          academicStatus == null ? null : academicStatus!.toLowerCase(),
      "skill_sets": skillSets,
    };
    pushNewScreen(context, screen: EditProfileThree(data: userData));
  }

  save() async {
    setState(() {
      isLoading = true;
    });
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    userData = {
      ...widget.data,
      "firstname": firstNameController.text.trim(),
      "lastname": lastNameController.text.trim(),
      "academic_status": academicStatus,
      "skill_sets": skillSets,
    };
    bool res = await updateUserProfile(context, userData);
    if (res) {
      bool result = await getUserDetails(context, userModel.token!);
      if (result) {
        Navigator.of(context)
          ..pop()
          ..pop()
          ..pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, "Edit Profile"),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: getSize(context, 10)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              isLoading
                  ? Container(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(color: colors.paddygreen))
                  : Container(),
              GestureDetector(
                onTap: () => save(),
                child: textControl("Save", context,
                    color: colors.paddygreen, size: 16),
              ),
            ]),
            SizedBox(height: getSize(context, 20)),
            CustomTextField(
                header: "First Name",
                controller: firstNameController,
                hintText: "First Name"),
            SizedBox(height: getSize(context, 30)),
            CustomTextField(
                header: "Last Name",
                controller: lastNameController,
                hintText: "Last Name"),
            SizedBox(height: getSize(context, 30)),
            CustomDropDown(
              value: academicStatus == null
                  ? null
                  : academicStatus.toString().capitalizeString(),
              dropdownlist: ["Undergraduate", "Graduate", "Postgraduate"],
              onChanged: (val) {
                academicStatus = val.toString();
              },
              header: "Academic Status",
              hintText: "E.g Undergraduate",
            ),
            SizedBox(height: getSize(context, 30)),
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
                          child: textControl(skillSetController.text, context),
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
            // CustomContainer(
            //   height: 0,
            //   header: "Skill Set",
            //   child: MultiSelectDialogField(
            //     initialValue: [],
            //     searchHint: "",
            //     searchable: true,
            //     items: skills.map((e) => MultiSelectItem(e, e)).toList(),
            //     onConfirm: (values) {
            //       skillSets = values;
            //       //  print(skillSets);
            //     },
            //     decoration: BoxDecoration(border: Border()),
            //   ),
            // ),
            SizedBox(height: getSize(context, 80)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: textControl("Back", context,
                      size: 17, color: colors.paddygreen),
                ),
                GestureDetector(
                  onTap: () => next(),
                  child: textControl("Next", context,
                      size: 17, color: colors.paddygreen),
                ),
              ],
            ),
          ]),
        )));
  }
}
