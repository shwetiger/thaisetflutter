// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/three_d_result.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/providers/twod_provider.dart';

class ThreeDPage extends StatefulWidget {
  const ThreeDPage({Key key}) : super(key: key);

  @override
  _ThreeDPageState createState() => _ThreeDPageState();
}

class _ThreeDPageState extends State<ThreeDPage>
    with SingleTickerProviderStateMixin {
  Color borderColor = Colors.grey.withOpacity(0.1);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<ThreeDResult> items = [];

  @override
  void initState() {
    super.initState();
    get3DResults();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> get3DResults() async {
    items = await context.read<TwoDProvider>().getThreeDResult(context);
    items.sort((a, b) => b.date.compareTo(a.date));
  }

  refresh() async {
    items = await context.read<TwoDProvider>().getThreeDResult(context);
    items.sort((a, b) => b.date.compareTo(a.date));
    _refreshController.refreshCompleted();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Results"),
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
            : (items != null && items.isNotEmpty)
                ? Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView(
                      children: items
                          .map(
                            (item) => Card(
                              margin: const EdgeInsets.only(
                                  top: 0, bottom: 8, right: 16, left: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, bottom: 10.0),
                                          child: Text(
                                            "Date",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: mainColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          "3D",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: mainColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getDateFormat(item.date),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: mainColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          item.number.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.yellow[700],
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList()
                          .cast<Widget>(),
                    ),
                  )
                : const Center(
                    child: Text("Please wait..."),
                  ),
      ),
    );
  }

  String getDateFormat(DateTime date) {
    var date1 = DateFormat("dd-MM-yyyy").format(date);
    return date1;
  }
}
