import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/custom_button.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/community_screens/single_community.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Map<String, dynamic>> communityList = [];
  bool loading = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    loadCommunityData(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> loadCommunityData(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (userModel.communities.isEmpty) {
      setState(() {
        isLoading = true;
      });
      await quickUserData(context);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      communityList = userModel.communities;
      //  print(communityList);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    return Container(
        color: colors.backgroundWhite,
        child: Column(
          children: [
            SizedBox(height: getSize(context, 20)),
            Center(
                child: textControl("Community", context,
                    size: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: getSize(context, 20)),
            Expanded(
              child: loading
                  ? Center(
                      child: loaderMain(context, status: true, size: 40),
                    )
                  : ListView.builder(
                      //physics: BouncingScrollPhysics(),
                      itemCount: communityList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                            height: getSize(context, 320),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pushNewScreen(context,
                                        screen: SingleCommunity(
                                            content: communityList[index]),
                                        withNavBar: false);
                                  },
                                  child: Container(
                                    height: getSize(context, 200),
                                    width: getWidth(context),
                                    child: CachedNetworkImage(
                                      imageUrl: communityList[index]
                                          ["communityPicture"],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          LinearProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    // decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImage(imageUrl: communityList[index]["communityPicture"]), fit: BoxFit.cover)),
                                  ),
                                ),
                                SizedBox(height: getSize(context, 15)),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          textControl(
                                              communityList[index]["name"],
                                              context,
                                              fontWeight: FontWeight.w900,
                                              size: 18,
                                              overflow: true),
                                          SizedBox(height: getSize(context, 5)),
                                          Row(children: [
                                            textControl(
                                                communityList[index]
                                                        ["followers"]
                                                    .length
                                                    .toString(),
                                                context,
                                                fontWeight: FontWeight.w800,
                                                size: 12),
                                            textControl(" Followers", context,
                                                fontWeight: FontWeight.w500,
                                                size: 12)
                                          ]),
                                          SizedBox(height: getSize(context, 5)),
                                          Row(children: [
                                            textControl("Topics ", context,
                                                fontWeight: FontWeight.w500,
                                                size: 12,
                                                color: colors.textBlue),
                                            textControl(
                                                communityList[index]["topics"]
                                                    .length
                                                    .toString(),
                                                context,
                                                fontWeight: FontWeight.w700,
                                                size: 12)
                                          ]),
                                        ],
                                      )),
                                      Column(children: [
                                        CustomButton(
                                          text: communityList[index]
                                                      ["followers"]
                                                  .contains(userModel.id)
                                              ? "Following"
                                              : "Follow",
                                          onPressed: () {
                                            setState(() {
                                              if (communityList[index]
                                                      ["followers"]
                                                  .contains(userModel.id)) {
                                                communityList[index]
                                                        ["followers"]
                                                    .remove(userModel.id);
                                                followUnfollowCommunity(
                                                    context,
                                                    communityList[index]
                                                        ["name"],
                                                    {"action": "unfollow"});
                                                userModel
                                                    .setUpdatedResult(true);
                                              } else {
                                                communityList[index]
                                                        ["followers"]
                                                    .add(userModel.id);
                                                followUnfollowCommunity(
                                                    context,
                                                    communityList[index]
                                                        ["name"],
                                                    {"action": "follow"});
                                                userModel
                                                    .setUpdatedResult(true);
                                              }
                                            });
                                          },
                                          width: 88,
                                          height: 30,
                                          textSize: 12,
                                          buttonType: communityList[index]
                                                      ["followers"]
                                                  .contains(userModel.id)
                                              ? ButtonType.one
                                              : ButtonType.two,
                                        ),
                                        SizedBox(height: getSize(context, 20)),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  pushNewScreen(context,
                                                      screen: SingleCommunity(
                                                          content:
                                                              communityList[
                                                                  index]),
                                                      withNavBar: false);
                                                },
                                                child: textControl(
                                                    "Enter Community ", context,
                                                    color: colors.paddygreen,
                                                    size: 12),
                                              ),
                                              Icon(Icons.chevron_right,
                                                  size: 15,
                                                  color: colors.paddygreen),
                                            ])
                                      ])
                                    ],
                                  ),
                                ),
                                divider(context)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
