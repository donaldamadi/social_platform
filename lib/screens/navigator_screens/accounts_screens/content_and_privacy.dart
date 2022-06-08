import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/notification_settings.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ContentAndPrivacyPage extends StatefulWidget {
  const ContentAndPrivacyPage({Key? key}) : super(key: key);

  @override
  _ContentAndPrivacyPageState createState() => _ContentAndPrivacyPageState();
}

class _ContentAndPrivacyPageState extends State<ContentAndPrivacyPage> {
  Map<String, dynamic> contentAndPrivacySettings = {};
  bool disallowMessages = false;
  bool videoAutoplays = false;
  bool customHomeFeed = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      populateContentAndPrivacy(context);
    });
  }

  submitData() async {
    setState(() {
      isLoading = true;
    });
    UserOnBoardChangeNotifierModel userOnBoardModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    bool res = await updateContentAndPrivacy(context, {
      "disAllowMessages": disallowMessages,
      "videoAutoplays": videoAutoplays,
      "customHomeFeed": customHomeFeed
    });
    if (res) {
      // toastSuccess("Settings saved successfully", context);
      contentAndPrivacySettings =
          userOnBoardModel.userData!["data"]["settings"];
      contentAndPrivacySettings["disAllowMessages"] = disallowMessages;
      contentAndPrivacySettings["videoAutoplays"] = videoAutoplays;
      contentAndPrivacySettings["customHomeFeed"] = customHomeFeed;
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  populateContentAndPrivacy(BuildContext context) {
    UserOnBoardChangeNotifierModel userOnBoardModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    contentAndPrivacySettings = userOnBoardModel.userData!["data"]["settings"];
    //  print(contentAndPrivacySettings);
    setState(() {
      disallowMessages = contentAndPrivacySettings["disAllowMessages"];
      videoAutoplays = contentAndPrivacySettings["videoAutoplays"];
      customHomeFeed = contentAndPrivacySettings["customHomeFeed"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            headerWidget(context, "Content & Privacy"),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: () {
                  submitData();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(),
                    textControl("Save", context,
                        color: colors.paddyLightGreen,
                        size: 14,
                        fontWeight: FontWeight.w500),
                  ],
                ),
              ),
            ),
            Container(
              height: getSize(context, 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: textControl(
                          "Allow no one on student paddy to send message",
                          context,
                          size: 12,
                          fontWeight: FontWeight.w400)),
                  Checkbox(
                      value: disallowMessages,
                      onChanged: (newValue) {
                        setState(() {
                          disallowMessages = newValue!;
                        });
                      })
                ],
              ),
            ),
            Container(
              height: getSize(context, 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: textControl("Allow video autoplays", context,
                          size: 12, fontWeight: FontWeight.w400)),
                  Checkbox(
                      value: videoAutoplays,
                      onChanged: (newValue) {
                        setState(() {
                          videoAutoplays = newValue!;
                        });
                      })
                ],
              ),
            ),
            Container(
              height: getSize(context, 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: textControl(
                          "Home page feeds should include contents for topics, resource, etc.",
                          context,
                          size: 12,
                          fontWeight: FontWeight.w400)),
                  Checkbox(
                      value: customHomeFeed,
                      onChanged: (newValue) {
                        setState(() {
                          customHomeFeed = newValue!;
                        });
                      })
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget selectSettingsWidget(BuildContext context, String text,
      {bool checked = false}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: getSize(context, 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: textControl(text, context,
                    size: 12, fontWeight: FontWeight.w400)),
            Checkbox(
                value: checked,
                onChanged: (newValue) {
                  setState(() {
                    checked = newValue!;
                  });
                })
          ],
        ),
      );
    });
  }
}
