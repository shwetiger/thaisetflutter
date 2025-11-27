// @dart=2.9
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/live_2d_log.dart';
import 'package:thai2dlive/pages/twod_help_page.dart';

class TwoDHistoryPage extends StatefulWidget {
  const TwoDHistoryPage({Key key, this.result, this.section}) : super(key: key);
  final String result;
  final String section;
  @override
  _TwoDHistoryPageState createState() => _TwoDHistoryPageState();
}

class _TwoDHistoryPageState extends State<TwoDHistoryPage> {
  final _thscaffoldKey = GlobalKey<ScaffoldState>();

  final LiveQuery liveQuery = LiveQuery();

  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('Live2dLog'));
  DateTime updatedTime = DateTime.now();
  List<Live2DLog> list = [];

  @override
  void initState() {
    super.initState();

    query = QueryBuilder<ParseObject>(ParseObject('Live2dLog'))
      ..whereEqualTo('section', widget.section);
    fetch();
  }

  Future<void> fetch() async {
    var response = await query.query();
    if (response.success) {
      list = [];
      for (var item in response.results) {
        Live2DLog model = Live2DLog(
          date: item['date'],
          result: item['result'],
          section: item['section'],
          set: item['set'],
          value: item['value'],
          isReference: item['isReference'],
        );
        list.add(model);
        // list.add(Live2DLog.fromJson(json.decode(item.toString())));
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      // if (widget.section == "10:30 AM" && list.isNotEmpty) {
      //   list.removeAt(list.length - 1);
      // }

      List<Live2DLog> tempList =
          list.where((item) => item.isReference).toList();
      if (tempList.isNotEmpty) {
        updatedTime = tempList.first.date;
      }
      //print(list);
      setState(() {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _thscaffoldKey,
      appBar: AppBar(
        title: const Text("2D History"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //   child: Text(
            //     widget.result,
            //     style: resultstyle,
            //   ),
            // ),

            // ***pyae
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: <Widget>[
                      Text(
                        widget.result,
                        style: resultstyle,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(130, 80, 0, 0),
                        child: IconButton(
                            color: Colors.grey,
                            icon: FaIcon(FontAwesomeIcons.questionCircle),
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
                  // Text(
                  //   widget.result,
                  //   style: resultstyle,
                  // ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 70),
                  //   child: IconButton(
                  //     color: Colors.grey,
                  //       icon: FaIcon(FontAwesomeIcons.questionCircle),
                  //       onPressed: () {
                  //         //print("Pressed");
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (BuildContext context) => const TwoDHelpPage(),
                  //           ),
                  //         );
                  //       }
                  //   ),
                  // ),
                ],
              ),
            ),
            // ***endpyae
            Container(
              margin: const EdgeInsets.only(top: 0, bottom: 5),
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 5),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check,
                    color: Color(0xFF20801C),
                    size: 25,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Updated: ${getDate(updatedTime)}",
                    style: GoogleFonts.roboto(
                        color: mainColor,
                        fontSize: 13,
                        fontStyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: list
                        .map((item) => Card(
                              elevation: 0,
                              color: item.isReference
                                  ? Colors.lightBlueAccent.withOpacity(0.3)
                                  : Colors.white,
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          item.date != null
                                              ? getTime(item.date.toString())
                                              : "Date",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                        item.set != null && item.set != "--"
                                            ? RichText(
                                                text: TextSpan(
                                                  text: item.set
                                                      .toString()
                                                      .substring(
                                                          0,
                                                          item.set
                                                                  .toString()
                                                                  .length -
                                                              1),
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: item.set
                                                          .toString()
                                                          .substring(
                                                              item.set
                                                                      .toString()
                                                                      .length -
                                                                  1,
                                                              item.set
                                                                  .toString()
                                                                  .length),
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Colors.amber),
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
                                                  text: item.value
                                                      .toString()
                                                      .substring(
                                                          0,
                                                          item.value
                                                                  .toString()
                                                                  .length -
                                                              4),
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 14.0,
                                                      color: Colors.black),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: item.value
                                                            .toString()
                                                            .substring(
                                                                item.value
                                                                        .toString()
                                                                        .length -
                                                                    4,
                                                                item.value
                                                                        .toString()
                                                                        .length -
                                                                    3),
                                                        style: GoogleFonts.roboto(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color:
                                                                Colors.amber)),
                                                    TextSpan(
                                                        text: item.value
                                                            .toString()
                                                            .substring(
                                                                item.value
                                                                        .toString()
                                                                        .length -
                                                                    3,
                                                                item.value
                                                                    .toString()
                                                                    .length),
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black)),
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
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getDate(DateTime date) {
    var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

  getTime(time) {
    var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    DateTime tempDate = formatter.parse(time);
    var dateFormat = DateFormat("h:mm:ss");
    return dateFormat.format(tempDate);
  }
}
