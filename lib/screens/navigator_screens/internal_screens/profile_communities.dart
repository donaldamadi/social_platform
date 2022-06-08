import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ProfileCommunities extends StatefulWidget {
  ProfileCommunities({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<ProfileCommunities> createState() => _ProfileCommunitiesState();
}

class _ProfileCommunitiesState extends State<ProfileCommunities> {
  TabController? tabController;
  Map<String, dynamic> followingData = {};
  List<dynamic> followingList = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 1;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCommunitiesData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          page++;
          getCommunitiesData(moreData: true);
        }
      });
    });
  }

  getCommunitiesData({moreData = false}) async {
    if (moreData == true) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
    followingData = await getFollowedCommunities(context, widget.userId);
    followingList.addAll(followingData["data"]);
    setState(() {
      isLoading = false;
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, "Following"),
        body: isLoading
            ? loaderMain(context, status: true, color: colors.paddygreen)
            : Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.paddygreen))),
                      // height: 45,
                      width: getWidth(context),
                      child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: AutoSizeText("Following - ${followingData["total"]}",
                              maxLines: 1, style: TextStyle(color: colors.paddygreen, fontWeight: FontWeight.bold))),
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: followingList.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data = followingList[index];
                              return InkWell(
                                // onTap: () => pushNewScreen(context, screen: OtherProfilePage(content: data)),
                                onTap: (){},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      child: Container(
                                        width: getWidth(context),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            textControl(data["_id"] ?? "", context, fontWeight: FontWeight.w400),
                                            Row(children: [
                                              textControl("Contributions", context, size: 12, fontWeight: FontWeight.w400, color: colors.textBlue),
                                              SizedBox(width: getSize(context, 5)),
                                              textControl((data["contributions"] ?? 0).toString(), context, size: 12, fontWeight: FontWeight.w400),
                                            ])
                                          ],
                                        ),
                                      ),
                                    ),
                                    divider(context)
                                  ],
                                ),
                              );
                            }))
                  ],
                ),
              ));
  }
}
