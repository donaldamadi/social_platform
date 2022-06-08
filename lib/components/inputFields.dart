import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:student_paddy_mobile/components/searchable_dropdown.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class NumberTextInputFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 4) {
      if(newTextLength < 7){
        newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ' ');
        if (newValue.selection.end >= 3) selectionIndex += 1;
      }

      else if(newTextLength >= 7){
        newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ' ' + newValue.text.substring(3, usedSubstringIndex = 6) + ' ');
        if (newValue.selection.end >= 6) selectionIndex += 2;
      }


    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class CustomRangeTextInputFormatter extends TextInputFormatter {

  int min;
  int max;

  CustomRangeTextInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,TextEditingValue newValue,) {
    if(newValue.text == '')
      return TextEditingValue().copyWith(text: "");
    else if(int.parse(newValue.text) < min){
      Fluttertoast.showToast(msg: "Minimum value is $min", backgroundColor: Colors.red, textColor: Colors.white);
      return TextEditingValue().copyWith(text: min.toString());
    }
    else if(int.parse(newValue.text) > max){
      Fluttertoast.showToast(msg: "Maximum value is $max", backgroundColor: Colors.red, textColor: Colors.white);
      return TextEditingValue().copyWith(text: max.toString());
    }
    return newValue;
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {

      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;


      NumberFormat f = NumberFormat("#,###");

      if(newValue.text.contains(".")){
        if(newValue.text.substring(newValue.text.length - 1) == "."){
          if(oldValue.text.length > newValue.text.length){
            f = NumberFormat("#,###");
          }
          else{
            f = NumberFormat("#,###.");
          }
        }
        else{
          f = NumberFormat("#,###.##");
        }
      }

      final number = double.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
            offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}

Widget
textInputField(BuildContext context, {double borderRadius: 7, dynamic value = "", double height: 50, Function? onChange, String? placeholder:"", double fontSize: 14, bool noBorder: false,
  FocusNode? focusNode, String? errorText, bool multiLine: false, String? type = "text", bool autofocus = false, bool isDate: false, Color backColor: Colors.white, Color? placeholderColor, double placeholderSize: 13, Color? borderColor,
  bool range: false, int min: 0, int max: 0, bool disabled=false, Function? passwordToggle, Function? dateTap, bool passwordState: true, Widget? leftSide, double leftSize: 0, TextEditingController? textEditingController, bool formatNumber = true,
  bool isChecking = false, int? maxLength, Key? key, double padding = 20}){
  List<TextInputFormatter> formatList = [];
  if (formatNumber) {
    if(type == "number"){
      formatList.add(NumericTextFormatter());
      if(range){
        formatList.add(CustomRangeTextInputFormatter(min, max));
      }
    }
  }
  if(borderColor == null)borderColor = Colors.black.withOpacity(0.3);
  return Container(
      width: getWidth(context),
      height: height,
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: noBorder ? null : Border.all(width: 1, color: borderColor)
      ),
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Stack(
        children: [
          leftSide != null ? Positioned.fill(child: Align(
            alignment: Alignment.centerLeft,
            child: leftSide,
          )) : SizedBox(),
          TextFormField(
            key: key,
            controller: textEditingController,
            autofocus: autofocus,
            style: TextStyle(
              fontSize: fontSize,
              // fontFamily: fonts.ptSans,
              fontWeight: FontWeight.w500,
              color: disabled ? Colors.black.withOpacity(0.3):placeholderColor!=null?placeholderColor:Colors.black,
            ),
            onChanged: (e){
              if(type == "number"){
                onChange!(e.replaceAll(",", ""));
              }
              else{
                onChange!(e);
              }
            },
            obscureText: type == "password" && passwordState,
            focusNode: focusNode,
            initialValue: textEditingController == null ? type == "number" && formatNumber ? value == null || value == "" ? "" :
            numberFormat.format(double.parse(value.toString())).toString() : value == null ? "": value.toString() : null,
            enabled: !disabled && !isDate,
            keyboardType: type == "multiline" ? TextInputType.multiline : type == "number" ? TextInputType.number : TextInputType.text,
            inputFormatters: formatList,
            textAlignVertical: TextAlignVertical.center,
            maxLines: type == "multiline" ? null : 1,
            maxLength: maxLength,
            decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                errorText: errorText,
                contentPadding: EdgeInsets.only(left: getSize(context, leftSize), top: getSize(context, 15), bottom: getSize(context, 15)),
                counterText: "",
                hintText: placeholder,
                hintStyle: TextStyle(
                    fontSize: getSize(context, placeholderSize),
                    // fontFamily: fonts.ptSans,
                    color: placeholderColor == null ? Colors.black.withOpacity(0.3) : placeholderColor
                )
            ),
          ),
          type == "password" ? Positioned.fill(child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(onTap: passwordToggle as void Function()?, child: Icon(passwordState ? Icons.visibility : Icons.visibility_off, size: 18),),
          )) :type == "date"?Positioned.fill(child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(onTap: dateTap as void Function()?, child: Icon(Icons.calendar_today, size: 18),))): isChecking?Positioned.fill(child: Align(
              alignment: Alignment.centerRight,
              child: Container(width:getSize(context, 10), height: getSize(context, 10),child: CircularProgressIndicator(strokeWidth:getSize(context, 3), valueColor: new AlwaysStoppedAnimation<Color>(colors.paddygreen))))): SizedBox()
        ],
      ),
  );
}

