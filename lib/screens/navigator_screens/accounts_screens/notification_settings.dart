import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  Map<String, dynamic> notifSettings = {};
  bool followingContent = false;
  bool follow = false;
  bool mentions = false;
  bool comments = false;
  bool answer = false;
  bool upvotes = false;
  bool reposts = false;
  bool topics = false;
  bool messages = false;
  bool community = false;
  bool edits = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      populateSettings(context);
    });
  }

  populateSettings(BuildContext context) {
    UserOnBoardChangeNotifierModel userOnBoardModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    notifSettings =
        userOnBoardModel.userData!["data"]["settings"]["notificationsettings"];
    //  print(notifSettings);
    setState(() {
      followingContent = notifSettings["followingContent"];
      follow = notifSettings["follow"];
      mentions = notifSettings["mentions"];
      comments = notifSettings["comments"];
      answer = notifSettings["answer"];
      upvotes = notifSettings["upvotes"];
      reposts = notifSettings["reposts"];
      topics = notifSettings["topics"];
      messages = notifSettings["messages"];
      community = notifSettings["community"];
      edits = notifSettings["edits"];
    });
  }

  submitData() async {
    setState(() {
      isLoading = true;
    });
    UserOnBoardChangeNotifierModel userOnBoardModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    Map<String, dynamic> data = {
      "followingContent": followingContent,
      "follow": follow,
      "mentions": mentions,
      "comments": comments,
      "answer": answer,
      "upvotes": upvotes,
      "reposts": reposts,
      "topics": topics,
      "messages": messages,
      "community": community,
      "edits": edits,
    };
    bool res = await updateNotifSettings(context, data);
    if (res) {
      notifSettings = userOnBoardModel.userData!["data"]["settings"]
          ["notificationsettings"];
      notifSettings["followingContent"] = followingContent;
      notifSettings["follow"] = follow;
      notifSettings["mentions"] = mentions;
      notifSettings["comments"] = comments;
      notifSettings["answer"] = answer;
      notifSettings["upvotes"] = upvotes;
      notifSettings["reposts"] = reposts;
      notifSettings["topics"] = topics;
      notifSettings["messages"] = messages;
      notifSettings["community"] = community;
      notifSettings["edits"] = edits;
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerWidget(context, "Notification Settings"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(),
                    GestureDetector(
                        onTap: () => submitData(),
                        child: textControl("Save", context,
                            color: colors.paddyLightGreen,
                            size: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: getSize(context, 30)),
                textControl("Notify on", context, size: 18),
                SizedBox(height: getSize(context, 20)),
                selectSettingsWidget(
                    context, "New content shared by users I follow",
                    checked: followingContent, onChanged: (newValue) {
                  setState(() {
                    followingContent = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "New content shared on topics I follow",
                    checked: topics, onChanged: (newValue) {
                  setState(() {
                    topics = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "Answers to questions I ask or reask",
                    checked: answer, onChanged: (newValue) {
                  setState(() {
                    answer = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "Upvotes on my content and content I am tagged on",
                    checked: upvotes, onChanged: (newValue) {
                  setState(() {
                    upvotes = newValue!;
                  });
                }),
                selectSettingsWidget(context, "Reposts on my content",
                    checked: reposts, onChanged: (newValue) {
                  setState(() {
                    reposts = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "Comment on my content and replies to my content",
                    checked: comments, onChanged: (newValue) {
                  setState(() {
                    comments = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "Comments on content I am tagged on",
                    checked: mentions, onChanged: (newValue) {
                  setState(() {
                    mentions = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "New messages and replies to my messages",
                    checked: messages, onChanged: (newValue) {
                  setState(() {
                    messages = newValue!;
                  });
                }),
                selectSettingsWidget(context, "New users that follow me",
                    checked: follow, onChanged: (newValue) {
                  setState(() {
                    follow = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "New topic added to a community I follow",
                    checked: community, onChanged: (newValue) {
                  setState(() {
                    community = newValue!;
                  });
                }),
                selectSettingsWidget(
                    context, "Edits to content I interact with", checked: edits,
                    onChanged: (newValue) {
                  setState(() {
                    edits = newValue!;
                    //  print(edits);
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget selectSettingsWidget(BuildContext context, String text,
      {bool checked = false, Function(bool?)? onChanged}) {
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
              onChanged: onChanged,
            )
          ],
        ),
      );
    });
  }
}

Widget headerWidget(BuildContext context, String text) {
  return Container(
    height: getSize(context, 50),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.chevron_left),
      ),
      textControl(text, context, size: 17, fontWeight: FontWeight.w900),
      SizedBox(width: getSize(context, 60))
    ]),
  );
}
