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

class ContributorsPage extends StatefulWidget {
  final String name;

  ContributorsPage({required this.name});

  @override
  _ContributorsPageState createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> {
  bool isLoading = true;
  bool isMoreLoading = true;
  Map<String, dynamic> contributorsData = {};
  List<dynamic> contributors = [];
  int page = 1;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getContributors(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (contributorsData["data"]["total"] > contributors.length) {
            page++;
            getContributors(context, moreData: true);
          }
        }
      });
    });
  }

  getContributors(BuildContext context, {bool moreData = false}) async {
    if (moreData == false) {
      setState(() {
        isLoading = true;
      });
    }
    if (moreData == true) {
      setState(() {
        isMoreLoading = true;
      });
    }
    contributorsData =
        await getCommunity(context, widget.name, "contributors", page);
    contributors.addAll(contributorsData["data"]["contributors"]);
    setState(() {
      isMoreLoading = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context);
    return Scaffold(
      appBar: customAppBar(context, "Contributors"),
      body: isLoading
          ? loaderMain(context, status: true, color: colors.paddygreen)
          : ListView.builder(
              controller: scrollController,
              //physics: BouncingScrollPhysics(),
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = contributors[index];
                return InkWell(
                  onTap: () => pushNewScreen(context,
                      screen: data["user"]["_id"] == userModel.id
                          ? ProfilePage()
                          : OtherProfilePage(content: data["user"])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Container(
                          width: getWidth(context),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(data["user"]["profilepic"]),
                                  radius: 20),
                              SizedBox(width: getSize(context, 10)),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textControl(
                                      data["user"]["firstname"] == null
                                          ? "-"
                                          : "${data["user"]["firstname"]} ${data["user"]["lastname"]}",
                                      context,
                                      fontWeight: FontWeight.w400),
                                  Row(children: [
                                    textControl("Contributions", context,
                                        size: 12,
                                        fontWeight: FontWeight.w400,
                                        color: colors.textBlue),
                                    SizedBox(width: getSize(context, 5)),
                                    textControl(
                                        (data["posts"] +
                                                data["questions"] +
                                                data["resources"] +
                                                data["answers"])
                                            .toString(),
                                        context,
                                        size: 12,
                                        fontWeight: FontWeight.w400),
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
              }),
    );
  }
}