Widget inputSelectField(BuildContext context, {double borderRadius: 7, String? placeholder, String? value, required List<String> itemList, double fontSize: 14, bool noBorder: false,
  Function(String?)? onSelect, double height: 50, double? width, Color borderColor: Colors.grey, dynamic key, double padding: 20}){
  return Container(
      width: width == null ? getWidth(context) : getSize(context, width),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
          border: noBorder ? null : Border.all(width: 1, color: borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: getSize(context, padding)),
      child: Center(
        child: DropdownButtonFormField(
          isExpanded: true,
          key: key,
          onChanged: onSelect,
          value: value != null && value != "null"  ? value :  null,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.paddygreen,),
          decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              hintText: placeholder,
              contentPadding: EdgeInsets.only(top: getSize(context, 11), bottom: getSize(context, 11)),
              hintStyle: TextStyle(
                  fontSize: getSize(context, fontSize),
                  // fontFamily: fonts.ptSans,
                  color: Colors.black.withOpacity(0.3)
              ),
              isDense: true
          ),
          iconSize: getSize(context, 20),
          style: TextStyle(
              fontSize: getSize(context, fontSize),
              // fontFamily: fonts.ptSans,
              color: Colors.grey
          ),
          items: itemList.map((String val) {
            return DropdownMenuItem(
              key: ValueKey(val),
              value: val,
              child: Text(val,),
            );
          }).toList(),
        ),
      )
  );
}

Widget inputSelectFieldTwo(BuildContext context, {double borderRadius: 14, required String placeholder, required List<String?> itemList, double fontSize: 14, bool noBorder: false,
  required Function onSelect, double height: 50, double? width, Color borderColor: Colors.black, dynamic key, double padding: 10, bool icon = true}){
  return Container(
      width: width == null ? getWidth(context) : getSize(context, width),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: noBorder ? null : Border.all(width: 1, color: borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: getSize(context, padding)),
      child: Center(
        child: SearchableDropdown(
          isExpanded: true,
          key: key,
          onChanged: onSelect,
          icon: icon ? Icon(Icons.keyboard_arrow_down, color: colors.paddygreen) : null,
          iconSize: getSize(context, 20),
          selectedValueWidgetFn: (item) {
            return Container(
              width: width == null ? getWidth(context) : getSize(context, width),
              child: textControl(item, context, size: getSize(context, fontSize), color: Colors.grey, textAlign: TextAlign.start, fontWeight: FontWeight.w400),
            );
          },
          underline: SizedBox(),
          hint: Text(placeholder, style: TextStyle(
              fontSize: getSize(context, fontSize),
              // fontFamily: fonts.ptSans,
              color: Colors.black.withOpacity(0.3)
          ),),
          style: TextStyle(
              fontSize: getSize(context, fontSize),
              // fontFamily: fonts.ptSans,
              color: Colors.blueGrey
          ),
          items: itemList.map((String? val) {
            return DropdownMenuItem(
              key: ValueKey(val),
              value: val,
              child: Text(val!,),
            );
          }).toList(),
        ),
      )
  );
}


