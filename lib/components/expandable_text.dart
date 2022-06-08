import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:student_paddy_mobile/components/measure_widget_size.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/fonts.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/userOnBoardModel.dart';
import '../screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'custom_url_launcher.dart';
import 'multi_image_viewer.dart';

class ExpandableText extends StatefulWidget {
  ExpandableText(
      {required this.text,
      required this.onTap,
      this.isHtml = true,
      this.images = const []});

  final bool? isHtml;
  final String text;
  final bool onTap;
  List<String> images = [];

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  //  var onTap;
  void Function(String? d, RenderContext x, Map<String, String> f, Element? e)?
      onTap;
  Size childSize = Size.zero;
  GlobalKey contentKey = GlobalKey();

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Column(
      children: <Widget>[
        Container(
          child: ConstrainedBox(
            constraints: isExpanded
                ? BoxConstraints()
                : BoxConstraints(maxHeight: 100.0),
            child: MeasureSize(
              onChange: (size) {
                childSize = size;
                setState(() {});
              },
              child: SingleChildScrollView(
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                child: HtmlWidget(
                  "<p>${widget.text.trim()}</p>",
                  customWidgetBuilder: (element) {
                    // print(element.localName);
                    return null;
                  },
                  isSelectable: widget.onTap ? false : true,
                  key: contentKey,
                  customStylesBuilder: (element) {
                    if (element.classes.contains('tag')) {
                      return {
                        // 'color': 'blue',
                        // "content": "@",
                        'text-decoration': 'none',
                        'font-weight': 'bold'
                      };
                    }

                  },
                  onTapUrl: (url) async {
                    print(url);
                    print(url.contains('profile/'));
                    if (url.contains("/profile/")) {
                      print(url);
                      String id = url.split('/profile/')[1];
                      id = id.replaceAll(RegExp("([^0-9A-Za-z])"), "");
                      print(id);
                      print(userModel.id);
                      id != userModel.id
                          ? pushNewScreen(context,
                              screen: OtherProfilePage(content: {"_id": id}))
                          : pushNewScreen(context, screen: ProfilePage());
                      return false;
                    } else {
                      if (await canLaunch(url)) {
                        await CustomLauncher().launchURL(context, url);
                        return true;
                        // await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }
                  },
                  textStyle: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: getSize(
                        context,
                        ((370 <= getWidth(context) &&
                                    getWidth(context) <= 380) &&
                                (662 <= getHeight(context) &&
                                    getHeight(context) <= 672))
                            ? 16
                            : ((410 <= getWidth(context) &&
                                        getWidth(context) <= 418) &&
                                    (891 <= getHeight(context) &&
                                        getHeight(context) <= 900))
                                ? 15
                                : 14),
                    fontFamily: fonts.avenir,
                    letterSpacing: 0.1,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    wordSpacing: 0.4,
                  ),
                ),
              ),
              // child: widget.onTap
              //     ? Html(
              //         shrinkWrap: true,
              //         key: contentKey,
              //         data: widget.text.trim(),
              //         onLinkTap:
              //             (url, renderContext, attributes, element) async {
              //           if (await canLaunch(url!)) {
              //             await CustomLauncher().launchURL(context, url);
              //             // await launch(url);
              //           } else {
              //             throw 'Could not launch $url';
              //           }
              //         },
              //         style: {
              //           'html': Style(textAlign: TextAlign.left),
              //           "body": Style(
              //             margin: EdgeInsets.zero,
              //             padding: EdgeInsets.zero,
              //             fontSize: FontSize(getSize(
              //                 context,
              //                 ((370 <= getWidth(context) &&
              //                             getWidth(context) <= 380) &&
              //                         (662 <= getHeight(context) &&
              //                             getHeight(context) <= 672))
              //                     ? 16
              //                     : ((410 <= getWidth(context) &&
              //                                 getWidth(context) <= 418) &&
              //                             (891 <= getHeight(context) &&
              //                                 getHeight(context) <= 900))
              //                         ? 15
              //                         : 14)),
              //             fontFamily: fonts.avenir,
              //             letterSpacing: 0.1,
              //             color: Colors.black,
              //             fontWeight: FontWeight.w400,
              //             wordSpacing: 0.4,
              //           )
              //         },
              //       )
              //     :
              //     AbsorbPointer(
              //   absorbing: widget.onTap ? true : false,
              //   child: SelectableHtml(
              //     scrollPhysics: NeverScrollableScrollPhysics(),
              //     shrinkWrap: true,
              //     key: contentKey,
              //     data: widget.text.trim(),
              //     onLinkTap: (url, renderContext, attributes, element) async {
              //       if (await canLaunch(url!)) {
              //         await CustomLauncher().launchURL(context, url);
              //         // await launch(url);
              //       } else {
              //         throw 'Could not launch $url';
              //       }
              //     },
              //     style: {
              //       'html': Style(textAlign: TextAlign.left),
              //       "body": Style(
              //         margin: EdgeInsets.zero,
              //         padding: EdgeInsets.zero,
              //         fontSize: FontSize(getSize(
              //             context,
              //             ((370 <= getWidth(context) &&
              //                         getWidth(context) <= 380) &&
              //                     (662 <= getHeight(context) &&
              //                         getHeight(context) <= 672))
              //                 ? 16
              //                 : ((410 <= getWidth(context) &&
              //                             getWidth(context) <= 418) &&
              //                         (891 <= getHeight(context) &&
              //                             getHeight(context) <= 900))
              //                     ? 15
              //                     : 14)),
              //         fontFamily: fonts.avenir,
              //         letterSpacing: 0.1,
              //         color: Colors.black,
              //         fontWeight: FontWeight.w400,
              //         wordSpacing: 0.4,
              //       )
              //     },
              //   ),
              // ),
            ),
          ),
        ),
        // ),
        (childSize.height >= 100)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      child: textControl(
                          isExpanded ? '...show less' : '...show more', context,
                          color: colors.paddygreen),
                      onPressed: () => setState(() =>
                          isExpanded ? isExpanded = false : isExpanded = true)),
                ],
              )
            : SizedBox(),
        SizedBox(height: 10),
        multiImageViewer(Get.context!, widget.images),
      ],
    );
  }
}
