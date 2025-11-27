//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/two_d_result.dart';
import 'package:thai2dlive/providers/twod_provider.dart';

class TwoDResultPage extends StatefulWidget {
  const TwoDResultPage({Key key}) : super(key: key);

  @override
  _TwoDResultPage createState() => _TwoDResultPage();
}

class _TwoDResultPage extends State<TwoDResultPage> {
  final _trscaffoldKey = GlobalKey<ScaffoldState>();
  List<TwoDResult> twodLists = [];
  String isFirebase = "";
  bool back4appLoading = false;
  DateFormat dfmt = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    get2DResults();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> get2DResults() async {
    twodLists = await context.read<TwoDProvider>().getTwoDResult(context);
  }

  refresh() async {
    twodLists = await context.read<TwoDProvider>().getTwoDResult(context);
    _refreshController.refreshCompleted();
    setState(() {});
  }

  getDay(date) {
    DateTime tempDate = DateFormat("dd/MM/yyyy").parse(date);
    var result1 = DateFormat('dd-MM-yyyy').format(tempDate);
    var result = result1 + "  " + DateFormat('EEEE').format(tempDate);
    return result;
  }

  TextStyle labelStyle = const TextStyle(
    color: Colors.grey,
    // fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  TextStyle valueStyle = const TextStyle(
    color: mainColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  TextStyle resultStyle = TextStyle(
    color: Colors.yellow[700],
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _trscaffoldKey,
      appBar: AppBar(
        title: const Text("2D Results"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        header: const WaterDropHeader(
          waterDropColor: mainColor,
        ),
        onRefresh: refresh,
        child: (context.watch<TwoDProvider>().istwoDResultLists)
            ? const Center(
                child: SpinKitChasingDots(
                  color: mainColor,
                  size: 50.0,
                ),
              )
            : (twodLists != null && twodLists.isNotEmpty)
                ? Container(
                    margin: const EdgeInsets.only(
                      left: 8,
                      top: 0,
                      right: 8,
                      bottom: 8,
                    ),
                    child: _buildGroupListView(twodLists))
                : const Center(
                    child: Text("Please wait..."),
                  ),
      ),
    );
  }

  DateTime getSectionTime(String time) {
    // print(time);
    if (time != "" && time != null && time != "null") {
      return DateFormat("hh:mm a").parse(time);
    } else {
      return DateTime.now();
    }
  }

  Widget _buildGroupListView(List<TwoDResult> twodLists) {
    return GroupedListView<TwoDResult, String>(
      elements: twodLists,
      groupBy: (element) => getDate(element.date),
      itemComparator: (e1, e2) =>
          getSectionTime(e1.time1030).compareTo(getSectionTime(e2.time1030)),
      groupComparator: (value1, value2) =>
          dfmt.parse(value2).compareTo(dfmt.parse(value1)),
      shrinkWrap: true,
      // order: GroupedListOrder.DESC,
      sort: true,
      useStickyGroupSeparators: true,
      padding: const EdgeInsets.only(bottom: 50),
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
        child: Text(
          value,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
      ),
      itemBuilder: (c, element) {
        // return Card(
        //     elevation: 20,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10.0),
        //     ),
        //     margin: const EdgeInsets.only(top: 0, bottom: 5, right: 8, left: 8),
        //     child: Column(
        //       children: [
        //         _buildResult(element.time1030, element.set1030, element.val1030,
        //             element.result1030),
        //         getDivider(context),
        //         const SizedBox(
        //           height: 50,
        //         )
        //       ],
        //     ));

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.only(top: 0, bottom: 5, right: 8, left: 8),
          child: _buildResult(element.time1030, element.set1030,
              element.val1030, element.result1030),
        );
      },
      // itemCount: holidayList.length,
    );
  }

  Widget getDivider(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      height: 1,
      width: 0.8 * MediaQuery.of(context).size.width,
    );
  }

  Widget _buildResult(String section, String set, String val, String result) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  section ?? " ",
                  textAlign: TextAlign.center,
                  style: valueStyle,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Set", style: labelStyle),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      set ?? " ",
                      style: valueStyle,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Value", style: labelStyle),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      val ?? " ",
                      style: valueStyle,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("2D", style: labelStyle),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      result ?? " ",
                      style: resultStyle,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getDate(DateTime date) {
    return dfmt.format(date);
  }
}
