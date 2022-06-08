
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Widget simpleButton(
    String text,
    BuildContext context,
    {
      double padV: 50, double padH: 200,
      double fontSize: 13, double borderRadius: 10,
      Color? backColor, Color? color, FontWeight? fontWeight,
      required Function onTap,
      bool loading = false,
      bool disabled = false,
      Color? loaderColor,
      Widget? child,
      bool haveBorder: false,
      double borderWidth: 1,
      Color borderColor: Colors.black,
      bool isChecking = false
    }
    ){
  return GestureDetector(
    onTap: (){
      if(disabled)return;
        onTap();
    },
    child: Container(
      height: getSize(context, padV),
      width: padH == getWidth(context) ? padH : getSize(context, padH),
      child: Stack(
        children: [
          Center(
            child: loading ? SpinKitThreeBounce(
              size: getSize(context, 20),
              color: loaderColor == null ? Colors.white : loaderColor,
            ):
            child == null ? textControl(text, context, size: fontSize,
                color: color == null ? Colors.white : color,
                fontWeight: fontWeight == null ? FontWeight.w600 : fontWeight):child,
          ),
          isChecking?Positioned.fill(child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Container(width:getSize(context, 10), height: getSize(context, 10),child: CircularProgressIndicator(strokeWidth:getSize(context, 3), valueColor: new AlwaysStoppedAnimation<Color>(colors.paddygreen))),
              ))): SizedBox()
        ],
      ),
      decoration: BoxDecoration(
          color: disabled ? Colors.grey :backColor == null ? colors.paddygreen : backColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: haveBorder ? Border.all(width: borderWidth, color: borderColor) : null
      ),
    ),
  );
}