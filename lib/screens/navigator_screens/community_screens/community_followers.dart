import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/accounts_screens/profilePage.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class CommunityFollowers extends StatefulWidget {
  final String community;

  CommunityFollowers({required this.community});

  @override
  _CommunityFollowersState createState() => _CommunityFollowersState();
}

class _CommunityFollowersState extends State<CommunityFollowers> {
  TabController? tabController;
  Map<String, dynamic> followersData = {};
  List<dynamic> followersList = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 1;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getFollowersData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page++;
          getFollowersData(moreData: true);
        }
      });
    });
  }

  getFollowersData({moreData = false}) async {
    if (moreData == true) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
    followersData =
        await getCommunityFollowers(context, widget.community, page);
    followersList.addAll(followersData["data"]);
    setState(() {
      isLoading = false;
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context);
    return Scaffold(
        appBar: customAppBar(context, "Followers"),
        body: isLoading
            ? loaderMain(context, status: true, color: colors.paddygreen)
            : Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: colors.paddygreen))),
                      // height: 45,
                      width: getWidth(context),
                      child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: AutoSizeText(
                              "Followers - ${followersData["total"]}",
                              maxLines: 1,
                              style: TextStyle(
                                  color: colors.paddygreen,
                                  fontWeight: FontWeight.bold))),
                    ),
                    Expanded(
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: followersList.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data = followersList[index];
                              return InkWell(
                                onTap: () => pushNewScreen(context,
                                    screen: data["_id"] == userModel.id
                                        ? ProfilePage()
                                        : OtherProfilePage(content: data)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Container(
                                        width: getWidth(context),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    data["profilepic"] ?? ""),
                                                radius: 20),
                                            SizedBox(
                                                width: getSize(context, 10)),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                textControl(
                                                    data["firstname"] == null
                                                        ? "-"
                                                        : "${data["firstname"]} ${data["lastname"]}",
                                                    context,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                Row(children: [
                                                  textControl(
                                                      "Contributions", context,
                                                      size: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: colors.textBlue),
                                                  SizedBox(
                                                      width:
                                                          getSize(context, 5)),
                                                  textControl(
                                                      (data["contributions"] ??
                                                              0)
                                                          .toString(),
                                                      context,
                                                      size: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ])
                                              ],
                                            )),
                                            // CustomButton(text: "Follow", onPressed: () {}, width: 80, height: 30, textSize: 12, fontWeight: FontWeight.w100)
                                          ],
                                        ),
                                      ),
                                    ),
                                    divider(context)
                                  ],
                                ),
                              );
                            })),
                    isLoadingMore
                        ? loaderMain(context,
                            status: true,
                            size: getSize(context, 20),
                            height: 50)
                        : SizedBox()
                  ],
                ),
              ));
  }
}
