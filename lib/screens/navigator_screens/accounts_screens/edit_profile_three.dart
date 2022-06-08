import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class EditProfileThree extends StatefulWidget {
  final Map<String, dynamic> data;
  EditProfileThree({required this.data});

  @override
  _EditProfileThreeState createState() => _EditProfileThreeState();
}

class _EditProfileThreeState extends State<EditProfileThree> {
  TextEditingController institutionController = TextEditingController();
  TextEditingController facultyController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  List<dynamic> schoolsList = [];
  List<dynamic> schoolNameList = [];
  String? yearOfGrad;
  Map<String, dynamic> userData = {};
  DateTime? currentDate;
  bool isLoading = false;
  DateTime? selectedDate;

  searchSchools(keyword) async {
    schoolsList = await getSchools(context, keyword);
    schoolNameList.clear();
    for (var i in schoolsList) {
      schoolNameList.add(i["name"]);
    }
    setState(() {});
  }

  save() async {
    setState(() {
      isLoading = true;
    });
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    userData = {
      ...widget.data,
      "institution": institutionController.text.trim(),
      "faculty": facultyController.text.trim(),
      "department": departmentController.text.trim(),
      "graduation_year": yearOfGrad,
    };
    bool res = await updateUserProfile(context, userData);
    if (res) {
      bool result = await getUserDetails(context, userModel.token!);
      if (result) {
        // Get.off(NavigatorPage());
        Navigator.of(context)
          ..pop()
          ..pop()
          ..pop()
          ..pop();
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    //  print(yearOfGrad);
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: (yearOfGrad != null && yearOfGrad != "null")
            ? DateTime.parse(yearOfGrad!.toString() + "01" + "01")
            : DateTime(DateTime.now().year),
        firstDate: widget.data["academic_status"] == "graduate"
            ? DateTime(1940)
            : DateTime(DateTime.now().year),
        lastDate: widget.data["academic_status"] == "graduate"
            ? DateTime(DateTime.now().year + 1)
            : DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        yearOfGrad = currentDate?.year.toString();
      });
    //  print(currentDate?.year.toString());
    //  print(yearOfGrad);
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
  void initState() {
    super.initState();
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    institutionController.text =
        userModel.userData!["data"]["institution"] ?? "";
    facultyController.text = userModel.userData!["data"]["faculty"] ?? "";
    departmentController.text = userModel.userData!["data"]["department"] ?? "";
    yearOfGrad = userModel.userData!["data"]["graduation_year"]
        .toString()
        .substring(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(context, "Edit Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getSize(context, 20)),
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
                      color: colors.paddygreen, size: 16)),
            ]),
            SizedBox(height: getSize(context, 20)),
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
            SizedBox(height: getSize(context, 80)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: textControl("Back", context,
                  size: 17, color: colors.paddygreen),
            ),
          ]),
        ),
      ),
    );
  }
}
