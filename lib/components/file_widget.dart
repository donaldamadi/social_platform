import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class FileWidget extends StatefulWidget {
  final Map<String, dynamic> content;

  FileWidget({required this.content});

  @override
  _FileWidgetState createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
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
              CircleAvatar(backgroundImage: AssetImage("assets/pngs/man.jpg"), radius: 20),
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
                        Image.asset("assets/pngs/grad_cap.png", height: 12, width: 10),
                        SizedBox(width: getSize(context, 3)),
                        textControl(widget.content["createdBy"]["institution"] ?? "", context, fontWeight: FontWeight.w800, size: 10, color: colors.textBlue.withOpacity(0.7)),
                        SizedBox(width: getSize(context, 3)),
                        textControl("Engineering", context, fontWeight: FontWeight.w800, size: 10, color: colors.textBlue)
                      ],
                    ),
                    SizedBox(height: getSize(context, 5)),
                    SizedBox(height: getSize(context, 10)),
                    SizedBox(height: getSize(context, 5)),
                    // Align(alignment: Alignment.topLeft, child: textControl("Question", context, size: 13, color: colors.textBlue)),
                    Container(
                        height: 205,
                        width: getWidth(context),
                        decoration: BoxDecoration(color: colors.paddygreen, borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: SizedBox.expand(
                          child: InkWell(
                            onTap: () {
                            },
                            child: Center(
                              child: Icon(Icons.insert_drive_file, size: 100, color: colors.backgroundWhite.withOpacity(0.8)),
                            ),
                          ),
                        )),
                    SizedBox(height: getSize(context, 5)),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SvgPicture.asset("assets/svgs/question_answered.svg", height: 15, width: 15),
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
          // divider(context)
        ],
      ),
    );
  }
}
