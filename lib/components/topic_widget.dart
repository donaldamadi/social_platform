import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/topic_screens/single_topic.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class TopicWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  TopicWidget({required this.content});

  @override
  _TopicWidgetState createState() => _TopicWidgetState();
}

class _TopicWidgetState extends State<TopicWidget> {
  List<dynamic> tempFollowers = [];

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
      height: 65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox.expand(
              child: InkWell(
                onTap: () {
                  pushNewScreen(context,
                      screen: SingleTopic(content: widget.content),
                      withNavBar: false);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textControl(widget.content["name"], context,
                        overflow: true),
                    Row(
                      children: [
                        textControl("Contributions", context,
                            overflow: true,
                            size: 12,
                            fontWeight: FontWeight.w300,
                            color: colors.textBlue),
                        SizedBox(width: getSize(context, 5)),
                        textControl(
                            (widget.content["contributions"] ?? 0).toString(),
                            context,
                            overflow: true,
                            fontWeight: FontWeight.w400),
                        SizedBox(width: getSize(context, 5)),
                        textControl("Followers", context,
                            overflow: true,
                            size: 12,
                            fontWeight: FontWeight.w300,
                            color: colors.textBlue),
                        SizedBox(width: getSize(context, 5)),
                        textControl(
                            widget.content["followers"] != null
                                ? widget.content["followers"].length.toString()
                                : "0",
                            context,
                            overflow: true,
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomButton(
            text: (widget.content["followers"] == null
                    ? tempFollowers.contains(userModel.id)
                    : widget.content["followers"].contains(userModel.id))
                ? "Following"
                : "Follow",
            onPressed: () {
              setState(() {
                if ((widget.content["followers"] == null
                    ? tempFollowers.contains(userModel.id)
                    : widget.content["followers"].contains(userModel.id))) {
                  widget.content["followers"] == null
                      ? tempFollowers.remove(userModel.id)
                      : widget.content["followers"].remove(userModel.id);
                  followUnfollowTopic(
                      context, widget.content["name"], {"action": "unfollow"});
                } else {
                  widget.content["followers"] == null
                      ? tempFollowers.add(userModel.id)
                      : widget.content["followers"].add(userModel.id);
                  followUnfollowTopic(
                      context, widget.content["name"], {"action": "follow"});
                }
              });
            },
            width: 80,
            height: 30,
            textSize: 12,
            buttonType: (widget.content["followers"] == null
                    ? tempFollowers.contains(userModel.id)
                    : widget.content["followers"].contains(userModel.id))
                ? ButtonType.one
                : ButtonType.two,
          )
        ],
      ),
    );
  }
}
