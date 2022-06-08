import 'dart:async';

import 'package:bubble/bubble.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:student_paddy_mobile/components/app_bar.dart';
import 'package:student_paddy_mobile/components/loader.dart';
import 'package:student_paddy_mobile/components/modal_bottom_sheet.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/network/requestHandler.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/other_profile_page.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({required this.content, this.name, this.id});

  final Map<String, dynamic> content;
  final String? id;
  final String? name;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> chats = [];
  final format = DateFormat('hh:mm a', 'en_US');
  bool isLoading = false;
  String? otherUserId;
  ScrollController scrollController = ScrollController();
  Map<String, dynamic>? sentData;
  // IO.Socket socket = IO.io(NetworkData.baseUrl.replaceAll("/v1/", ""), <String, dynamic>{
  //   'transports': ['websocket'],
  //   'autoConnect': false,
  // });

  int start = 2;
  TextEditingController textController = TextEditingController();
  Timer? timer;
  bool typing = false;
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    controlModel.setIsNotRead(true);
  }

  // final format = DateFormat('yyyy-MM-dd hh:mm');

  @override
  void initState() {
    super.initState();
    //  print(widget.content);
    //  print("Initializing chat screen");
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    //  print("Connecting to Socket");
    // controlModel.socket.connect();
    //  print('Trying to connect');
    //  print(controlModel.socket.connected);
    controlModel.socket.onConnect((data) => //  print("Connected"));
        controlModel.socket.on("connect", (data) => {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controlModel.setIsNotRead(false);
      controlModel.socket.on("receive-message", (data) {
        if (data["tag"] == "chat room") addChat(data);
        controlModel.setMessageBadge(false);
      });
      controlModel.socket.on("typing-res", (data) {
        if (data["tag"] == "chat room") showTyping();
      });
      scrollController.addListener(() {});
    });
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    if (widget.content["person"] == null) {
      for (var i in widget.content["participants"]) {
        if (i["_id"] != userModel.id) {
          otherUserId = i["_id"];
        }
      }
    } else {
      otherUserId = widget.content["person"]["_id"];
    }
    //  print("USER ID::: $otherUserId");
    controlModel.socket.emit("subscribe", {
      "room": widget.content["_id"] ?? widget.content["chatRoomId"],
      "otherUserId": otherUserId
    });
    getChats();
  }

  showTyping() {
    if (this.mounted) {
      setState(() {
        typing = true;
      });
      startTimer();
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer?.cancel();
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          setState(() {
            typing = false;
            timer.cancel();
          });
        } else {
          setState(() {
            start--;
          });
        }
      },
    );
  }

  addChat(var data) {
    //  print(data);
    chats.add({
      "readByRecipient": false,
      "body": data["message"],
      "sender": data["userId"],
      "chatId": widget.content["_id"] ?? widget.content["chatRoomId"],
      "receiver": data["userId"],
      "createdAt": DateTime.now().subtract(Duration(hours: 1)).toString(),
      "updatedAt": DateTime.now().subtract(Duration(hours: 1)).toString(),
      "__v": 0
    });
    // if (mounted) {
    //   setState(() {});
    // }
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent + 80,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
    FocusScope.of(context).requestFocus(focusNode);
  }

  sendChat(BuildContext context) async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    if (textController.text.isEmpty || textController.text == "") {
    } else if (textController.text.trim() == "") {
    } else {
      //  print(userModel.userData!);
      String text = textController.text.trim();
      textController.clear();
      chats.add({
        "readByRecipient": false,
        "body": text,
        "sender": userModel.id,
        "chatId": widget.content["_id"] ?? widget.content["chatRoomId"],
        "receiver": userModel.id,
        "createdAt": DateTime.now().subtract(Duration(hours: 1)).toString(),
        "updatedAt": DateTime.now().subtract(Duration(hours: 1)).toString(),
        "__v": 0
      });

      setState(() {});
      scrollToBottom(scrollController, scrollAddition: 80);
      sentData = await sendMessage(
          context,
          widget.content["_id"] ?? widget.content["chatRoomId"],
          {"body": text});
      controlModel.socket.emit("send-message", {
        "userId": userModel.id,
        "room": widget.content["_id"],
        "message": text,
        "otherUserId": otherUserId
      });
    }
  }

  getChats() async {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    //  print("userModel Id ${userModel.id}");
    //  print("userData ${userModel.userData}");
    setState(() {
      isLoading = true;
    });
    chats = await getChatMessages(
        context, widget.content["_id"] ?? widget.content["chatRoomId"]);
    chats = chats.reversed.toList();
    //  print(chats.length);
    setState(() {
      isLoading = false;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollToBottom(scrollController);
      }
    });
  }

  void main() {
    final dataSet = [
      {
        "time": "2020-06-16T10:31:12.000Z",
        "message": "Message1",
      },
      {
        "time": "2020-06-16T10:29:35.000Z",
        "message": "Message2",
      },
      {
        "time": "2020-06-15T09:41:18.000Z",
        "message": "Message3",
      },
    ];

    var groupByDate =
        groupBy(dataSet, (Map obj) => obj['time'].substring(0, 10));
    groupByDate.forEach((date, list) {
      // Header
      //  print('$date:');

      // Group
      list.forEach((listItem) {
        // List item
        //  print('${listItem["time"]}, ${listItem["message"]}');
      });
      // day section divider
      //  print("\n");
    });
  }

  Widget chatWidget(
      String image, String time, String message, String name, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => copyToClipboard(message),
          child: Bubble(
            margin: BubbleEdges.all(0),
            alignment: isMe ? Alignment.topRight : Alignment.topLeft,
            nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
            color: isMe ? colors.backgroundWhite : colors.paddygreen,
            borderColor: isMe ? colors.paddygreen : null,
            child: selectableTextControl(message, context,
                size: 15,
                fontWeight: FontWeight.w400,
                textAlign: isMe ? TextAlign.left : TextAlign.left,
                color: isMe ? colors.paddygreen : Colors.white),
          ),
        ),
        SizedBox(height: getSize(context, 4)),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            textControl(time, context, size: 11),
          ],
        ),
      ],
    );
  }

