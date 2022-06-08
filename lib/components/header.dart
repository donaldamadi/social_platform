import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';

Widget headerWidget (BuildContext context, {required Function() onTap,required String text}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Icon(Icons.chevron_left, size: 24),
      textControl(text, context, size: 21),
      Container(width: 35)
    ],
  );
}