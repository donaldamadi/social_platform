import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

///Custom TextField
// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final String header;
  final String? hintText;
  final TextEditingController? controller;
  // final Widget prefix;
  final String? type;
  void Function(String)? onChanged;
  final double hintSize;
  final Widget? icon;
  final bool? autoFocus;
  final FocusNode? focusNode;
  final Color? hintTextColor;
  final double? hintTextSize;
  final Color? headerTextColor;
  final double? headerTextSize;
  final bool border;
  final bool multiline;
  final int? maxLines;
  final Color? borderColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool? enabled;
  final int? maxLength;

///Custom TextField
  CustomTextField({
    required this.header,
    this.hintText,
    this.controller,
    this.maxLength,
    this.type,
    this.onChanged,
    this.hintSize = 14,
    this.icon,
    this.autoFocus,
    this.focusNode,
    this.hintTextColor,
    this.hintTextSize,
    this.headerTextColor,
    this.headerTextSize,
    this.border = true,
    this.multiline = false,
    this.maxLines = 1,
    this.borderColor,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureState = true;

  void togglePassword() {
    setState(() {
      obscureState = !obscureState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.header == ""
            ? SizedBox()
            : textControl(
                widget.header,
                context,
                fontWeight: FontWeight.w700,
                size: widget.headerTextSize ?? 18,
                color: widget.headerTextColor,
              ),
        SizedBox(height: 8),
        Container(
          height: widget.height,
          width: widget.width,
          child: TextField(
            maxLength: widget.maxLength,
            enabled: widget.enabled! ? true : false,
            focusNode: widget.focusNode ?? null,
            autofocus: widget.autoFocus ?? false,
            style: TextStyle(fontSize: 17, letterSpacing: 0.3),
            onChanged: widget.onChanged,
            keyboardType: widget.type == "Password"
                ? TextInputType.visiblePassword
                : widget.type == "Email"
                    ? TextInputType.emailAddress
                    : widget.multiline
                        ? TextInputType.multiline
                        : null,
            maxLines: widget.maxLines ?? null,
            inputFormatters: widget.type == "Username"
                ? [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]"))]
                : [],
            obscureText: widget.type == "Password" ? obscureState : false,
            controller: widget.controller,
            cursorColor: colors.paddygreen,
            cursorHeight: 19.0,
            decoration: InputDecoration(
                prefixIcon: widget.icon ?? null,
                prefixIconConstraints:
                    BoxConstraints(minHeight: 35, minWidth: 35),
                contentPadding: widget.border
                    ? EdgeInsets.symmetric(horizontal: 15, vertical: 5)
                    : EdgeInsets.zero,
                suffixIcon: widget.type == "Password"
                    ? InkWell(
                        onTap: togglePassword,
                        child: Icon(obscureState
                            ? Icons.visibility
                            : Icons.visibility_off),
                      )
                    : null,
                hintText: widget.hintText ?? "",
                hintStyle: TextStyle(
                    fontSize: widget.hintTextSize ?? widget.hintSize,
                    color: widget.hintTextColor ?? colors.lightGrey,
                    fontFamily: fonts.avenir,
                    letterSpacing: 0),
                border: widget.border
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(widget.borderRadius ?? 30)),
                        borderSide: BorderSide(
                            color: widget.borderColor ?? Color(0xFF6D6E71),
                            width: 3.0),
                      )
                    : InputBorder.none,
                focusedBorder: widget.border
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(widget.borderRadius ?? 14)),
                        borderSide: BorderSide(
                            color: widget.borderColor ?? colors.paddygreen,
                            width: 2.0),
                      )
                    : InputBorder.none),
          ),
        )
      ],
    );
  }
}

class AppBarTextField extends StatefulWidget {
  final TextEditingController? controller;

  AppBarTextField({this.controller});

  @override
  _AppBarTextFieldState createState() => _AppBarTextFieldState();
}

class _AppBarTextFieldState extends State<AppBarTextField> {
  GlobalKey<FormState>? key;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 30,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              'assets/svgs/search_icon.svg',
              height: 90,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: key,
              controller: widget.controller,
              cursorColor: colors.paddygreen,
              cursorHeight: 19,
              decoration:
                  InputDecoration.collapsed(hintText: "Search Student Paddy"),
              style: TextStyle(fontFamily: fonts.avenir, letterSpacing: 1.5),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: colors.paddygreen.withAlpha(150)),
      ),
    );
  }
}

class CustomContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final Widget child;
  final String? header;
  final double? borderRadius;

  CustomContainer(
      {this.height,
      this.width,
      required this.child,
      this.header,
      this.borderRadius});

  @override
  CcustomContainerState createState() => CcustomContainerState();
}

class CcustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.header == null
            ? SizedBox()
            : textControl(widget.header!, context,
                fontWeight: FontWeight.w700, size: 18),
        SizedBox(height: 8),
        Container(
          height: widget.height == null
              ? 50
              : widget.height == 0
                  ? null
                  : widget.height,
          width: widget.width == null ? getWidth(context) : widget.height,
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF6D6E71), width: 0.7),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 30)),
          child: widget.child,
        ),
      ],
    );
  }
}
