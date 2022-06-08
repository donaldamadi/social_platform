import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/gallery_viewer.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

NumberFormat nairaFormat =
    new NumberFormat.currency(locale: "en_US", symbol: "N");
NumberFormat numberFormat = new NumberFormat.decimalPattern();

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getSize(BuildContext context, double maxSize) {
  double deleteVariable = 600;
  if (getHeight(context) > 900 && getHeight(context) <= 1200) {
    deleteVariable = 700;
  } else if (getHeight(context) <= 900) {
    deleteVariable = 800;
  }
  double newSize = getHeight(context) * maxSize / deleteVariable;
  if (newSize > maxSize) {
    newSize = maxSize;
  }
  return newSize;
}

void closeKeyboard() {
  Future.delayed(Duration.zero, () {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  });
}

void unfocus(BuildContext context) {
  FocusScope.of(context).unfocus();
}

bool validateEmail(String value) {
  Pattern pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = new RegExp(pattern.toString());
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

void toastError(String message, BuildContext context, {int? seconds}) {
  closeKeyboard();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: textControl(message, context,
        fontWeight: FontWeight.w700, color: colors.backgroundWhite),
    duration: Duration(seconds: seconds ?? 5),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: "Close",
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void toastMessage(String message, BuildContext context, {int? seconds}) {
  closeKeyboard();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: textControl(message, context,
        fontWeight: FontWeight.w700, color: colors.backgroundWhite),
    duration: Duration(seconds: seconds ?? 5),
    backgroundColor: colors.blueColorOne,
    action: SnackBarAction(
      label: "Close",
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void toastSuccess(String message, BuildContext context, {int? seconds}) {
  closeKeyboard();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: textControl(message, context,
        fontWeight: FontWeight.w700, color: colors.backgroundWhite),
    duration: Duration(seconds: seconds ?? 5),
    backgroundColor: colors.paddygreen,
    action: SnackBarAction(
      label: "Close",
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget divider(BuildContext context,
    {Color backColor: const Color(0xFF000000),
    double height: 0.6,
    double? width}) {
  return Container(
    width: width == null ? getWidth(context) : getSize(context, width),
    decoration: BoxDecoration(
        border: Border(
      bottom: BorderSide(color: backColor.withOpacity(0.15), width: height),
    )),
  );
}

void openImage(BuildContext context, final int index, List<String> unitImages) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GalleryPhotoViewWrapper(
        galleryItems: unitImages,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        initialIndex: index,
        scrollDirection: Axis.horizontal,
      ),
    ),
  );
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body?.text).documentElement!.text;

  return parsedString;
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

scrollToBottom(ScrollController scrollController, {int? scrollAddition}) {
  scrollController.animateTo(
      scrollController.position.maxScrollExtent + (scrollAddition ?? 0),
      duration: Duration(milliseconds: 500),
      curve: Curves.ease);
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// Future<DateTime?> pickDate(BuildContext context, {String year = "1940", String month = "1", String day = "1", bool isFuture: false, bool fixedFirstDate = false, DateTime? initialDate, bool fixedLastDate = false, DateTime lastDate = DateTime(2100)}) {
//   return showDatePicker(
//     context: context,
//     initialDate: fixedFirstDate? DateTime(int.parse(year), int.parse(month), int.parse(day)) : initialDate == null ? DateTime.now() : initialDate,
//     firstDate: isFuture ? DateTime.now() : DateTime(int.parse(year), int.parse(month), int.parse(day)),
//     lastDate: fixedLastDate?lastDate:isFuture || fixedFirstDate ? DateTime(2100, int.parse(month), int.parse(day)): DateTime.now(),
//     builder: (context, child) {
//       return Theme(
//         data: ThemeData.dark(),
//         child: child!,
//       );
//     },
//   );
// }

Future<TimeOfDay?> pickTime(BuildContext context) {
  return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      });
}

copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text))
      .then((value) => Fluttertoast.showToast(msg: "Copied to clipboard"));
}

// 1. compress file and get Uint8List
Future<Uint8List> compressFileAndGetList(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 2300,
    minHeight: 1500,
    quality: 94,
    rotate: 90,
  );
  print(file.lengthSync());
  print(result?.length);
  return result!;
}

// 2. compress file and get file.
Future<File> compressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 88,
    rotate: 180,
  );

  print(file.lengthSync());
  print(result?.lengthSync());

  return result!;
}

// 3. compress asset and get Uint8List.
Future<Uint8List> compressAsset(String assetName) async {
  var list = await FlutterImageCompress.compressAssetImage(
    assetName,
    minHeight: 1920,
    minWidth: 1080,
    quality: 96,
    rotate: 180,
  );

  return list!;
}

// 4. compress Uint8List and get another Uint8List.
Future<Uint8List> compressList(Uint8List list) async {
  var result = await FlutterImageCompress.compressWithList(
    list,
    minHeight: 1920,
    minWidth: 1080,
    quality: 96,
    rotate: 135,
  );
  print(list.length);
  print(result.length);
  return result;
}

Future<File> compressFile(File file) async {
  final filePath = file.absolute.path;

  final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
  final splitted = filePath.substring(0, (lastIndex));
  final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    outPath,
    quality: 5,
  );

  debugPrint(file.lengthSync().toString());
  debugPrint(result?.lengthSync().toString());

  return result!;
}

// String uint8ListTob64(Uint8List uint8list) {
//   String base64String = base64Encode(uint8list);
//   String header = "data:image/png;base64,";
//   return header + base64String;
// }

// Uint8List b64Touint8List(String b64) {
//   Uint8List uint8list = b64.rea
//   return uint8list;
// }

// String path = "image.png";
// File file = File(path);
// Uint8List uint8list = file.readAsBytesSync();
// //or
// Uint8List uint8list = await file.readAsBytes();

Future<void> retrieveDynamicLink(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  try {
    //Called when app is terminated
    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink.toString().contains("/login")) {
      if (userModel.token != null) logoutUser(context, userModel.token!);
    }

    if (deepLink != null) {
      //  print("This is the link: ${deepLink.queryParameters.toString()}");
      //  print("Other link: ${deepLink.queryParameters}");
      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
    }

    //Called when app is in background
    dynamicLinks.onLink.listen((event) {
      Uri link = event.link;
      if (link.toString().contains("/login")) {
        if (userModel.token != null) logoutUser(context, userModel.token!);
      }
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}
