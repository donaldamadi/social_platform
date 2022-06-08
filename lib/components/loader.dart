import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Widget loaderMain(BuildContext context, {bool status=false, Color? containerColor, double? size, Color? color, double? height, double? width}){
  if(!status){
    return SizedBox();
  }
  return Container(
    height: height ?? getHeight(context),
    width: width ?? getWidth(context),
    color: containerColor == null ?Colors.transparent:containerColor,
    child: Center(
      child: SpinKitThreeBounce(
        size: size!=null?getSize(context, size):getSize(context, 40),
        color: color ?? colors.paddygreen,
      )
    ),
  );
}