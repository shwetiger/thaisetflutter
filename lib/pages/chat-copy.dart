// @dart=2.9

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/data/database_helper.dart';
import 'package:thai2dlive/models/chat_msg.dart';
import 'package:thai2dlive/models/chat_user.dart';
import 'package:thai2dlive/models/two_d_live_result.dart';
import 'package:thai2dlive/pages/profile_edit.dart';
import 'package:thai2dlive/pages/twod_page.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/pages/user_photo.dart';
import 'package:thai2dlive/providers/login_provider.dart';
import 'package:thai2dlive/providers/twod_provider.dart';

import 'group-list.dart';
import 'user_ph_login.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatUser user = ChatUser();

  QuerySnapshot<Object> initialDatas;
  bool isLoading = true;
  FirebaseFirestore db = FirebaseFirestore.instance;
  int msgCount = 30;
  int scrollExtent = 10000;
  bool showPage = false;

  @override
  void initState() {
    super.initState();
    checkHoliday();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    if (super.mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TwoDPage()),
            (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Live Chat"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const TwoDPage()),
                  (Route<dynamic> route) => false);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            FirebaseAuth.instance.currentUser != null
                ? PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ProfileEditScreen(),
                          ),
                        );
                      } else {
                        await context.read<LoginProvider>().logOut(context);

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const TwoDPage()),
                            (Route<dynamic> route) => false);
                      }
                    },
                    itemBuilder: (context) => [
                          const PopupMenuItem(
                            child: Text("Edit Profile"),
                            value: 1,
                          ),
                          const PopupMenuItem(
                            child: Text("Log out"),
                            value: 2,
                          )
                        ],
                    child: FutureBuilder<DocumentSnapshot>(
                      future: db
                          .collection(chatUserCollection)
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        user = ChatUser.fromJson(snapshot.data.data());
                        return Row(
                          children: [
                            UserPhoto(
                              height: 30,
                              width: 30,
                              imageurl: user.imageUrl,
                              name: user.name,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        );
                      },
                    ))
                : const Text(" "),
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildLiveCard(),
            Expanded(
              child: PaginateFirestore(
                scrollDirection: Axis.vertical,
                options: const GetOptions(source: Source.serverAndCache),
                scrollController: _scrollController,
                bottomLoader: const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18.0),
                  child: Text("Load More Messages.."),
                )),
                reverse: true,
                query: db
                    .collection(chatMessageCollection)
                    .orderBy("createdAt", descending: true),
                itemsPerPage: 15,
                isLive: true,
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, documentSnapshots, index) {
                  if (documentSnapshots.isEmpty) {
                    return const Center(
                      child: Text("No Messages"),
                    );
                  }
                  ChatMessage chatMessage =
                      ChatMessage.fromJson(documentSnapshots[index].data());

                  String uid = FirebaseAuth.instance.currentUser?.uid;
                  bool isCurrentUser = chatMessage.authorId == uid;

                  if (!isCurrentUser) {
                    return Container(
                      // padding: const EdgeInsets.only(
                      //     left: 8, top: 8, right: 8, bottom: 8),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: width,
                                  ),
                                  Text(
                                    chatMessage.authorName ?? " ",
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  UserPhoto(
                                    height: height,
                                    width: width,
                                    imageurl: chatMessage.authorPhoto,
                                    name: chatMessage.authorName,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Image.asset(
                                    "assets/left.png",
                                    width: 15.0,
                                    height: 15.0,
                                    fit: BoxFit.fill,
                                  ),
                                  //FaIcon(FontAwesomeIcons.caretLeft,size: 30,),
                                  Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 0.0, maxWidth: 260),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0XFFdcdbdb),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Color(0XFFdcdbdb).withOpacity(0.4),
                                      //     blurRadius: 4,
                                      //     offset: Offset(4, 6), // Shadow position
                                      //   ),
                                      // ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            children: [
                                              Text(
                                                chatMessage.content ?? " ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(
                                                        color: Colors.black),
                                              ),
                                              chatMessage.content.length > 32
                                                  ? Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Text(
                                                          getTimeFormat(
                                                              chatMessage
                                                                  .createdAt
                                                                  ?.toDate()),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.6))),
                                                    )
                                                  : showMessageDate(
                                                      chatMessage.content,
                                                      chatMessage.createdAt
                                                          ?.toDate()),
                                              // Text(getTimeFormatDate(chatMessage.createdAt.toDate().toString())+" "+getTimeFormat(chatMessage.createdAt.toDate()),
                                              //   style: TextStyle(color: Colors.black.withOpacity(0.6))
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: index == 0 ||
                                    checkDate(
                                            chatMessage.createdAt?.toDate(),
                                            ChatMessage.fromJson(
                                                    documentSnapshots[index - 1]
                                                        .data())
                                                .createdAt
                                                ?.toDate()) ==
                                        ''
                                ? EdgeInsets.only(top: 0)
                                : EdgeInsets.only(
                                    top: 10), //const EdgeInsets.only(top: 10),
                            child: Text(index == 0
                                ? ''
                                : checkDate(
                                    chatMessage.createdAt?.toDate(),
                                    ChatMessage.fromJson(
                                            documentSnapshots[index - 1].data())
                                        .createdAt
                                        ?.toDate())),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      // padding: const EdgeInsets.only(
                      //     left: 8, top: 8, right: 8, bottom: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        chatMessage.authorName ?? " ",
                                        style: const TextStyle(
                                          // fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        constraints: const BoxConstraints(
                                            minWidth: 0.0, maxWidth: 250),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: mainColor.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    chatMessage.content ?? " ",
                                                    // softWrap: false,
                                                    // textAlign: TextAlign.center,
                                                    maxLines: 4,
                                                    // textDirecti,
                                                    // overflow:
                                                    //     TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  chatMessage.content.length >
                                                          32
                                                      ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Text(
                                                            getTimeFormat(
                                                                chatMessage
                                                                    .createdAt
                                                                    ?.toDate()),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.6)),
                                                          ),
                                                        )
                                                      : showMessageDate1(
                                                          index,
                                                          chatMessage.content,
                                                          chatMessage.createdAt
                                                              ?.toDate()),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/right.png",
                                        width: 20.0,
                                        height: 20.0,
                                        fit: BoxFit.fill,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      UserPhoto(
                                        height: height,
                                        width: width,
                                        imageurl: chatMessage.authorPhoto,
                                        name: chatMessage.authorName,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: index == 0 ||
                                    checkDate(
                                            chatMessage.createdAt?.toDate(),
                                            ChatMessage.fromJson(
                                                    documentSnapshots[index - 1]
                                                        .data())
                                                .createdAt
                                                ?.toDate()) ==
                                        ''
                                ? EdgeInsets.only(top: 0)
                                : EdgeInsets.only(
                                    top: 10), //const EdgeInsets.only(top: 20),
                            child: Text(index == 0
                                ? ''
                                : checkDate(
                                    chatMessage.createdAt?.toDate(),
                                    ChatMessage.fromJson(
                                            documentSnapshots[index - 1].data())
                                        .createdAt
                                        ?.toDate())),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 2, bottom: 16, left: 8, right: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300],
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
              ),
              child: TextField(
                controller: msgController,
                maxLength: 64,
                onSubmitted: (value) async {
                  if (FirebaseAuth.instance.currentUser?.uid != null) {
                    String msg = msgController.text.trim();
                    if (msg != "") {
                      ChatMessage chatMessage = ChatMessage(
                        authorId: user.id,
                        authorName: user.name,
                        authorPhoto: user.imageUrl,
                        content: msg,
                        createdAt: Timestamp.fromDate(DateTime.now()),
                      );
                      await context
                          .read<LoginProvider>()
                          .sendMessage(context, chatMessage);
                      msgController.clear();
                      // WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
                    } else {}
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const UserPhLoginScreen(),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.keyboard_alt_outlined,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      if (FirebaseAuth.instance.currentUser?.uid != null) {
                        String msg = msgController.text.trim();
                        if (msg != "") {
                          ChatMessage chatMessage = ChatMessage(
                            authorId: user.id,
                            authorName: user.name,
                            authorPhoto: user.imageUrl,
                            content: msg,
                            createdAt: Timestamp.fromDate(DateTime.now()),
                          );
                          // _scrollToBottom();
                          await context
                              .read<LoginProvider>()
                              .sendMessage(context, chatMessage);
                          msgController.clear();
                          // WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
                        } else {}
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const UserPhLoginScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: mainColor,
                    ),
                  ),
                  labelText: 'Type Your Message',
                  labelStyle: TextStyle(color: mainColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkHoliday() async {
    await context.read<TwoDProvider>().checkTdyHoliday(context);
  }

  AnimationController _controller;
  Animation _animation;
  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('TwoDLiveResult'))
        ..whereEqualTo('objectId', 'xNiYjJixOZ');

  TextStyle labelStyle = GoogleFonts.roboto(
    fontSize: 12,
    color: Colors.grey,
  );
  TextStyle valueStyle = GoogleFonts.roboto(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: mainColor);
  TextStyle resultValueStyle = GoogleFonts.roboto(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow[700]);

  Widget _buildLiveCard() {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 2),
      child: ParseLiveListWidget<ParseObject>(
          query: query,
          lazyLoading: true,
          preloadedColumns: const ["test1", "sender.username"],
          childBuilder: (BuildContext context,
              ParseLiveListElementSnapshot<ParseObject> snapshot) {
            if (snapshot.failed) {
              return const Center(
                child: Text('something went wrong!'),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.loadedData.get<String>("data");
              List<TwoDLiveResult> list = [];
              TwoDLiveResult item = TwoDLiveResult();
              if (data != null && data != "") {
                var obj = json.decode(data);

                list = [];
                for (var item in obj) {
                  list.add(TwoDLiveResult.fromJson(item));
                }

                String index = "";
                DateTime now = DateTime.now();
                for (int i = 0; i < list.length; i++) {
                  DateTime from = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(list[i].fromDateTime);
                  DateTime to = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(list[i].toDateTime);

                  if ((from.isBefore(now) && to.isAfter(now)) ||
                      (from.isAtSameMomentAs(now)) ||
                      (to.isAtSameMomentAs(now))) {
                    index = i.toString();
                    break;
                  }
                }

                if (index == "") {
                  List<TwoDLiveResult> doneList =
                      list.where((element) => element.isDone).toList();
                  if (doneList.isNotEmpty) {
                    item = doneList.last;
                  } else {
                    item = list.first;
                  }
                } else {
                  item = list[int.parse(index)];
                }
              }

              return Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "Live",
                                style: labelStyle,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              !item.isDone
                                  ? FadeTransition(
                                      opacity: _animation,
                                      child: Text(
                                        snapshot.loadedData
                                                .get<String>("result") ??
                                            "--",
                                        style: resultValueStyle,
                                      ),
                                    )
                                  : Text(
                                      snapshot.loadedData
                                              .get<String>("result") ??
                                          "--",
                                      style: resultValueStyle,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "Set",
                                style: labelStyle,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              item.set != "--" &&
                                      item.set != null &&
                                      item.set != ""
                                  ? !item.isDone
                                      ? FadeTransition(
                                          opacity: _animation,
                                          child: RichText(
                                            text: TextSpan(
                                              text: item.set.substring(
                                                  0, item.set.length - 1),
                                              style: valueStyle,
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: item.set.substring(
                                                      item.set.length - 1,
                                                      item.set.length),
                                                  style: resultValueStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            text: item.set.substring(
                                                0, item.set.length - 1),
                                            style: valueStyle,
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: item.set.substring(
                                                    item.set.length - 1,
                                                    item.set.length),
                                                style: resultValueStyle,
                                              ),
                                            ],
                                          ),
                                        )
                                  : Text(
                                      item.set ?? " ",
                                      style: valueStyle,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "Value",
                                style: labelStyle,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              item.value != "--" &&
                                      item.value != null &&
                                      item.value != ""
                                  ? !item.isDone
                                      ? FadeTransition(
                                          opacity: _animation,
                                          child: RichText(
                                            text: TextSpan(
                                              text: item.value.substring(
                                                  0, item.value.length - 4),
                                              style: valueStyle,
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: item.value.substring(
                                                        item.value.length - 4,
                                                        item.value.length - 3),
                                                    style: resultValueStyle),
                                                TextSpan(
                                                  text: item.value.substring(
                                                      item.value.length - 3,
                                                      item.value.length),
                                                  style: valueStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            text: item.value.substring(
                                                0, item.value.length - 4),
                                            style: valueStyle,
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: item.value.substring(
                                                    item.value.length - 4,
                                                    item.value.length - 3),
                                                style: resultValueStyle,
                                              ),
                                              TextSpan(
                                                  text: item.value.substring(
                                                      item.value.length - 3,
                                                      item.value.length),
                                                  style: valueStyle),
                                            ],
                                          ),
                                        )
                                  : Text(
                                      item.value ?? " ",
                                      style: valueStyle,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "2D",
                                style: labelStyle,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              item.isDone
                                  ? Text(
                                      item.result ?? " ",
                                      style: resultValueStyle,
                                    )
                                  : Text(
                                      "--",
                                      style: valueStyle,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "Loading SET 2D Live Data...",
                ),
              );
            }
          }),
    );
  }

  getTimeFormat(date) {
    var newDate;
    newDate = date == null ? DateTime.now() : date;
    var myDate = DateTime.parse(newDate.toString());
    //DateTime myDate = new DateFormat("dd-MMM-yyyy hh:mm a").parse(date);
    var day1 = DateFormat('hh:mm:ss a').format(myDate);
    return day1;
  }

  getTimeFormatDate(date) {
    var newDate;
    newDate = date == null ? DateTime.now() : date;
    var myDate = DateTime.parse(newDate.toString());
    //DateTime myDate = new DateFormat("dd-MMM-yyyy hh:mm a").parse(date);
    var day1 = DateFormat('dd.MM.yyyy').format(myDate);

    return day1;
  }

  checkDate(date, oldDate) {
    if (oldDate == null) {
      oldDate = date.toString();
    }
    var myDate1 = DateTime.parse(date.toString());
    var myDate2 = DateTime.parse(oldDate.toString());

    var now = new DateTime.now();
    var currentDate = DateFormat('dd.MM.yyyy').format(now);
    //print(currentDate);
    //DateTime myDate = new DateFormat("dd-MMM-yyyy hh:mm a").parse(date);
    var day1 = DateFormat('dd.MM.yyyy').format(myDate1);
    var day2 = DateFormat('dd.MM.yyyy').format(myDate2);
    if (day2 != day1) {
      if (currentDate == day2) {
        return 'Today';
      } else {
        return day2;
      }
    } else {
      return '';
    }
  }

  showMessageDate(chatMess, date) {
    var newDate;
    newDate = date == null ? DateTime.now() : date;

    if (chatMess.length <= 8) {
      return Text(getTimeFormat(newDate),
          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12));
    }
    if (chatMess.length > 8 && chatMess.length < 13) {
      var checkDate = getTimeFormat(newDate);
      return Text(checkDate.padLeft(chatMess.length, " "),
          style: TextStyle(color: Colors.black.withOpacity(0.6)));
    }
    if (chatMess.length > 13 && chatMess.length < 20) {
      var checkDate = getTimeFormat(newDate);
      return Text(checkDate.padLeft(chatMess.length + 5, " "),
          style: TextStyle(color: Colors.black.withOpacity(0.6)));
    } else {
      var checkDate = getTimeFormat(newDate);
      return Text(checkDate.padLeft(chatMess.length + 10, " "),
          style: TextStyle(color: Colors.black.withOpacity(0.6)));
    }
  }

  showMessageDate1(index, chatMess, date) {
    var newDate;
    newDate = date == null ? DateTime.now() : date;
    if (chatMess.length <= 8) {
      return Text(
        getTimeFormat(newDate),
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      );
    }
    if (chatMess.length > 8 && chatMess.length < 13) {
      var checkDate = getTimeFormat(newDate);

      return Text(checkDate.padLeft(chatMess.length, " "),
          style: TextStyle(color: Colors.white.withOpacity(0.6)));
    }
    if (chatMess.length > 13 && chatMess.length < 20) {
      var checkDate = getTimeFormat(newDate);
      return Text(checkDate.padLeft(chatMess.length + 5, " "),
          style: TextStyle(color: Colors.white.withOpacity(0.6)));
    } else {
      var checkDate = getTimeFormat(newDate);
      return Text(checkDate.padLeft(chatMess.length + 10, " "),
          style: TextStyle(color: Colors.white.withOpacity(0.6)));
    }
  }
}
