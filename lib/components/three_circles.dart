import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Widget threeCircles (int index, BuildContext context){
  return Row(
    children: [
      Container(
        height: getSize(context, 12),
        width: getSize(context, 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: index == 1 ? Border.all(color: colors.paddygreen) : Border(),
          color: index == 1 ? Colors.transparent : colors.paddygreen
        ),
      ),
      SizedBox(width: getSize(context, 3)),
      Container(
        height: getSize(context, 12),
        width: getSize(context, 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: index == 2 ? Border.all(color: colors.paddygreen) : Border(),
          color: index == 2 ? Colors.transparent : colors.paddygreen
        ),
      ),
      SizedBox(width: getSize(context, 3)),
      Container(
        height: getSize(context, 12),
        width: getSize(context, 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: index == 3 ? Border.all(color: colors.paddygreen) : Border(),
          color: index == 3 ? Colors.transparent : colors.paddygreen
        ),
      ),
      SizedBox(width: getSize(context, 3)),
    ],
  );
}