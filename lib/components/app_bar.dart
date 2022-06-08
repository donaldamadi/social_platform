import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

AppBar customAppBar(BuildContext context, String title, {Widget? actions, bool isBackButton = true, Widget? subTitle, void Function()? onPressed}) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: Colors.black),
      title: Container(
        width: getWidth(context),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          isBackButton ? IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onPressed ?? () {
              Navigator.pop(context);
            },
          ) : SizedBox(width: getSize(context, 50)),
          Column(
            mainAxisAlignment: subTitle != null ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              textControl(title, context, fontWeight: FontWeight.w800, size: 18),
              subTitle ?? SizedBox()
            ],
          ),
          actions ?? SizedBox(width: getSize(context, 50))
        ]),
      ),
    );
  }