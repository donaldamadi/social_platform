import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Widget sortingWidgetContainer(BuildContext context, {bool status: false, bool canClose: true, Widget? child, Function? closeAlert}) {
  return IgnorePointer(
    ignoring: !status,
    child: Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (canClose) closeAlert!();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 30),
            height: getHeight(context),
            color: status ? Colors.black.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        AnimatedPositioned(
          right: 0,
          left: 0,
          bottom: status ? 0 : -getHeight(context),
          duration: Duration(milliseconds: 10),
          curve: Curves.easeIn,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: getWidth(context) / 10, vertical: getSize(context, 20)),
              decoration: BoxDecoration(
                  color: colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(getSize(context, 30)),
                    topRight: Radius.circular(getSize(context, 30)),
                  )),
              child: status ? child : SizedBox()),
        )
      ],
    ),
  );
}

Widget quickActionItem(BuildContext context, List<Widget> children, {VoidCallback? close, Function(String)? select}) {
  return Container(
    child: Column(
      children: [
        Center(
          child: Container(
            width: getSize(context, 100),
            height: getSize(context, 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: colors.blueColorOne),
          ),
          // child: divider(context, width: 100, height: 3, backColor: Colors.grey.withOpacity(0.5)),
        ),
        SizedBox(height: getSize(context, 20)),
        Column(
          children: children,
        ),
        SizedBox(height: getSize(context, 20)),
        CustomButton(
          width: getWidth(context),
          buttonColor: colors.blueColorOne,
            text: "Cancel",
            onPressed: () {
              close!();
            })
      ],
    ),
  );
}

Widget itemContent(BuildContext context, String text, {bool isActive: false, bool isLast: false, Function? onTap, Widget? icon}) {
  return GestureDetector(
    onTap: onTap!(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          children: [icon ?? Icon(Icons.add_circle, color: colors.blueColorOne), SizedBox(width: getSize(context, 20)), textControl(text, context, size: 15)],
        ),
        SizedBox(
          height: 20,
        ),
        isLast ? SizedBox() : divider(context, backColor: Colors.grey.withOpacity(0.2))
      ],
    ),
  );
}

List quickActionTypeTwo(BuildContext context, {Function? onTap, String? id}) {
  List<Widget> quickActionTypes = [];
  quickActionTypes.add(itemContent(context, "Share", icon: SvgPicture.asset("assets/svgs/share.svg"), onTap: () {}));
  quickActionTypes.add(itemContent(context, "Bookmark", icon: SvgPicture.asset("assets/svgs/bookmark.svg"), onTap: () {}));
  quickActionTypes.add(itemContent(context, "Block User", icon: SvgPicture.asset("assets/svgs/block_user.svg"),  onTap: () {}));
  quickActionTypes.add(itemContent(context, "Report content", icon: SvgPicture.asset("assets/svgs/report_content.svg"),  onTap: () {}));
  quickActionTypes.add(itemContent(context, "Unfollow user", icon: SvgPicture.asset("assets/svgs/unfollow_user.svg"),  onTap: () {}));
  return quickActionTypes;
}