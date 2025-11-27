// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/live_2d_log.dart';

class TwoDHelpPage extends StatefulWidget {
  const TwoDHelpPage({
    Key key,
  }) : super(key: key);

  // const TwoDHelpPage({Key key, this.result, this.section}) : super(key: key);
  // final String result;
  // final String section;
  @override
  _TwoDHelpPageState createState() => _TwoDHelpPageState();
}

class _TwoDHelpPageState extends State<TwoDHelpPage> {
  final _thscaffoldKey = GlobalKey<ScaffoldState>();

  final LiveQuery liveQuery = LiveQuery();

  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('Live2dLog'));
  DateTime updatedTime = DateTime.now();
  List<Live2DLog> list = [];

  @override
  void initState() {
    super.initState();

    // query = QueryBuilder<ParseObject>(ParseObject('Live2dLog'))
    //   ..whereEqualTo('section', widget.section);
    // fetch();
  }

  // Future<void> fetch() async {
  //   var response = await query.query();
  //   if (response.success) {
  //     list = [];
  //     for (var item in response.results) {
  //       Live2DLog model = Live2DLog(
  //         date: item['date'],
  //         result: item['result'],
  //         section: item['section'],
  //         set: item['set'],
  //         value: item['value'],
  //         isReference: item['isReference'],
  //       );
  //       list.add(model);
  //
  //       // list.add(Live2DLog.fromJson(json.decode(item.toString())));
  //     }
  //     list.sort((a, b) => b.date.compareTo(a.date));
  //     if (widget.section == "10:30 AM" && list.isNotEmpty) {
  //       list.removeAt(list.length - 1);
  //     }
  //
  //     List<Live2DLog> tempList =
  //         list.where((item) => item.isReference).toList();
  //     if (tempList.isNotEmpty) {
  //       updatedTime = tempList.first.date;
  //     }
  //
  //     setState(() {});
  //   } else {}
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _thscaffoldKey,
      appBar: AppBar(
        title: const Text("Help"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      'All official data are derived from Stock Exchange of Thailand (SET).',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: mainColor),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      "assets/help-1.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      'How are 2D numbers derived from the SET index?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: mainColor),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      "assets/help-2.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
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
