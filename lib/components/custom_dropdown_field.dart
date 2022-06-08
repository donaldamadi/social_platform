import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';

class CustomDropDown extends StatefulWidget {
  @override
  _CustomDropDownState createState() => _CustomDropDownState();

  final String? hintText;
  final String? header;
  final List dropdownlist;
  final String? fieldKey;
  final double? borderRadius;
  void Function(Object?) onChanged;
  Object? value;
  CustomDropDown(
      {required this.dropdownlist,
      this.header,
      this.hintText,
      this.fieldKey,
      this.borderRadius,
      required this.onChanged,
      this.value});
}

class _CustomDropDownState extends State<CustomDropDown> {
  dynamic currentSelectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.header != null
            ? textControl(widget.header!, context,
                fontWeight: FontWeight.w700, size: 18)
            : SizedBox(),
        widget.header != null ? SizedBox(height: 5) : SizedBox(),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),
              border: Border.all(color: Color(0xFF6D6E71)),
            ),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle:
                      TextStyle(color: colors.lightGrey.withOpacity(0.7))),
              value: widget.value,
              style: TextStyle(fontSize: 24, color: Colors.grey),
              icon: Container(
                child: Center(
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
              onChanged: widget.onChanged,
              items: widget.dropdownlist.map((category) {
                return DropdownMenuItem(
                  child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      child: Text(category,
                          style:
                              TextStyle(fontSize: 14, color: Colors.black87))),
                  value: category,
                );
              }).toList(),
            )),
      ],
    );
  }
}
