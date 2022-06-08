import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/empty_state.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/notification_widget.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/getXController.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = false;
  bool isMoreLoading = false;
  List<dynamic> notifications = [];
  int page = 1;
  final CounterController counterController = Get.put(CounterController());
  ScrollController scrollController = ScrollController();
  Map<String, dynamic>? newNotifs;
  bool isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ControlChangeNotifierModel controlModel =
          Provider.of<ControlChangeNotifierModel>(context, listen: false);
      getNotifs(context);
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          // debugPrint(newNotifs!["total"].toString());
          if (newNotifs!["total"] > notifications.length) {
            // debugPrint(page.toString());
            page = page + 1;
            getNotifs(context, moreData: true);
          }
        }
      });
      markAll();
      final CounterController counterController = Get.put(CounterController());
      counterController.setNotificationCountToZero();
      controlModel.addListener(() {
        if (controlModel.isLoadingNotifications == true) {
          setState(() {
            isLoadingNextPage = true;
          });
        } else {
          setState(() {
            isLoadingNextPage = false;
          });
        }
      });
    });
  }

  getNotifs(BuildContext context, {bool moreData = false}) async {
    if (moreData) {
      setState(() {
        isMoreLoading = true;
      });
    }
    newNotifs = await getNotifications(context, page);
    // debugPrint(newNotifs.toString());
    if (moreData == true) {
      notifications.addAll(newNotifs!["data"]);
    } else {
      notifications = newNotifs!["data"];
    }
    //  print(notifications);
    //  print(notifications.length);
    setState(() {
      isMoreLoading = false;
      isLoading = false;
    });
  }

  markAll() async {
    bool res = await markAllNotifications(context);
    if (res) getNotifs(context);
    counterController.setNotifCount(0.obs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Notifications"),
      body: isLoading
          ? Center(
              child: loaderMain(context, status: true),
            )
          : SafeArea(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getSize(context, 20)),
                // Mark as Read Implementation
                // Padding(
                //   padding: EdgeInsets.only(right: 20, bottom: 20),
                //   child:
                //       Row(mainAxisAlignment: MainAxisAlignment.end, children: [InkWell(onTap: () => markAll(), child: textControl("Mark all as read", context, color: colors.paddygreen, size: 15))]),
                // ),
                isLoadingNextPage
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator()),
                      )
                    : SizedBox(),
                Expanded(
                  child: notifications.length < 1
                      ? Center(child: EmptyState())
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                NotificationWidget(
                                    content: notifications[index]),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getSize(context, 20)),
                                  child: divider(context),
                                )
                              ],
                            );
                          },
                        ),
                ),
                isMoreLoading
                    ? loaderMain(context,
                        status: true, size: getSize(context, 20), height: 50)
                    : SizedBox()
              ],
            )),
    );
  }
}
