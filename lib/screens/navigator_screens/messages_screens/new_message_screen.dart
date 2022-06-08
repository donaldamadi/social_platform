import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/chat_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  List<dynamic> usersList = [];
  TextEditingController searchController = TextEditingController();
  String? id;
  Map<String, dynamic>? chatMap;
  bool isLoading = false;

  complete(String value) async {
    usersList = await autoCompleteUser(context, value);
    //  print(usersList);
    setState(() {});
  }

  send() async {
    if (id == null) {
      toastMessage("Please select a valid user", context);
    } else {
      setState(() {
        isLoading = true;
      });
      chatMap = await initiateChat(context, {"participant": id});
      setState(() {
        isLoading = false;
      });
      if (chatMap!.isNotEmpty) {
        pushNewScreen(context, screen: ChatScreen(content: chatMap!["data"]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "New Message"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getSize(context, 20)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                textControl("To:", context, color: colors.borderGrey, size: 15),
                SizedBox(width: getSize(context, 10)),
                Expanded(
                  child: CustomTextField(
                    controller: searchController,
                    height: 40,
                    header: "",
                    hintText: "Search for new users",
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        id = null;
                        complete(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 20),
                isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator())
                    : SizedBox(),
                // SizedBox(width: getSize(context, 15)),
                // IconButton(
                //   icon: Icon(Icons.send),
                //   onPressed: () => send(),
                //   color: colors.blueColorOne,
                //   padding: EdgeInsets.zero,
                //   constraints: BoxConstraints(),
                // ),
              ],
            ),
          ),
          SizedBox(height: getSize(context, 20)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: textControl("Suggested", context,
                fontWeight: FontWeight.w800, size: 18),
          ),
          SizedBox(height: getSize(context, 20)),
          Expanded(
            child: ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // searchController.text = usersList[index]["firstname"] == null ? usersList[index]["username"] : usersList[index]["firstname"] + " " + usersList[index]["lastname"];
                    id = usersList[index]["_id"];
                    send();
                  },
                  child: Container(
                    height: 80,
                    width: getWidth(context),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                              backgroundImage:
                                  NetworkImage(usersList[index]["profilepic"]),
                              radius: 25),
                          SizedBox(width: getSize(context, 20)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  width: getWidth(context) - 120,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        textControl(
                                            usersList[index]["firstname"] ==
                                                    null
                                                ? usersList[index]["username"]
                                                : usersList[index]
                                                        ["firstname"] +
                                                    " " +
                                                    usersList[index]
                                                        ["lastname"],
                                            context,
                                            overflow: true),
                                        SizedBox(width: 10),
                                        textControl(
                                            "@" + usersList[index]["username"],
                                            context,
                                            size: 12)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Image.asset("assets/pngs/grad_cap.png",
                                        height: 10),
                                    SizedBox(width: getSize(context, 4)),
                                    textControl(
                                        usersList[index]["institution"] ?? "",
                                        context,
                                        size: 11,
                                        color: colors.textBlue,
                                        overflow: true),
                                  ],
                                ),
                              ),
                              // Expanded(child: divider(context))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