//Paginate messages by loading past messages

  loadPastMessages(BuildContext context) async {
    // UserOnBoardChangeNotifierModel userModel =
    //     Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    // //  print("userModel Id ${userModel.id}");
    // //  print("userData ${userModel.userData}");
    // setState(() {
    //   isLoading = true;
    // });
    // chats = await getChatMessages(
    //     context, widget.content["_id"] ?? widget.content["chatRoomId"]);
    // onRefresh: () async => loadPastMessages(context),
  }

  @override
  Widget build(BuildContext context) {
    UserOnBoardChangeNotifierModel userModel =
        Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    return Scaffold(
      // key: UniqueKey(),
      appBar: customAppBar(
        context,
        (widget.content["person"]["firstname"] ?? "") +
            " " +
            (widget.content["person"]["lastname"] ?? ""),
        actions: IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: () {
            quickActionModalBottomSheet3(context, id: otherUserId!);
          },
        ),
        subTitle: typing
            ? textControl("is Typing", context,
                fontStyle: FontStyle.italic, size: 12)
            : null,
      ),
      body: Stack(
        children: [
          isLoading
              ? loaderMain(context, status: true, color: colors.paddygreen)
              : SingleChildScrollView(
                  // key: UniqueKey(),
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: getSize(context, 15)),
                        GestureDetector(
                          onTap: () => pushNewScreen(context,
                              screen: OtherProfilePage(
                                  content: widget.content["person"])),
                          child: CircleAvatar(
                              radius: getSize(context, 25),
                              backgroundImage: NetworkImage(
                                  widget.content["person"]["profilepic"] ??
                                      "")),
                        ),
                        SizedBox(height: getSize(context, 10)),
                        textControl(
                            (widget.content["person"]["firstname"] ?? "") +
                                " " +
                                (widget.content["person"]["lastname"] ?? ""),
                            context,
                            fontWeight: FontWeight.w800),
                        SizedBox(height: getSize(context, 10)),
                        Container(
                          height: 20,
                          child: Row(
                            children: [
                              Image.asset("assets/pngs/grad_cap.png",
                                  color: colors.blueColorOne, height: 10),
                              SizedBox(width: getSize(context, 5)),
                              textControl(
                                  widget.content["person"]["institution"] ?? "",
                                  context,
                                  color: colors.textBlue,
                                  size: 11)
                            ],
                          ),
                        ),
                        Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: chatWidget(
                                        chats[index]["sender"] == userModel.id
                                            ? userModel.userData!["data"]
                                                ["profilepic"]
                                            : "${widget.content["person"]["profilepic"]}",
                                        format
                                            .format(DateTime.parse(
                                                    chats[index]["createdAt"])
                                                .add(Duration(hours: 1)))
                                            .toString(),
                                        chats[index]["body"],
                                        chats[index]["sender"] == userModel.id
                                            ? "${userModel.userData!["data"]["firstname"]} ${userModel.userData!["data"]["lastname"]}"
                                            : "${widget.content["person"]["firstname"]} ${widget.content["person"]["lastname"]}",
                                        chats[index]["sender"] == userModel.id
                                            ? true
                                            : false),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: getSize(context, 120))
                      ],
                    ),
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: getWidth(context),
              decoration: BoxDecoration(
                color: colors.backgroundWhite,
                border: Border(
                  top: BorderSide(
                      width: 0.5, color: Colors.black.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  /* IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {},
                    padding: EdgeInsets.symmetric(horizontal: getSize(context, 10)),
                    constraints: BoxConstraints(),
                  ), */
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20, top: 20, left: 15),
                      child: Container(
                        child: TextField(
                          focusNode: focusNode,
                          onChanged: (val) {
                            controlModel.socket.emit("typing-req", {
                              "room": widget.content["_id"] ??
                                  widget.content["chatRoomId"],
                              "userId": userModel.id,
                              "otherUserId": otherUserId
                            });
                          },
                          controller: textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              hintText: "Start typing...",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                borderSide: BorderSide(
                                    color: Color(0xFF6D6E71), width: 3.0),
                              )),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => sendChat(context),
                    padding:
                        EdgeInsets.symmetric(horizontal: getSize(context, 10)),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
