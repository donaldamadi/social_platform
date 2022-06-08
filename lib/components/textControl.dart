import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Text textControl(String text, BuildContext context,
    {

    /// custom Text Widget
    FontWeight fontWeight: FontWeight.w600,
    String? font,
    TextDirection? textDirection,
    double height: 1.5,
    Key? key,
    double size: 14,
    Color? color,
    bool underline: false,
    double spacing: 0.3,
    TextAlign textAlign: TextAlign.start,
    bool? overflow,
    FontStyle? fontStyle,
    int? maxLines,
    double? wordSpacing}) {
  if (color == null) {
    color = Colors.black;
  }

  if (font == null) {
    font = fonts.avenir;
  }
  return Text(
    text,
    textDirection: textDirection,
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: overflow != null ? TextOverflow.ellipsis : null,
    style: TextStyle(
        wordSpacing: wordSpacing,
        fontSize: getSize(
            context,
            ((370 <= getWidth(context) && getWidth(context) <= 380) &&
                    (662 <= getHeight(context) && getHeight(context) <= 672))
                ? size + 2.0
                : ((410 <= getWidth(context) && getWidth(context) <= 418) &&
                        (891 <= getHeight(context) &&
                            getHeight(context) <= 900))
                    ? size + 0.5
                    : size),
        fontFamily: font,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: spacing,
        height: height,
        decoration: underline ? TextDecoration.underline : null,
        fontStyle: fontStyle),
    key: key,
  );
}



SelectableText selectableTextControl(String text, BuildContext context,
    {

    /// custom Text Widget
    FontWeight fontWeight: FontWeight.w600,
    String? font,
    TextDirection? textDirection,
    double height: 1.5,
    Key? key,
    double size: 14,
    Color? color,
    bool underline: false,
    double spacing: 0.3,
    TextAlign textAlign: TextAlign.start,
    bool? overflow,
    FontStyle? fontStyle,
    int? maxLines,
    double? wordSpacing}) {
  if (color == null) {
    color = Colors.black;
  }

  if (font == null) {
    font = fonts.avenir;
  }
  return SelectableText(
    text,
    textDirection: textDirection,
    maxLines: maxLines,
    textAlign: textAlign,
    // overflow: overflow != null ? TextOverflow.ellipsis : null,
    style: TextStyle(
        wordSpacing: wordSpacing,
        fontSize: getSize(
            context,
            ((370 <= getWidth(context) && getWidth(context) <= 380) &&
                    (662 <= getHeight(context) && getHeight(context) <= 672))
                ? size + 2.0
                : ((410 <= getWidth(context) && getWidth(context) <= 418) &&
                        (891 <= getHeight(context) &&
                            getHeight(context) <= 900))
                    ? size + 0.5
                    : size),
        fontFamily: font,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: spacing,
        height: height,
        decoration: underline ? TextDecoration.underline : null,
        fontStyle: fontStyle),
    key: key,
  );
}
