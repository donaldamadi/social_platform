import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/actions_screen/comment.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final String link;

  LinkWidget({required this.content, required this.link});

  @override
  _LinkWidgetState createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  var previewData;

  TextStyle? textStyle = TextStyle(
    fontSize: 13,
    fontFamily: fonts.avenir,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    height: 1.5,
  );

  Future<void> onOpen(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: getSize(context, 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundImage: AssetImage("assets/pngs/profile_icon.png"), radius: 20),
              SizedBox(width: getSize(context, 15)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        textControl("Joseph Morgan", context, fontWeight: FontWeight.w800),
                        SizedBox(width: getSize(context, 5)),
                        textControl("@Nachikpong.", context, size: 10, fontWeight: FontWeight.w500),
                        SizedBox(width: getSize(context, 5)),
                        textControl("2d", context, size: 10, fontWeight: FontWeight.w500)
                      ],
                    ),
                    SizedBox(height: getSize(context, 5)),
                    Row(
                      children: [
                        Image.asset("assets/pngs/grad_cap.png", height: getSize(context, 12), width: getSize(context, 10)),
                        SizedBox(width: getSize(context, 3)),
                        textControl(widget.content["createdBy"]["institution"] ?? "", context, fontWeight: FontWeight.w800, size: 10, color: colors.textBlue.withOpacity(0.7)),
                        SizedBox(width: getSize(context, 3)),
                        textControl("Engineering", context, fontWeight: FontWeight.w800, size: 10, color: colors.textBlue)
                      ],
                    ),
                    SizedBox(height: getSize(context, 5)),
                    LinkPreview(
                      padding: EdgeInsets.zero,
                      width: getWidth(context),
                      enableAnimation: true,
                      text: widget.link,
                      linkStyle: TextStyle(
                        fontSize: getSize(context, 13),
                        fontFamily: fonts.avenir,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        height: 1.5,
                      ),
                      headerStyle: TextStyle(fontSize: getSize(context, 13)),
                      metadataTitleStyle: textStyle?.copyWith(fontWeight: FontWeight.w700),
                      metadataTextStyle: textStyle,
                      previewData: previewData,
                      onPreviewDataFetched: (data) {
                        setState(() {
                          previewData = data;
                        });
                      },
                    ),
                    SizedBox(height: getSize(context, 10)),
                    SizedBox(height: getSize(context, 5)),
                    // textControl(widget.link, context, size: 13, color: colors.textBlue),
                    SizedBox(height: getSize(context, 5)),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset("assets/svgs/question_answered.svg", height: 15, width: 15),
                            onPressed: () => pushNewScreen(context, screen: CommentScreen(content: widget.content), withNavBar: false),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          Row(children: [
                            Icon(Icons.arrow_upward, size: 14, color: colors.textBlue),
                            SizedBox(width: getSize(context, 4)),
                            textControl("15", context, size: 9, color: colors.textBlue)
                          ]),
                          Row(children: [
                            Icon(Icons.arrow_downward, size: 14, color: colors.textBlue),
                            SizedBox(width: getSize(context, 4)),
                            textControl("103", context, size: 9, color: colors.textBlue)
                          ]),
                          SvgPicture.asset("assets/svgs/refresh.svg", height: 15, width: 15),
                          // SizedBox(width: getSize(context, 50)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz, size: 15), padding: EdgeInsets.zero, constraints: BoxConstraints())
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: getSize(context, 10)),
          divider(context)
        ],
      ),
    );
  }
}
