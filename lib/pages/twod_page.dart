// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/api/twod_threed_api.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/data/sys_data.dart';
import 'package:thai2dlive/models/holiday_model.dart';
import 'package:thai2dlive/models/two_d_live_result.dart';
import 'package:thai2dlive/pages/twod_history_page.dart';
import 'package:thai2dlive/pages/twod_realtime_history_page.dart';
import 'package:thai2dlive/providers/twod_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/two_d_modern_result.dart';
import '../models/two_d_modern_result_update.dart';
import 'about_us.dart';
import 'api_for_developer_mobile_screen.dart';
import 'chat.dart';
import 'download_page.dart';
import 'holiday_page.dart';
import 'threed_result_page.dart';
import 'dart:math' as math;
import 'twod_result_page.dart';

class TwoDPage extends StatefulWidget {
  const TwoDPage({Key key}) : super(key: key);
  @override
  _TwoDPageState createState() => _TwoDPageState();
}

class _TwoDPageState extends State<TwoDPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  AnimationController _controller;
  Animation _animation;
  var appBarHeight = AppBar().preferredSize.height;
  final LiveQuery liveQuery = LiveQuery();

  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('TwoDLiveResult'))
        ..whereEqualTo('objectId', 'xNiYjJixOZ'); //edit pro

  QueryBuilder<ParseObject> modernInternet =
      QueryBuilder<ParseObject>(ParseObject('ModernInternet'));

  QueryBuilder<ParseObject> modernInternetLink =
      QueryBuilder<ParseObject>(ParseObject('Live2dboss'));

  QueryBuilder<ParseObject> playstoreChecked =
      QueryBuilder<ParseObject>(ParseObject('ThaiSet2D'));

  bool isMounted = false;
  FirebaseMessaging _messaging;
  String link = "";
  String appUpdateUrl = "";
  // String apkV7AUrl = "";
  // String apkV8AUrl = "";
  // String apkX86_64Url = "";
  String appName = "";
  String updateversion = "";
  // int size_V7A = 0;
  // int size_V8A = 0;
  // int size_X86_64 = 0;
  int size = 0;
  // int fileSize = 0;

  String isPlaystored = "";

  // AppcastConfiguration cfg = AppcastConfiguration(
  //     url: SystemData.updateLink, supportedOS: ['android']);
  TwoDModernNumberModel modern;
  TwoDModernNumberModel modernNew;

  List<TwoDModernNumberUpdateModel> list = [];
  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    checkVersionUpdate();
    // checkVersionUpdate(context);
    // getLink();

    checkHoliday();
    checkCorrectTime();
    if (!kIsWeb) {
      subscriptToPublicChannel();
    }
    getModernInternet();
    getTwoDModernNumber();
    getPlaystoreChecked();
  }

  Future<void> checkVersionUpdate(
      // BuildContext context
      ) async {
    var appUpdateLinkRef = FirebaseFirestore.instance.collection(appUpdateLink);
    try {
      await appUpdateLinkRef.get().then((value) {
        value.docs.forEach((result) {
          link = result.data()['url'];
          updateversion = result.data()['version'];
          appUpdateUrl = result.data()['appUpdateUrl'];
          appName = result.data()['name'];
          size = result.data()['fileSize'];
        });

        SystemData.updateVersion = updateversion;
        SystemData.appName = appName;
        int newVer = int.parse(updateversion.replaceAll(".", ""));
        int myVer = int.parse(version.replaceAll(".", ""));
        if (newVer > myVer) {
          _showUpdateAlertDialog(context);
        }
      });
    } catch (e) {}
  }

  // getLink() async {
  //   link = await DatabaseHelper.getData(DataKeyValue.updateLink);
  // }

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

  getTwoDModernNumber() async {
    TwoDModernNumberModel modernNew;
    TwoDThreeDApi api = TwoDThreeDApi(context);
    var url = "";
    var response = await modernInternetLink.query();
    print("ModernResponse>>>>" + response.result.toString());
    if (response.success) {
      for (var item in response.results) {
        url = item['link'];
      }
      setState(() {});
    }
    print("ModernNewinint>>>>" + modernNew.toString());
    modernNew = await api.getTwodModernNumber(context, url);
    // modernNew.internet930=null;
    // modernNew.modern930=null;
    // modernNew.internet200=null;
    // modernNew.modern200=null;
    print("ModernNew>>>>" + modernNew.toString());
    print("List>>>>" + list.toString());
    DateTime date = await api.getDateTime(context);

    if (modernNew == null) {
      if ((date.hour == 9 && date.minute >= 30) || date.hour > 9) {
        TwoDModernNumberModel moderncc = TwoDModernNumberModel(
          internet930: list[0].internet,
          modern930: list[0].modern,
          internet200: null,
          modern200: null,
        );
        modern = moderncc;
        setState(() {});
        return;
      }
      if (date.hour >= 14) {
        TwoDModernNumberModel moderncc = TwoDModernNumberModel(
          internet930: list[0].internet,
          modern930: list[0].modern,
          internet200: list[0].internet230,
          modern200: list[0].modern230,
        );
        modern = moderncc;
        setState(() {});
        return;
      } else {
        TwoDModernNumberModel moderncc = TwoDModernNumberModel(
          internet930: list[0].internet,
          modern930: list[0].modern,
          internet200: list[0].internet230,
          modern200: list[0].modern230,
        );
        modern = moderncc;
        setState(() {});
        return;
      }
    } else {
      if (((date.hour == 9 && date.minute >= 30) || date.hour > 9) &&
          date.hour < 14) {
        if (modernNew.internet930 == null || modernNew.modern930 == null) {
          modernNew.internet930 = list[0].internet;
          modernNew.modern930 = list[0].modern;
          modern = modernNew;
          setState(() {});
        } else {
          modern = modernNew;
          setState(() {});
        }
        return;
      }
      if (date.hour >= 14) {
        if (modernNew.internet930 == null || modernNew.modern930 == null) {
          modernNew.internet930 = list[0].internet;
          modernNew.modern930 = list[0].modern;
          modern = modernNew;
          setState(() {});
        }
        if (modernNew.internet200 == null || modernNew.modern200 == null) {
          modernNew.internet200 = list[0].internet230;
          modernNew.modern200 = list[0].modern230;
          modern = modernNew;
          setState(() {});
        } else {
          modern = modernNew;
          setState(() {});
        }
        return;
      } else {
        modern = modernNew;
        setState(() {});
        return;
      }
    }
  }

  Future<void> getModernInternet() async {
    var response = await modernInternet.query();
    if (response.success) {
      list = [];
      for (var item in response.results) {
        TwoDModernNumberUpdateModel model = TwoDModernNumberUpdateModel(
          internet: item['internet'],
          modern: item['modern'],
          internet230: item['internet230'],
          modern230: item['modern230'],
        );
        list.add(model);
      }
      setState(() {});
    } else {
      list = [];
    }
  }

  bool showWarning = false;
  Future<void> checkCorrectTime() async {
    TwoDThreeDApi api = TwoDThreeDApi(context);
    DateTime d = await api.getDateTime(context);
    DateTime n = DateTime.now();
    DateTime onlineDate = DateTime(d.year, d.month, d.day, d.hour, d.minute);
    DateTime sysDate = DateTime(n.year, n.month, n.day, n.hour, n.minute);
    print("OnnlieDate>>>" + onlineDate.toString());
    print("sysDate>>>" + sysDate.toString());
    if (sysDate != onlineDate) {
      setState(() {
        showWarning = true;
      });
    }
  }

  @override
  void dispose() {
    if (super.mounted) {
      isMounted = true;
      stopBack4app();
      _controller.dispose();
    }

    super.dispose();
  }

  stopBack4app() async {
    Subscription subscription = await liveQuery.client.subscribe(query);
    liveQuery.client.unSubscribe(subscription);
  }

  // _launchURL() async {
  //   StoreRedirect.redirect(
  //       androidAppId: "intersoft.pos.soft_ta", iOSAppId: "284882215");
  // }
  String date = "";
  String now = "";

  @override
  Widget build(BuildContext context) {
    HolidayModel holiday = context.watch<TwoDProvider>().holiday;

    // HolidayModel holiday = HolidayModel(
    //     date: "2021-12-31T00:00:00", description: "Constitution Day");

    // var cfg = AppcastConfiguration(url: link, supportedOS: ['android']);
    // var cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text("Thai SET 2D"),
        centerTitle: false,
        backgroundColor: mainColor,
        actions: [
          isPlaystored == "0"
              ? InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const ChatScreen(),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.comments,
                        // color: Colors.white,
                        color: Color(0xffffffff),
                        size: 26,
                      ),
                    ),
                  ),
                )
              : Container(),
          const SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const TwoDResultPage(),
                  ));
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffffffff),
                // border: Border.all(
                //   // color: Colors.white,
                //   color: Color(0xffffffff),
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffffffff),
                    // color: Colors.grey,
                    blurRadius: 4.0,
                    offset: Offset(0.0, 0.0),
                    // spreadRadius: 1.0,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              // margin: const EdgeInsets.only(top: 10),
              width: 28,
              height: 28,
              child: const Center(
                child: Text(
                  "2D",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const ThreeDPage(),
                  ));
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffffffff),
                    blurRadius: 4.0,
                    offset: Offset(0.0, 0.0),
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              // margin: const EdgeInsets.only(top: 10),
              width: 28,
              height: 28,
              child: const Center(
                child: Text(
                  "3D",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: Color(0xffffffff),
                    color: mainColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          PopupMenuButton(
              offset: Offset(0.0, appBarHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const HolidayPage(),
                    ),
                  );
                }
                if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const AboutUs(),
                    ),
                  );
                }
                if (value == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          TwoDRealTimeHistoryPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      padding: EdgeInsets.all(0.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                            ),
                            FaIcon(
                              FontAwesomeIcons.calendarAlt,
                              color: mainColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Holiday", style: TextStyle(color: mainColor)),
                          ],
                        ),
                      ),
                      value: 1,
                    ),
                    PopupMenuItem(
                      padding: EdgeInsets.all(0.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                            ),
                            FaIcon(
                              FontAwesomeIcons.infoCircle,
                              color: mainColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "About Us",
                              style: TextStyle(color: mainColor),
                            ),
                          ],
                        ),
                      ),
                      value: 2,
                    ),
                    PopupMenuItem(
                      padding: EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                          ),
                          FaIcon(
                            FontAwesomeIcons.clock,
                            color: mainColor,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Real Time History",
                              style: TextStyle(color: mainColor)),
                        ],
                      ),
                      value: 3,
                    ),
                  ],
              child: Row(
                children: [
                  Icon(
                    Icons.more_vert,
                    size: 35,
                  ),
                  // Text('Setting'),
                ],
              )),
        ],
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
                                getBtnRow(),
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
                        bool showAnimation =
                            !context.watch<TwoDProvider>().isHoliday;
                        bool showManualOutAnimation = false;
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

                            bool isOngoingAndNotDone = from.isBefore(now) &&
                                to.isAfter(now) &&
                                !list[i].isDone;

                            bool isManualPendingCondition = (toDisplayDateTime
                                        .isBefore(now) ||
                                    toDisplayDateTime.isAtSameMomentAs(now)) &&
                                ((list[i].switchManual && !list[i].isManual) ||
                                    (!list[i].switchManual &&
                                        !list[i].isDone)) &&
                                now.hour < 17;

                            if (isOngoingAndNotDone) {
                              showAnimation = true;
                              showManualOutAnimation = false;
                              break;
                            } else if (isManualPendingCondition) {
                              showAnimation = false;
                              showManualOutAnimation = false;
                              break;
                            } else {
                              showAnimation = false;
                              showManualOutAnimation = false;
                            }
                          }
                        }
                        return Column(
                          children: [
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
                                                      .get<String>("result") ??
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
                                  SizedBox(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height, //480//510,
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: list.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        TwoDLiveResult item = list[index];
                                        return InkWell(
                                          onTap: () async {
                                            if ((item.switchManual &&
                                                    item.isManual &&
                                                    (item.isShowHistory !=
                                                            null &&
                                                        item.isShowHistory)) ||
                                                (!item.switchManual &&
                                                    item.isDone &&
                                                    (item.isShowHistory !=
                                                            null &&
                                                        item.isShowHistory))) {
                                              //to edit
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          TwoDHistoryPage(
                                                              result:
                                                                  item.result,
                                                              section:
                                                                  item.section),
                                                ),
                                              );
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Card(
                                                color: index % 2 == 0
                                                    ? mainColor
                                                    : cardColor,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                margin: const EdgeInsets.only(
                                                    top: 0,
                                                    bottom: 10,
                                                    right: 10,
                                                    left: 10),
                                                // top: 0,
                                                // bottom: 8,
                                                // right: 10,
                                                // left: 10),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .only(
                                                      top: 5,
                                                      bottom:
                                                          10), // top: 10, bottom: 15),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 7.5,
                                                                bottom: 7.5),
                                                        child: Text(
                                                          item.section,
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 1,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                        color: const Color(
                                                                0xffffffff)
                                                            .withOpacity(0.6),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 16,
                                                          right: 16,
                                                          top: 12,
                                                        ),
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
                                                                      "Set",
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10.0),
                                                                      child: item.set != "--" &&
                                                                              item.set != null &&
                                                                              item.set != ""
                                                                          ? ((showAnimation && item.switchManual && !item.isManual) || (showAnimation && !item.switchManual && !item.isDone))
                                                                              ? FadeTransition(
                                                                                  opacity: _animation,
                                                                                  child: !showManualOutAnimation
                                                                                      ? RichText(
                                                                                          text: TextSpan(
                                                                                            text: item.set.substring(0, item.set.length - 1),
                                                                                            style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                            children: <TextSpan>[
                                                                                              TextSpan(text: item.set.substring(item.set.length - 1, item.set.length), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow)),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      : Text(
                                                                                          "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                        ),
                                                                                )
                                                                              : RichText(
                                                                                  text: TextSpan(
                                                                                    text: item.set.substring(0, item.set.length - 1),
                                                                                    style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                    children: <TextSpan>[
                                                                                      TextSpan(text: item.set.substring(item.set.length - 1, item.set.length), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow)),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                          : Text(
                                                                              item.set,
                                                                              style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
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
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10.0),
                                                                      child: item.value != "--" &&
                                                                              item.value != null &&
                                                                              item.value != ""
                                                                          ? ((showAnimation && item.switchManual && !item.isManual) || (showAnimation && !item.switchManual && !item.isDone))
                                                                              ? FadeTransition(
                                                                                  opacity: _animation,
                                                                                  child: !showManualOutAnimation
                                                                                      ? RichText(
                                                                                          text: TextSpan(
                                                                                            text: item.value.substring(0, item.value.length - 4),
                                                                                            style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                            children: <TextSpan>[
                                                                                              TextSpan(text: item.value.substring(item.value.length - 4, item.value.length - 3), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow)),
                                                                                              TextSpan(text: item.value.substring(item.value.length - 3, item.value.length), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      : Text(
                                                                                          "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                        ),
                                                                                )
                                                                              : RichText(
                                                                                  text: TextSpan(
                                                                                    text: item.value.substring(0, item.value.length - 4),
                                                                                    style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                    children: <TextSpan>[
                                                                                      TextSpan(text: item.value.substring(item.value.length - 4, item.value.length - 3), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow)),
                                                                                      TextSpan(text: item.value.substring(item.value.length - 3, item.value.length), style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                          : Text(
                                                                              item.value,
                                                                              style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
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
                                                                    Text("2D",
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white)),
                                                                    Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                10.0),
                                                                        child: ((showAnimation && item.switchManual && !item.isManual) ||
                                                                                (showAnimation && !item.switchManual && !item.isDone))
                                                                            ? Text(
                                                                                "--",
                                                                                style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                              )
                                                                            : Text(
                                                                                item.result,
                                                                                style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                              )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ((item.switchManual &&
                                                                        item
                                                                            .isManual &&
                                                                        (item.isShowHistory !=
                                                                                null &&
                                                                            item
                                                                                .isShowHistory)) ||
                                                                    (!item.switchManual &&
                                                                        item
                                                                            .isDone &&
                                                                        (item.isShowHistory !=
                                                                                null &&
                                                                            item.isShowHistory)))
                                                                ? SizedBox(
                                                                    width: 15,
                                                                    child:
                                                                        Column(
                                                                      children: const [
                                                                        Text(
                                                                            ""),
                                                                        Icon(
                                                                            Icons
                                                                                .arrow_forward_ios,
                                                                            color:
                                                                                Colors.white,
                                                                            size: 15),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              index == (list.length - 1)
                                                  ? Column(
                                                      children: [
                                                        SizedBox(
                                                          child: Card(
                                                            color: mainColor,
                                                            elevation: 3,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 0,
                                                                    bottom: 10,
                                                                    right: 10,
                                                                    left: 10),
                                                            // top: 0,
                                                            // bottom: 8,
                                                            // right: 10,
                                                            // left: 10),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5,
                                                                      bottom:
                                                                          10), // top: 10, bottom: 15),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text(
                                                                                  "",
                                                                                  style: GoogleFonts.roboto(
                                                                                    fontSize: 14,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: Text(
                                                                                    "9:30 AM",
                                                                                    style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text(
                                                                                  "Modern",
                                                                                  style: GoogleFonts.roboto(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: modern == null
                                                                                      ? Container(
                                                                                          child: SpinKitChasingDots(color: Colors.white, size: 15),
                                                                                        )
                                                                                      : Text(
                                                                                          (modern.modern930 != null && modern.modern930 != "") ? modern.modern930.toString() : "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                                        ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text("Internet", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: modern == null
                                                                                      ? Container(
                                                                                          child: SpinKitChasingDots(color: Colors.white, size: 15),
                                                                                        )
                                                                                      : Text(
                                                                                          (modern.internet930 != null && modern.internet930 != "") ? modern.internet930.toString() : "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                                        ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 1,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    color: const Color(
                                                                            0xffffffff)
                                                                        .withOpacity(
                                                                            0.6),
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: Text(
                                                                                    "2:00 PM",
                                                                                    style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: modern == null
                                                                                      ? Container(
                                                                                          child: SpinKitChasingDots(color: Colors.white, size: 15),
                                                                                        )
                                                                                      : Text(
                                                                                          (modern.modern200 != null && modern.modern200 != "") ? modern.modern200.toString() : "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                                        ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: modern == null
                                                                                      ? Container(
                                                                                          child: SpinKitChasingDots(color: Colors.white, size: 15),
                                                                                        )
                                                                                      : Text(
                                                                                          (modern.internet200 != null && modern.internet200 != "") ? modern.internet200.toString() : "--",
                                                                                          style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.yellow),
                                                                                        ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          child: getBtnRow(),
                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    // child: ListView(
                                    //   physics: const NeverScrollableScrollPhysics(),
                                    //   children: list.map((item) {

                                    //   }).toList(),
                                    // ),
                                  ),
                                  // SizedBox(
                                  //   child: Card(
                                  //     color:mainColor,
                                  //     elevation: 3,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius:
                                  //       BorderRadius.circular(10.0),
                                  //     ),
                                  //     margin: const EdgeInsets.only(
                                  //         top: 0,
                                  //         bottom: 10,
                                  //         right: 10,
                                  //         left: 10),
                                  //     // top: 0,
                                  //     // bottom: 8,
                                  //     // right: 10,
                                  //     // left: 10),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.only(
                                  //           top: 5, bottom: 10),  // top: 10, bottom: 15),
                                  //       child: Column(
                                  //         children: [
                                  //           Container(
                                  //             padding: const EdgeInsets.only(
                                  //                 left: 16,
                                  //                 right: 16,
                                  //                 top: 5,bottom: 5),
                                  //             child: Row(
                                  //               mainAxisAlignment:
                                  //               MainAxisAlignment
                                  //                   .spaceBetween,
                                  //               children: [
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //                         Text(
                                  //                           "",
                                  //                           style: GoogleFonts
                                  //                               .roboto(
                                  //                             fontSize: 14,
                                  //                             color: Colors
                                  //                                 .white,
                                  //                           ),
                                  //                         ),
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child:  Text(
                                  //                             "9:30 AM",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight: FontWeight.bold,
                                  //                                 color: Colors.white),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //                         Text(
                                  //                           "Modern",
                                  //                           style: GoogleFonts
                                  //                               .roboto(
                                  //                             fontSize: 14,
                                  //                             fontWeight: FontWeight.bold,
                                  //                             color: Colors
                                  //                                 .white,
                                  //                           ),
                                  //                         ),
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child: modern == null
                                  //                               ? Container(
                                  //                             child: SpinKitChasingDots(
                                  //                                 color: Colors.white,
                                  //                                 size: 15),
                                  //                           )
                                  //                               : Text(
                                  //                             (modern.modern930 !=
                                  //                                 null &&
                                  //                                 modern
                                  //                                     .modern930 !=
                                  //                                     "")
                                  //                                 ? modern.modern930
                                  //                                 .toString()
                                  //                                 : "--",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight:
                                  //                                 FontWeight.bold,
                                  //                                 color: Colors.yellow),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //                         Text("Internet",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize:
                                  //                                 14,fontWeight: FontWeight.bold,
                                  //                                 color: Colors
                                  //                                     .white)),
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child:modern == null
                                  //                               ? Container(
                                  //                             child: SpinKitChasingDots(
                                  //                                 color: Colors.white,
                                  //                                 size: 15),
                                  //                           )
                                  //                               : Text(
                                  //                             (modern.internet930 !=
                                  //                                 null &&
                                  //                                 modern
                                  //                                     .internet930 !=
                                  //                                     "")
                                  //                                 ? modern.internet930
                                  //                                 .toString()
                                  //                                 : "--",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight:
                                  //                                 FontWeight.bold,
                                  //                                 color: Colors.yellow),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //           Container(
                                  //             height: 1,
                                  //             width: MediaQuery.of(context)
                                  //                 .size
                                  //                 .width *
                                  //                 0.9,
                                  //             color: const Color(0xffffffff)
                                  //                 .withOpacity(0.6),
                                  //           ),
                                  //           Container(
                                  //             padding: const EdgeInsets.only(
                                  //                 left: 16,
                                  //                 right: 16),
                                  //             child: Row(
                                  //               mainAxisAlignment:
                                  //               MainAxisAlignment
                                  //                   .spaceBetween,
                                  //               children: [
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child:  Text(
                                  //                             "2:00 PM",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight: FontWeight.bold,
                                  //                                 color: Colors.white),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child: modern == null
                                  //                               ? Container(
                                  //                             child: SpinKitChasingDots(
                                  //                                 color: Colors.white,
                                  //                                 size: 15),
                                  //                           )
                                  //                               : Text(
                                  //                             (modern.modern200 !=
                                  //                                 null &&
                                  //                                 modern
                                  //                                     .modern200 !=
                                  //                                     "")
                                  //                                 ? modern.modern200
                                  //                                 .toString()
                                  //                                 : "--",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight:
                                  //                                 FontWeight.bold,
                                  //                                 color: Colors.yellow),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     alignment:
                                  //                     Alignment.center,
                                  //                     child: Column(
                                  //                       children: [
                                  //
                                  //                         Padding(
                                  //                           padding:
                                  //                           const EdgeInsets
                                  //                               .only(
                                  //                               top:
                                  //                               10.0),
                                  //                           child:modern == null
                                  //                               ? Container(
                                  //                             child: SpinKitChasingDots(
                                  //                                 color: Colors.white,
                                  //                                 size: 15),
                                  //                           )
                                  //                               : Text(
                                  //                             (modern.internet200 !=
                                  //                                 null &&
                                  //                                 modern
                                  //                                     .internet200 !=
                                  //                                     "")
                                  //                                 ? modern.internet200
                                  //                                 .toString()
                                  //                                 : "--",
                                  //                             style: GoogleFonts.roboto(
                                  //                                 fontSize: 18.0,
                                  //                                 fontWeight:
                                  //                                 FontWeight.bold,
                                  //                                 color: Colors.yellow),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   child: getBtnRow(),
                                  // ),
                                  // SizedBox(
                                  //   height: 50,
                                  // )
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
                                getBtnRow(),
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

  Widget getBtnRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 20,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  _showVersionDialog(context);
                  // Text("Your app is the latest version")
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mainColor),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Center(
                    child: Text(
                      "Version $version",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Future<void> _showVersionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: mainColor,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                // IconButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                //   icon: const Icon(
                //     Icons.close,
                //     color: Colors.white,
                //   ),
                // ),
                Text(
                  "Your app is the latest version",
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _showUpdateAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            actionsPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.black12,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Text(
                    "Close",
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    return null;
                  },
                ),
                // const SizedBox(
                //   width: 20,
                // ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.black12,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Text(
                    "Update",
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // await initPlatformState();
                    await updateApp();
                  },
                ),
              ]),
            ],
            title: Center(
              child: Row(
                children: const [
                  Flexible(
                    child: Text(
                      "Update App ?",
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: null,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2, 0, 4, 0),
                            child: Icon(
                              Icons.warning,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        TextSpan(
                          text:
                              "A new version of Thai2D Live is available! Version $updateversion is now available-you have $version.",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ));
      },
    );
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

  getPlaystoreChecked() async {
    var response = await playstoreChecked.query();
    if (response.success) {
      for (var item in response.results) {
        isPlaystored = item['isPlaystored'];
        setState(() {});
      }
    } else {
      isPlaystored = "";
      setState(() {});
    }
  }
}
