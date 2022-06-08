import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class PeopleWidget extends StatefulWidget {
  final Map<String, dynamic> content;

  PeopleWidget({required this.content});

  @override
  _PeopleWidgetState createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {
  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context);
    return GestureDetector(
      onTap: () => pushNewScreen(context,
          screen: widget.content["_id"] == userModel.id
              ? ProfilePage()
              : OtherProfilePage(content: widget.content)),
      child: Container(
        height: 100,
        width: getWidth(context),
        child: Row(
          children: [
            CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.content["profilepic"])),
            SizedBox(width: getSize(context, 20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              textControl(
                                  "${widget.content["firstname"].toString().capitalizeString()} ${widget.content["lastname"].toString().capitalizeString()}",
                                  context,
                                  fontWeight: FontWeight.w800),
                              textControl(
                                  " @${widget.content["username"]}", context,
                                  overflow: true, size: 12)
                            ],
                          ),
                          Row(children: [
                            Image.asset("assets/pngs/grad_cap.png",
                                height: getSize(context, 12),
                                width: getSize(context, 10)),
                            SizedBox(width: getSize(context, 10)),
                            textControl(
                                widget.content["institution"] ?? "", context,
                                color: colors.textBlue, size: 13)
                          ])
                        ],
                      ),
                      SizedBox(width: getSize(context, 15)),
                      // CustomButton(text: "Follow", onPressed: () {}, width: getSize(context, 80), height: getSize(context, 30), buttonType: ButtonType.one, textSize: 10),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        textControl("Academic Status: ", context, size: 13),
                        textControl("Undergraduate '22", context,
                            size: 13, color: colors.textBlue, overflow: true)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: getWidth(context),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            textControl("Skills: ", context, size: 13),
                            textControl(
                                widget.content["skill_sets"] == null
                                    ? "No Skills"
                                    : (widget.content["skill_sets"]).join(", "),
                                context,
                                size: 13,
                                color: colors.textBlue,
                                overflow: true)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
