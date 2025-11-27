// @dart=2.9
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/data/data_key_name.dart';
import 'package:thai2dlive/data/database_helper.dart';
import 'package:thai2dlive/models/notification_page_obj.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({Key key, @required this.item})
      : super(key: key);
  final NotificationPageObj item;

  @override
  _NotificationDetailPage createState() => _NotificationDetailPage();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _NotificationDetailPage extends State<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      markAsRead();
    }
  }

  markAsRead() async {
    await DatabaseHelper.setData("read", DataKeyValue.backgroundNotiStatus);
    if (widget.item != null) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Details"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          child: getNotiWidget(context),
        ),
      ),
    );
  }

  Widget getNotiWidget(BuildContext context) {
    if (widget.item.type == "2D Results") {
      return Stack(fit: StackFit.loose, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(
                    left: 7, right: 7, bottom: 5, top: 100),
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 40, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: widget.item.title,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            children: <TextSpan>[
                              TextSpan(
                                  text: " " + widget.item.number.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: mainColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        color: Colors.black,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "Date  " +
                                (widget.item.currentdate != null
                                    ? getDate(widget.item.currentdate)
                                            .toString() +
                                        "  "
                                    : ""),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.item.fortime,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: mainColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 65,
          left: MediaQuery.of(context).size.width * 0.42,
          child: Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                getImage(widget.item.fortime),
                width: 60.0,
                height: 60.0,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ]);
    } else if (widget.item.type == "3D Results") {
      return Stack(fit: StackFit.loose, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              //height: 300,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(
                    left: 7, right: 7, bottom: 5, top: 100),
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 40, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "3D result number is ",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            children: <TextSpan>[
                              TextSpan(
                                  text: " " + widget.item.number.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: mainColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        color: Colors.black,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "Date " +
                                (widget.item.currentdate != null
                                    ? getDate(widget.item.currentdate)
                                        .toString()
                                    : ""),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: " 3:30 PM",
                                  //(widget.item.currentdate!=null?getTime(widget.item.currentdate).toString():""),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: mainColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 65,
          left: MediaQuery.of(context).size.width * 0.42,
          child: Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/3D.jpg',
                width: 60.0,
                height: 60.0,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ]);
    } else if (widget.item.type == "All" || widget.item.type == "Others") {
      return Stack(fit: StackFit.loose, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(
                    left: 7, right: 7, bottom: 5, top: 100),
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 30, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(
                          widget.item.title ?? "",
                          style: const TextStyle(
                              fontSize: 15,
                              color: mainColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          widget.item.body ?? "",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        color: Colors.black,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "Date ",
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            children: <TextSpan>[
                              TextSpan(
                                text: (widget.item.currentdate != null
                                        ? getDate(widget.item.currentdate)
                                            .toString()
                                        : "") +
                                    "  " +
                                    (widget.item.currentdate != null
                                        ? getTime(widget.item.currentdate)
                                            .toString()
                                        : ""),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: mainColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 65,
          left: MediaQuery.of(context).size.width * 0.42,
          child: Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/icon.png',
                width: 60.0,
                height: 60.0,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ]);
    } else {
      return Container();
    }
  }

  String getImage(String forTime) {
    String image = "assets/2D-1030.jpg";
    switch (forTime) {
      case '10:30 AM':
        image = "assets/2D-1030.jpg";
        break;

      case '12:01 PM':
        image = "assets/2D-12.jpg";
        break;

      case '02:30 PM':
        image = "assets/2D-230.jpg";
        break;

      case '04:30 PM':
        image = "assets/2D-430.jpg";
        break;
    }
    return image;
  }

  getTime(date) {
    DateTime tempDate = DateFormat("M/d/yyyy hh:mm:ss a").parse(date);
    // DateTime tempDate = DateFormat("yyyy-MM-ddThh:mm:ss").parse(date);
    var dateFormat = DateFormat("h:mm a");
    var result = dateFormat.format(tempDate);
    return result;
  }

  getDate(date) {
    // 3/4/2022 2:51:31 PM
    DateTime tempDate1 = DateFormat("M/d/yyyy hh:mm:ss a").parse(date);
    // DateTime tempDate1 = DateFormat("yyyy-MM-ddThh:mm:ss").parse(date);
    var dateFormat1 = DateFormat("dd/MM/yyyy");
    var result = dateFormat1.format(tempDate1);
    return result;
  }
}