Widget inputWithSelectField(BuildContext context, {bool isLeft: true, String? type, Function(String?)? onSelect, Function? onChange, double height: 40, double? width, double borderRadius: 7, dynamic textController, dynamic selectController,
  String? placeholder, String? value, String? selectValue, List<String>? itemList, Color borderColor: Colors.black, Color backColor: Colors.white, double placeholderSize: 15, double selectWidth: 100, bool formatNumber = true, double textPadding = 20}){

  Widget getSelectItem(){
    return Container(
      width: getSize(context, selectWidth),
      decoration: BoxDecoration(
        border: Border(
          right: !isLeft ? BorderSide.none : BorderSide(width: 1, color: borderColor),
          left: isLeft ? BorderSide.none : BorderSide(width: 1, color: borderColor),
        )
      ),
      child: inputSelectField(context, itemList: itemList!, value: selectValue, height: height, onSelect: onSelect, noBorder: true, key: selectController, padding: 10),
    );
  }

  return Container(
    width: getWidth(context),
    decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(width: 1, color: borderColor)
    ),
    child: Flex(
      direction: Axis.horizontal,
      children: [
        isLeft ? getSelectItem() : SizedBox(),
        Flexible(
          flex: 1,
          child: textInputField(context, onChange: onChange, placeholder: placeholder, value: value, type: type, height: height, noBorder: true, textEditingController: textController, formatNumber: formatNumber, padding: textPadding),
        ),
        !isLeft ? getSelectItem() : SizedBox(),
      ],
    ),
  );

}

// Widget inputFieldWithSearchableDropDown(BuildContext context, String title, String placeholder, List<String> itemList,
//     {Function (String)? onChange, String? value, Key? key}){
//   return  Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       title == "" ? SizedBox() : textControl(title, context, size: 14, fontWeight: FontWeight.w600),
//       SizedBox(height: getSize(context, 5),),
//       inputSelectFieldTwo(context, itemList: itemList, placeholder: placeholder, onSelect: (value)=>onChange!(value),
//   borderColor: colors.blueColor.withOpacity(0.1), backColor: colors.blueColor.withOpacity(0.1), value: value, key: key),
//     ],
//   );
// }

Widget sliderWidget(BuildContext context, {Function? onSelect, double value = 0.0, double min:1, double max: 10}){
  return Slider(
      value: value,
      min: min,
      max: max,
      divisions: 10,
      activeColor: colors.paddygreen,
      inactiveColor: colors.borderGrey,
      label: value.round().toString(),
      onChanged: onSelect as void Function(double)?,
      semanticFormatterCallback: (double newValue) {
        return '${newValue}km';
      }
  );
}

Widget datePicker(BuildContext context, {Function? onSelect, String? value, required double height, double borderRadius = 16, DateTime? startTime}){
  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startTime == null ? selectedDate : startTime,
        firstDate: DateTime(1900),
        // firstDate: startTime == null ? selectedDate.subtract(Duration(days: 0)) : startTime,
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      onSelect!("${picked.toLocal()}".split(' ')[0]);
  }

  String selected = value == null ? "select date" : value;

  return GestureDetector(
    onTap: () => _selectDate(context),
    child: Container(
      height: getSize(context, height < 50 ? 50 : height),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          // border: Border.all(color: borderGrey, width: 2.0)
          // boxShadow: [
          //   BoxShadow(
          //       color: Colors.black.withOpacity(0.01),
          //       blurRadius: 10,
          //       spreadRadius: 2,
          //       offset: Offset.fromDirection(1, 10)
          //   )
          // ]
      ),
      padding: EdgeInsets.symmetric(horizontal: getSize(context, 10)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: textControl(selected, context, size: 15),
      ),
    ),
  );
}

Widget radioButton(BuildContext context, {Function(dynamic)? onClick, dynamic status, dynamic value, Widget? extra, double width = 20}){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Radio(
        value: value,
        onChanged: onClick,
        groupValue: status,
        visualDensity: VisualDensity.compact,
      ),
      SizedBox(width: getSize(context, width),),
      extra == null ? SizedBox() : extra
    ],
  );
}

Widget toggleButton(BuildContext context, {Function? onClick,  bool value: false, Widget? extra}){
  return Switch(
    value: value,
    onChanged: onClick as void Function(bool)?,
  );
}

Widget checkBox(BuildContext context, {Function? onClick,  bool value: false, Widget? extra, bool isLeft: true}){
  return Container(
    child: Row(
      children: [
        isLeft ? extra! : SizedBox(),
        isLeft ? SizedBox(width: getSize(context, 10),) : SizedBox(),
        Checkbox(
          value: value,
          onChanged: onClick as void Function(bool?)?,
        ),
        !isLeft ? SizedBox(width: getSize(context, 10),) : SizedBox(),
        !isLeft ? extra! : SizedBox(),

      ],
    ),
  );
}