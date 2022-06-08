import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/custom_text_field.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/chat_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/messages_screens/new_message_screen.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> fullMessagesList = [];
  bool isLoading = false;
  var lastMessage;
  Map<String, dynamic> messagesData = {};
  List<dynamic> messagesList = [];
  int start = 2;
  Timer? timer;
  var toAdd;
  var toRemove;
  List<dynamic> users = [];
  // IO.Socket socket = IO.io(NetworkData.baseUrl.replaceAll("/v1/", ""), <String, dynamic>{
  //   'transports': ['websocket'],
  //   'autoConnect': false,
  // });

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    //  print("Initializing messages screen");
    populateMessages();
    initSocket();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ControlChangeNotifierModel controlModel =
          Provider.of<ControlChangeNotifierModel>(context, listen: false);
      controlModel.addListener(() {
        if (controlModel.getMessages == true) {
          populateMessages();
          controlModel.setGetMessages(false);
        }
      });
    });
  }

  void initSocket() {
    //  print("Connecting to Socket");
    // IO.Socket socket = IO.io(NetworkData.baseUrl.replaceAll("/v1/", ""), <String, dynamic>{
    //   'transports': ['websocket'],
    //   'autoConnect': false,
    // });
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    // controlModel.socket.connect();
    //  print('Trying to connect');
    //  print(controlModel.socket.connected);
    controlModel.socket.onConnect((data) => //  print("Connected"));
        controlModel.socket.on("connect", (data) => {}));
    // socket.on("receive-message", (data) => updateMessageList(data));
    controlModel.socket.on("initiateChat", (data) {
      //  print("Initiating Chat");
      //  print(data);
      populateMessages(update: true);
    });
    controlModel.socket.on("typing-res", (data) {
      if (data["tag"] == "all rooms") updateTyping(data);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controlModel.setIsNotRead(true);
      controlModel.socket.on("receive-message", (data) {
        //  print(data);
        populateMessages(update: true);
        // updateMessageList(data);
        // setState(() {});
      });
    });
  }

  updateTyping(dynamic data) {
    messagesList.forEach((e) {
      if (e["person"]["_id"] == data["userId"]) {
        if (lastMessage == null) {
          lastMessage = e["lastMessage"];
        }
        e["lastMessage"] = "typing...";
        if (mounted) {
          setState(() {
            const oneSec = const Duration(seconds: 1);
            timer?.cancel();
            timer = Timer.periodic(
              oneSec,
              (Timer timer) {
                if (start == 0) {
                  setState(() {
                    e["lastMessage"] = lastMessage;
                    timer.cancel();
                  });
                } else {
                  setState(() {
                    start--;
                  });
                }
              },
            );
          });
        }
      }
    });
  }

  searchMessages(value) {
    if (value.length > 0) {
      List<dynamic> searchData = [];
      for (var i in fullMessagesList) {
        if (i["person"]["firstname"]
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            i["person"]["lastname"]
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            i["person"]["username"]
                .toLowerCase()
                .contains(value.toLowerCase())) {
          searchData.add(i);
        }
      }
      messagesList = searchData;
      setState(() {});
    } else {
      setState(() {
        messagesList = fullMessagesList;
      });
    }
  }

  updateMessageList(dynamic data) {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    messagesList.forEach((e) {
      if (e["person"]["_id"] == data["userId"]) {
        toRemove = e;
        e["lastMessage"] = data["message"];
        lastMessage = data["message"];
        e["updatedAt"] = DateTime.now().toString();
        toAdd = e;
        // messagesList.remove(e);
        if (mounted) e["unreadMessages"] = true;
      }
    });
    messagesList.insert(0, toAdd);
    messagesList.removeAt(messagesList.indexOf(toRemove));
    // if (this.mounted) {
    setState(() {});
    // }
    controlModel.setMessageBadge(false);
  }

  populateMessages({bool update = false}) async {
    if (update == false) {
      setState(() {
        isLoading = true;
      });
    }
    // setState(() {
    //   isLoading = true;
    // });
    messagesData = await getMessages(context);
    messagesList = messagesData["data"];
    fullMessagesList = messagesList;
    //  print(messagesData);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return Scaffold(
      appBar: customAppBar(context, "Messaging"),
      body: isLoading
          ? loaderMain(context, status: true)
          : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, right: 20),
                        child: CustomTextField(
                          borderColor: colors.blueColorOne,
                          hintText: "Search conversations...",
                          header: "",
                          icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SvgPicture.asset(
                                "assets/svgs/search_icon.svg",
                                height: 10),
                          ),
                          onChanged: (value) {
                            searchMessages(value);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 25,
                      onPressed: () => pushNewScreen(context,
                              screen: NewMessage(), withNavBar: false)
                          .then((value) => populateMessages(update: true)),
                      icon: Icon(Icons.add_circle_outline_rounded),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(width: getSize(context, 20)),
                  ],
                ),
                SizedBox(height: getSize(context, 10)),
                Expanded(
                    child: ListView.builder(
                  //physics: BouncingScrollPhysics(),
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    if (messagesList[index]["person"] == null) {
                      return SizedBox();
                    } else {
                      return Container(
                        color: messagesList[index]["unreadMessages"] == true
                            ? colors.paddygreen.withOpacity(0.15)
                            : Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  messagesList[index]["unreadMessages"] = false;
                                });
                                pushNewScreen(context,
                                        screen: ChatScreen(
                                            content: messagesList[index],
                                            name:
                                                "${messagesList[index]["person"]["firstname"]} ${messagesList[index]["person"]["lastname"]}"),
                                        withNavBar: false)
                                    .then((value) {
                                  populateMessages(update: true);
                                  controlModel.socket.onConnect(
                                      (data) => //  print("Connected"));
                                          controlModel.socket
                                              .on("connect", (data) => {}));
                                });
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              overlayColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 20),
                                child: Container(
                                  height: getSize(context, 55),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                          radius: getSize(context, 20),
                                          backgroundImage: NetworkImage(
                                              "${messagesList[index]["person"]["profilepic"]}")),
                                      SizedBox(width: getSize(context, 10)),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: textControl(
                                                      "${messagesList[index]["person"]["firstname"]} ${messagesList[index]["person"]["lastname"]}",
                                                      context,
                                                      size: 14,
                                                      overflow: true),
                                                ),
                                                SizedBox(
                                                    width:
                                                        getSize(context, 10)),
                                                Flexible(
                                                  child: textControl(
                                                      "@" +
                                                          messagesList[index]
                                                                  ["person"]
                                                              ["username"],
                                                      context,
                                                      size: 12),
                                                )
                                              ],
                                            ),
                                            Container(
                                                height: 19,
                                                child: textControl(
                                                    "${messagesList[index]["lastMessage"] ?? "No messages yet..."}",
                                                    context,
                                                    size: 12,
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    overflow: true))
                                          ])),
                                      SizedBox(width: getSize(context, 10)),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          textControl(
                                              "${timeago.format(DateTime.parse(messagesList[index]["updatedAt"]))}",
                                              context,
                                              size: 8,
                                              color: Colors.black.withOpacity(
                                                  0.5)), /* textControl("Online", context, color: colors.paddygreen, size: 10) */
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: divider(context),
                            )
                          ],
                        ),
                      );
                    }
                  },
                ))
              ],
            ),
    );
  }
}
