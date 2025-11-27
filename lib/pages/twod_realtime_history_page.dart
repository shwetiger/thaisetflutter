// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/api/twod_threed_api.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/holiday_model.dart';
import 'package:thai2dlive/models/two_d_live_result.dart';
import 'package:thai2dlive/pages/twod_help_page.dart';
import 'package:thai2dlive/providers/twod_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../models/live_2d_log.dart';
import 'download_page.dart';
import 'dart:math' as math;

class TwoDRealTimeHistoryPage extends StatefulWidget {
  const TwoDRealTimeHistoryPage({Key key}) : super(key: key);
  @override
  _TwoDRealTimeHistoryPageState createState() =>
      _TwoDRealTimeHistoryPageState();
}

class _TwoDRealTimeHistoryPageState extends State<TwoDRealTimeHistoryPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  AnimationController _controller;
  Animation _animation;

  final LiveQuery liveQuery = LiveQuery();

  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('TwoDLiveResult'))
        ..whereEqualTo('objectId', 'xNiYjJixOZ'); //edit pro
  // QueryBuilder<ParseObject>(ParseObject('TwoDLiveResultTest'))
  //   ..whereEqualTo('objectId', '0bOQbAAGDm');//edit test

  QueryBuilder<ParseObject> liveResultQuery =
      QueryBuilder<ParseObject>(ParseObject('TwoDLiveResult'));

  QueryBuilder<ParseObject> queryLive2dlog =
      QueryBuilder<ParseObject>(ParseObject('Live2dLog'));

  QueryBuilder<ParseObject> queryRealTimeLog =
      QueryBuilder<ParseObject>(ParseObject('RealTimeLog'));

  bool isMounted = false;
  bool _loading = true;
  FirebaseMessaging _messaging;
  String link = "";
  String appUpdateUrl = "";
  String appName = "";
  String updateversion = "";
  int size = 0;

  String dropdownvalue = 'Real Time';
  var items = ['Real Time', '10:30 AM', '12:01 PM', '02:30 PM', '04:30 PM'];
  bool isRealTime = true;
  bool isNotRealTime = false;
  DateTime updatedTime = DateTime.now();
  List<Live2DLog> live2dlogList = [];
  List<Live2DLog> live2dNotRealTimelogList = [];
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    checkHoliday();
    //checkCorrectTime();
    if (!kIsWeb) {
      subscriptToPublicChannel();
    }
    getRealTimeData();
  }

  getRealTimeData() async {
    var newdate = await checkRealTime();
    // bool newHoliday=context.watch<TwoDProvider>().isHoliday;
    // print(newHoliday);
    if (newdate == "Saturday" || newdate == "Sunday") {
      RunTimeAuto();
    } else {
      Timer.periodic(Duration(seconds: 3), (Timer t) => RunTimeAuto());
    }
  }

  RunTimeAuto() {
    queryRealTimeLog = QueryBuilder<ParseObject>(ParseObject('RealTimeLog'));
    fetchRealTimeData();
  }

  Future<void> fetchRealTimeData() async {
    var response;
    response = await queryRealTimeLog.query();
    if (response.success) {
      live2dlogList = [];
      if (response.results == null) {
        live2dlogList = null;
        _loading = false;
        setState(() {});
        return;
      } else {
        for (var item in response.results) {
          if (dropdownvalue == 'Real Time') {
            if (checkGetDate(updatedTime) != checkGetDate(item['date'])) {
              live2dlogList = null;
              _loading = false;
              setState(() {});
              return;
            } else {
              Live2DLog model = Live2DLog(
                date: item['date'],
                result: item['result'],
                section: 'Real Time',
                set: item['set'],
                value: item['value'],
                isReference: false,
              );
              live2dlogList.add(model);
              _loading = false;
              setState(() {});
            }
          }
        }
        live2dlogList.sort((a, b) => b.date.compareTo(a.date));
        //print(live2dlogList);
        setState(() {});
      }
    } else {
      live2dlogList = null;
      _loading = false;
      setState(() {});
      return;
    }
  }

  Future<void> fetchNotRealTimeData(dropdownvalue) async {
    var liveResult;
    var response;
    liveResult = await liveResultQuery.query();
    if (liveResult.success) {
      for (var result in liveResult.results) {
        print(result['data']);
        List<dynamic> list = jsonDecode(result['data']);
        for (var i = 0; i < list.length; i++) {
          if ((dropdownvalue == list[i]['section']) &&
              (list[i]['isShowHistory'] && list[i]['isShowHistory'] != null)) {
            response = await queryLive2dlog.query();
            if (response.success) {
              live2dNotRealTimelogList = [];
              if (response.results == null) {
                live2dNotRealTimelogList = null;
                _loading = false;
                setState(() {});
                return;
              }
              for (var item in response.results) {
                if (checkGetDate(updatedTime) != checkGetDate(item['date'])) {
                  live2dNotRealTimelogList = null;
                  _loading = false;
                  setState(() {});
                  return;
                } else {
                  Live2DLog model = Live2DLog(
                    date: item['date'],
                    result: item['result'],
                    section: item['section'],
                    set: item['set'],
                    value: item['value'],
                    isReference: item['isReference'],
                  );
                  live2dNotRealTimelogList.add(model);
                  _loading = false;
                  setState(() {});
                }
              }
              live2dNotRealTimelogList.sort((a, b) => b.date.compareTo(a.date));
              //print(live2dlogList);
              setState(() {});
            } else {
              live2dNotRealTimelogList = null;
              _loading = false;
              setState(() {});
            }
          }
          if ((dropdownvalue == list[i]['section']) &&
              (!list[i]['isShowHistory'] || list[i]['isShowHistory'] == null)) {
            live2dNotRealTimelogList = null;
            _loading = false;
            setState(() {});
          }
        }
      }
    }

    // response = await queryLive2dlog.query();
    // if (response.success) {
    //   live2dNotRealTimelogList = [];
    //   if(response.results == null){
    //     live2dNotRealTimelogList=null;
    //     _loading=false;
    //     setState(() {});
    //     return;
    //   }
    //   for (var item in response.results) {
    //       if(checkGetDate(updatedTime) != checkGetDate(item['date']) ){
    //         live2dNotRealTimelogList=null;
    //         _loading=false;
    //         setState(() { });
    //         return;
    //       }
    //       else {
    //         Live2DLog model = Live2DLog(
    //           date: item['date'],
    //           result: item['result'],
    //           section: item['section'],
    //           set: item['set'],
    //           value: item['value'],
    //           isReference: item['isReference'],
    //         );
    //         live2dNotRealTimelogList.add(model);
    //         _loading=false;
    //         setState(() { });
    //       }
    //
    //   }
    //   live2dNotRealTimelogList.sort((a, b) => b.date.compareTo(a.date));
    //
    //   //print(live2dlogList);
    //   setState(() {});
    // } else {
    //   live2dNotRealTimelogList=null;
    //   _loading=false;
    //   setState(() {});
    // }
  }

  Future<void> subscriptToPublicChannel() async {
    _messaging = FirebaseMessaging.instance;
    //Testing
    await _messaging.subscribeToTopic("Testing");

    var subscriptionRef =
        FirebaseFirestore.instance.collection(subscriptionCollection);
    try {
      await subscriptionRef.get().then((value) {
        value.docs.forEach((result) async {
          await _messaging.subscribeToTopic(result.data()['channel_id']);
        });
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  checkHoliday() async {
    await context.read<TwoDProvider>().checkTdyHoliday(context);
  }

  bool showWarning = false;
  Future<void> checkCorrectTime() async {
    TwoDThreeDApi api = TwoDThreeDApi(context);
    DateTime d = await api.getDateTime(context);
    DateTime n = DateTime.now();
    DateTime onlineDate = DateTime(d.year, d.month, d.day, d.hour, d.minute);
    DateTime sysDate = DateTime(n.year, n.month, n.day, n.hour, n.minute);
    if (sysDate != onlineDate) {
      setState(() {
        showWarning = true;
      });
    }
  }

  Future<String> checkRealTime() async {
    TwoDThreeDApi api = TwoDThreeDApi(context);
    DateTime d = await api.getDateTime(context);
    DateTime n = DateTime.now();
    DateTime onlineDate = DateTime(d.year, d.month, d.day, d.hour, d.minute);
    DateTime sysDate = DateTime(n.year, n.month, n.day, n.hour, n.minute);
    var days;
    if (sysDate != onlineDate) {
      setState(() {
        days = DateFormat('EEEE').format(sysDate);
        return days;
      });
    } else {
      days = DateFormat('EEEE').format(onlineDate);
      return days;
    }
  }

  @override
  void dispose() {
    if (super.mounted) {
      isMounted = true;
      stopBack4app();
      dropdownvalue = '';
      _controller.dispose();
    }

    super.dispose();
  }

  stopBack4app() async {
    Subscription subscription = await liveQuery.client.subscribe(query);
    liveQuery.client.unSubscribe(subscription);
  }

  String date = "";
  String now = "";

  @override
  Widget build(BuildContext context) {
    HolidayModel holiday = context.watch<TwoDProvider>().holiday;

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text("2D History"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Visibility(
            visible: showWarning,
            child: Container(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      "Your system time is wrong. To get precise data, Please set the time zone (Myanmar) and set the correct time.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.yellow[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            // visible: true,
            visible: context.watch<TwoDProvider>().isHoliday,
            child: Card(
              color: const Color(0xffffffff),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 3,
              margin:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.solidTimesCircle,
                          color: Colors.red,
                          size: 25,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "2D CLOSED",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, bottom: 6, top: 0, right: 8),
                            child: holiday == null
                                ? const Text("")
                                : Text(
                                    holiday.date == null
                                        ? "SET Holiday: ${holiday.description}"
                                        : "(${getDayFormat(holiday.date)}) SET Holiday: ${holiday.description}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ParseLiveListWidget<ParseObject>(
                    query: query,
                    lazyLoading: true,
                    preloadedColumns: const ["test1", "sender.username"],
                    childBuilder: (BuildContext context,
                        ParseLiveListElementSnapshot<ParseObject> snapshot) {
                      if (snapshot.failed) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          child: Center(
                            child: Column(
                              children: [
                                const Text('something went wrong!'),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        DateTime updatedDateTime =
                            snapshot.loadedData.get<DateTime>("lastUpdateDate");
                        var data = snapshot.loadedData.get<String>("data");
                        List<TwoDLiveResult> list = [];
                        if (data != null && data != "") {
                          var obj = json.decode(data);
                          list = [];
                          for (var item in obj) {
                            list.add(TwoDLiveResult.fromJson(item));
                          }
                        }

                        DateTime now = DateTime.now();
                        bool showManualOutAnimation = false;
                        bool showAnimation =
                            !context.watch<TwoDProvider>().isHoliday;
                        if (showAnimation) {
                          for (int i = 0; i < list.length; i++) {
                            DateTime from = DateFormat('yyyy-MM-ddTHH:mm:ss')
                                .parse(list[i].fromDateTime);
                            DateTime to = DateFormat('yyyy-MM-ddTHH:mm:ss')
                                .parse(list[i].toDateTime);
                            DateTime toDisplayDateTime =
                                DateFormat('yyyy-MM-ddTHH:mm:ss')
                                    .parse(list[i].toDisplayDateTime);

                            DateTime dateManualOut;
                            if (list[i].section == "10:30 AM") {
                              dateManualOut =
                                  to.subtract(Duration(seconds: 15));
                            }
                            if (list[i].section == "12:01 PM") {
                              dateManualOut =
                                  to.subtract(Duration(seconds: 15));
                            }
                            if (list[i].section == "02:30 PM") {
                              dateManualOut =
                                  to.subtract(Duration(seconds: 15));
                            }
                            if (list[i].section == "04:30 PM") {
                              dateManualOut =
                                  to.subtract(Duration(seconds: 15));
                            }

                            //change ui 2022-08-18
                            if ((from.isBefore(now) &&
                                to.isAfter(now) &&
                                !list[i].isDone)) {
                              showAnimation = true;
                              //print('show1>>'+showAnimation.toString());
                              if ((list[i].switchManual &&
                                      (dateManualOut.isAtSameMomentAs(now) &&
                                          dateManualOut.isBefore(now)) ||
                                  dateManualOut.isBefore(now))) {
                                showManualOutAnimation = true;
                              }
                              //print("fff"+showManualOutAnimation.toString());
                              break;
                            }
                            if ((((toDisplayDateTime.isBefore(now) &&
                                        toDisplayDateTime
                                            .isAtSameMomentAs(now)) ||
                                    toDisplayDateTime.isBefore(now)) &&
                                list[i].switchManual &&
                                !list[i].isManual)) {
                              showAnimation = true;
                              if ((dateManualOut.isAtSameMomentAs(now) &&
                                      dateManualOut.isBefore(now)) ||
                                  dateManualOut.isBefore(now)) {
                                showManualOutAnimation = true;
                              }
                              //print("fff>>>"+showManualOutAnimation.toString());
                              // else{
                              //   showManualOutAnimation=false;
                              // }
                              //print('show2>>'+showAnimation.toString());
                              break;
                            } else {
                              showAnimation = false;
                              //showManualOutAnimation=false;
                              //print('show>>'+showAnimation.toString());
                            }
                          }
                        }
                        return Column(
                          children: [
                            Stack(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: showAnimation
                                      ? FadeTransition(
                                          opacity: _animation,
                                          child: !showManualOutAnimation
                                              ? Text(
                                                  snapshot.loadedData
                                                          .get<String>(
                                                              "result") ??
                                                      "--",
                                                  style: resultstyle,
                                                )
                                              : Text(
                                                  "--",
                                                  style: resultstyle,
                                                ),
                                        )
                                      : Text(
                                          snapshot.loadedData
                                                  .get<String>("result") ??
                                              "--",
                                          style: resultstyle,
                                        ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(260, 90, 0, 0),
                                  child: IconButton(
                                      color: Colors.grey,
                                      icon: FaIcon(
                                        FontAwesomeIcons.questionCircle,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        //print("Pressed");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                const TwoDHelpPage(),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                            updatedDateTime == null
                                ? Container()
                                : Container(
                                    margin: const EdgeInsets.only(
                                        top: 0, bottom: 5),
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, right: 5, left: 5),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // snapshot.loadedData.get<String>("result") == "--"
                                        !showAnimation
                                            ? const Icon(
                                                Icons.check,
                                                color: cardColor,
                                                size: 25,
                                              )
                                            : Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                child: const Icon(
                                                  Icons.restore_rounded,
                                                  color: cardColor,
                                                  size: 25,
                                                ),
                                              ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "Updated: ${getDate(updatedDateTime)}",
                                          style: GoogleFonts.roboto(
                                              color: cardColor,
                                              fontSize: 13,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Last 100 updated list",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                items: items
                                                    .map(
                                                        (item) =>
                                                            DropdownMenuItem<
                                                                    String>(
                                                                value: item,
                                                                child: Row(
                                                                  children: [
                                                                    dropdownvalue ==
                                                                            item
                                                                        ? Icon(
                                                                            FontAwesomeIcons
                                                                                .solidDotCircle,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                mainColor)
                                                                        : Icon(
                                                                            FontAwesomeIcons
                                                                                .circle,
                                                                            size:
                                                                                16),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    dropdownvalue ==
                                                                            item
                                                                        ? Text(
                                                                            item,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                              color: mainColor,
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            item,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                  ],
                                                                )))
                                                    .toList(),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    _loading = true;
                                                    dropdownvalue = newValue;
                                                    if (dropdownvalue ==
                                                        'Real Time') {
                                                      isNotRealTime = false;
                                                      isRealTime = true;
                                                      setState(() {});
                                                      return;
                                                    } else {
                                                      live2dNotRealTimelogList =
                                                          [];
                                                      isRealTime = false;
                                                      isNotRealTime = true;
                                                      queryLive2dlog =
                                                          QueryBuilder<
                                                                  ParseObject>(
                                                              ParseObject(
                                                                  'Live2dLog'))
                                                            ..whereEqualTo(
                                                                'section',
                                                                dropdownvalue);
                                                      fetchNotRealTimeData(
                                                          dropdownvalue);
                                                      setState(() {});
                                                      return;
                                                    }
                                                  });
                                                },
                                                dropdownElevation: 8,
                                                hint: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Text(
                                                    dropdownvalue,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                ),
                                                iconOnClick: const Icon(
                                                  Icons.keyboard_arrow_up,
                                                ),
                                                buttonDecoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                iconEnabledColor: Colors.grey,
                                                buttonHeight: 40,
                                                buttonWidth: 180,
                                                itemHeight: 40,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  _loading
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 30.0),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    mainColor),
                                          ),
                                        )
                                      : (live2dlogList != null ||
                                              live2dNotRealTimelogList != null
                                          ? Column(
                                              children: [
                                                Visibility(
                                                  visible: isRealTime,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      color: Colors.white,
                                                      elevation: 4,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child:
                                                            live2dlogList !=
                                                                    null
                                                                ? Column(
                                                                    children: live2dlogList
                                                                        .map((item) => Card(
                                                                              elevation: 0,
                                                                              color: item.isReference ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white,
                                                                              child: Container(
                                                                                padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                                                child: Column(
                                                                                  children: [
                                                                                    live2dlogList.indexOf(item) == 0
                                                                                        ? Padding(
                                                                                            padding: const EdgeInsets.only(bottom: 10),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          checkGetDate(updatedTime),
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "      Set",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "          Value",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "         2D",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  children: [
                                                                                                    SizedBox(
                                                                                                      width: 15,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      item.section,
                                                                                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          )
                                                                                        : Container(),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                      children: [
                                                                                        Text(
                                                                                          item.date != null
                                                                                              ? item.section != 'Real Time'
                                                                                                  ? getTime(item.date.toString())
                                                                                                  : getLiveTime(item.date.toString())
                                                                                              : "Date",
                                                                                          style: const TextStyle(color: Colors.black, fontSize: 16),
                                                                                        ),
                                                                                        item.set != null && item.set != "--"
                                                                                            ? RichText(
                                                                                                text: TextSpan(
                                                                                                  text: item.set.toString().substring(0, item.set.toString().length - 1),
                                                                                                  style: GoogleFonts.roboto(
                                                                                                    fontSize: 14.0,
                                                                                                    color: Colors.black,
                                                                                                  ),
                                                                                                  children: <TextSpan>[
                                                                                                    TextSpan(
                                                                                                      text: item.set.toString().substring(item.set.toString().length - 1, item.set.toString().length),
                                                                                                      style: GoogleFonts.roboto(fontSize: 14.0, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.amber),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            : Text(
                                                                                                "--",
                                                                                                style: GoogleFonts.roboto(
                                                                                                  fontSize: 14.0,
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                        item.value != null && item.value != "--"
                                                                                            ? RichText(
                                                                                                text: TextSpan(
                                                                                                  text: item.value.toString().substring(0, item.value.toString().length - 4),
                                                                                                  style: GoogleFonts.roboto(fontSize: 14.0, color: Colors.black),
                                                                                                  children: <TextSpan>[
                                                                                                    TextSpan(text: item.value.toString().substring(item.value.toString().length - 4, item.value.toString().length - 3), style: GoogleFonts.roboto(fontSize: 14.0, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.amber)),
                                                                                                    TextSpan(text: item.value.toString().substring(item.value.toString().length - 3, item.value.toString().length), style: GoogleFonts.roboto(fontSize: 14.0, color: Colors.black)),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            : Text(
                                                                                                '--',
                                                                                                style: GoogleFonts.roboto(
                                                                                                  fontSize: 14.0,
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                        Text(
                                                                                          item.result,
                                                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                                  )
                                                                : Column(
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            bottom:
                                                                                15),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                child: Column(
                                                                                  children: [
                                                                                    Text(
                                                                                      checkGetDate(updatedTime),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 12,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    dropdownvalue != 'Real Time'
                                                                                        ? Text(
                                                                                            dropdownvalue,
                                                                                            style: GoogleFonts.roboto(
                                                                                              fontSize: 14,
                                                                                              color: Colors.grey,
                                                                                            ),
                                                                                          )
                                                                                        : Container()
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
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
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
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
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
                                                                                      "2D",
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          "No Data"),
                                                                    ],
                                                                  ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: isNotRealTime,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      color: Colors.white,
                                                      elevation: 4,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child:
                                                            live2dNotRealTimelogList !=
                                                                    null
                                                                ? Column(
                                                                    children: live2dNotRealTimelogList
                                                                        .map((item) => Card(
                                                                              elevation: 0,
                                                                              color: Colors.white,
                                                                              child: Container(
                                                                                padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                                                child: Column(
                                                                                  children: [
                                                                                    live2dNotRealTimelogList.indexOf(item) == 0
                                                                                        ? Padding(
                                                                                            padding: const EdgeInsets.only(bottom: 10),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          checkGetDate(updatedTime),
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "      Set",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "          Value",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Container(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          "         2D",
                                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  children: [
                                                                                                    SizedBox(
                                                                                                      width: 15,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      item.section,
                                                                                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          )
                                                                                        : Container(),
                                                                                    Container(
                                                                                      color: item.isReference ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          Text(
                                                                                            item.date != null ? getTime(item.date.toString()) : "Date",
                                                                                            style: const TextStyle(color: Colors.black, fontSize: 16),
                                                                                          ),
                                                                                          item.set != null && item.set != "--"
                                                                                              ? RichText(
                                                                                                  text: TextSpan(
                                                                                                    text: item.set.toString().substring(0, item.set.toString().length - 1),
                                                                                                    style: GoogleFonts.roboto(
                                                                                                      fontSize: 14.0,
                                                                                                      color: Colors.black,
                                                                                                    ),
                                                                                                    children: <TextSpan>[
                                                                                                      TextSpan(
                                                                                                        text: item.set.toString().substring(item.set.toString().length - 1, item.set.toString().length),
                                                                                                        style: GoogleFonts.roboto(fontSize: 14.0, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.amber),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              : Text(
                                                                                                  "--",
                                                                                                  style: GoogleFonts.roboto(
                                                                                                    fontSize: 14.0,
                                                                                                    color: Colors.black,
                                                                                                  ),
                                                                                                ),
                                                                                          item.value != null && item.value != "--"
                                                                                              ? RichText(
                                                                                                  text: TextSpan(
                                                                                                    text: item.value.toString().substring(0, item.value.toString().length - 4),
                                                                                                    style: GoogleFonts.roboto(fontSize: 14.0, color: Colors.black),
                                                                                                    children: <TextSpan>[
                                                                                                      TextSpan(text: item.value.toString().substring(item.value.toString().length - 4, item.value.toString().length - 3), style: GoogleFonts.roboto(fontSize: 14.0, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.amber)),
                                                                                                      TextSpan(text: item.value.toString().substring(item.value.toString().length - 3, item.value.toString().length), style: GoogleFonts.roboto(fontSize: 14.0, color: Colors.black)),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              : Text(
                                                                                                  '--',
                                                                                                  style: GoogleFonts.roboto(
                                                                                                    fontSize: 14.0,
                                                                                                    color: Colors.black,
                                                                                                  ),
                                                                                                ),
                                                                                          Text(
                                                                                            item.result,
                                                                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                                  )
                                                                : Column(
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            bottom:
                                                                                15),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                child: Column(
                                                                                  children: [
                                                                                    Text(
                                                                                      checkGetDate(updatedTime),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 12,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      dropdownvalue,
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    )
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
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
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
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
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
                                                                                      "2D",
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          "No Data"),
                                                                    ],
                                                                  ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                color: Colors.white,
                                                elevation: 4,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10,
                                                                bottom: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      checkGetDate(
                                                                          updatedTime),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    dropdownvalue !=
                                                                            'Real Time'
                                                                        ? Text(
                                                                            dropdownvalue,
                                                                            style:
                                                                                GoogleFonts.roboto(
                                                                              fontSize: 14,
                                                                              color: Colors.grey,
                                                                            ),
                                                                          )
                                                                        : Container()
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      "Set",
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      "Value",
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      "2D",
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text("No Data"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                  SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Loading SET 2D Live Data...",
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }

  getDate(DateTime date) {
    var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
    String formattedDate = formatter.format(date.toLocal());
    return formattedDate;
  }

  getDayFormat(date) {
    // DateTime myDate = DateFormat("yyy-MM-dd").parse(date);
    var date1 = DateFormat("dd.MM.yyyy").format(date);
    return date1;
  }

  Future<DateTime> getCorrectTime() async {
    TwoDThreeDApi api = TwoDThreeDApi(context);
    DateTime d = await api.getDateTime(context);
    // DateTime n = DateTime.now();
    DateTime onlineDate = DateTime(d.year, d.month, d.day);
    // DateTime sysDate = DateTime(n.year, n.month, n.day, n.hour, n.minute);
    return onlineDate;
  }

  Future<void> updateApp() async {
    String _localPath = (await _findLocalPath());
    String apkFileLocation = _localPath + "/" + appName;
    File apkFile = File(apkFileLocation);
    bool isExist = await apkFile.exists();

    if (isExist) {
      int apkSizeInBytes = await apkFile.length();
      // double sizeInMb = apkSizeInBytes / (1024 * 1024);
      if (apkSizeInBytes == size) {
        // "/storage/emulated/0/Android/data/com.example.thai2dlive/files/thai2dlive-1.0.1.apk"
        OpenResult openState = await OpenFile.open(apkFileLocation);

        if (openState.type == ResultType.error) {
          await download();
        } else if (openState.type == ResultType.fileNotFound) {
          await download();
        }
      } else {
        await download();
      }
    } else {
      await download();
    }
  }

  download() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        if (appUpdateUrl != null && appUpdateUrl != "") {
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => DownLoadPage(
                  title: "Update new version $updateversion",
                  appName: appName,
                  url: appUpdateUrl,
                  // apkV7AUrl: apkV7AUrl,
                  // apkV8AUrl: apkV8AUrl,
                  // apkX86_64Url: apkX86_64Url,
                  version: updateversion));
        }
      } else {}
    } else {
      if (appUpdateUrl != null && appUpdateUrl != "") {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => DownLoadPage(
                title: "Update new version $updateversion",
                appName: appName,
                url: appUpdateUrl,
                // apkV7AUrl: apkV7AUrl,
                // apkV8AUrl: apkV8AUrl,
                // apkX86_64Url: apkX86_64Url,
                version: updateversion));
      }
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
        //externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    }

    return externalStorageDirPath;
  }

  checkGetDate(date) {
    //print(date);
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(date);
    //print("formattedDate"+formattedDate);
    return formattedDate;
  }

  getTime(time) {
    var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    DateTime tempDate = formatter.parse(time);
    var dateFormat = DateFormat("h:mm:ss");
    return dateFormat.format(tempDate);
  }

  getLiveTime(time) {
    var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    DateTime tempDate = formatter.parse(time);
    tempDate = tempDate.add(Duration(hours: 6, minutes: 30));
    var dateFormat = DateFormat("h:mm:ss");
    // print("formattedDate"+dateFormat.toString());
    return dateFormat.format(tempDate);
  }

// List<String> supportApk = [];
// Future<void> initPlatformState() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   try {
//     if (!kIsWeb) {
//       if (Platform.isAndroid) {
//         var build = await deviceInfo.androidInfo;
//         supportApk = build.supportedAbis;
//         print(build.supportedAbis);

//         if (supportApk.isNotEmpty) {
//           fileSize = size;
//           // armeabi-v7a,arm64-v8a,x86,x86_64
//           if (supportApk.contains("armeabi-v7a")) {
//             fileSize = size_V7A;
//           } else if (supportApk.contains("arm64-v8a")) {
//             fileSize = size_V8A;
//           } else if (supportApk.contains("x86_64")) {
//             fileSize = size_X86_64;
//           }
//         } else {
//           fileSize = size;
//         }
//       }
//     }
//     // ignore: empty_catches, non_constant_identifier_names
//   } catch (PlatformException) {}

//   if (!mounted) return;
// }

}

class ArrrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw UnimplementedError();
  }
}
