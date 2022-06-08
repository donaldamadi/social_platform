import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_paddy_mobile/utils/colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color? buttonColor;
  final bool enabled;
  final double borderRadius;
  final ButtonType buttonType;
  final Widget? buttonWidget;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final bool loading;
  final Color? loaderColor;
  CustomButton({
    required this.text,
    required this.onPressed,
    this.fontWeight,
    this.textSize,
    this.textColor,
    this.width = 156,
    this.height = 50,
    this.buttonColor = const Color(0xFF38957F),
    this.enabled = true,
    this.borderRadius = 30,
    this.buttonType = ButtonType.one,
    this.textStyle,
    this.loading = false,
    this.loaderColor,
    /*  = const TextStyle(color: Colors.white, fontSize: textSize, letterSpacing: 1, fontWeight: FontWeight.w800), */
    this.buttonWidget,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: widget.buttonType == ButtonType.one
              ? widget.buttonColor
              : Colors.transparent,
          // primary: widget.buttonType == ButtonType.one ? widget.buttonColor : Colors.white,

          shape: RoundedRectangleBorder(
            side: widget.buttonType == ButtonType.one
                ? BorderSide.none
                : BorderSide(
                    color: widget.buttonColor!,
                    width: 1,
                  ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        child: Center(
            child: widget.loading
                ? SpinKitThreeBounce(
                    size: 20,
                    color: widget.loaderColor == null
                        ? Colors.white
                        : widget.loaderColor,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.buttonWidget == null
                          ? SizedBox()
                          : widget.buttonWidget!,
                      widget.buttonWidget == null
                          ? SizedBox()
                          : SizedBox(width: 10),
                      AutoSizeText(widget.text,
                          style: widget.textStyle != null
                              ? widget.textStyle
                              : widget.buttonType == ButtonType.one
                                  ? TextStyle(
                                      color: widget.textColor ?? Colors.white,
                                      fontSize: widget.textSize ?? 15,
                                      letterSpacing: 0.2,
                                      fontWeight:
                                          widget.fontWeight ?? FontWeight.w600)
                                  : TextStyle(
                                      color:
                                          widget.textColor ?? colors.paddygreen,
                                      fontSize: widget.textSize ?? 15,
                                      letterSpacing: 0.2,
                                      fontWeight: widget.fontWeight ??
                                          FontWeight.w600)),
                    ],
                  )),
        onPressed: widget.enabled ? widget.onPressed : null,
      ),
    );
  }
}

enum ButtonType { one, two }
