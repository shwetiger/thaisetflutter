// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/holiday_model.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/providers/twod_provider.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({
    Key key,
  }) : super(key: key);

  @override
  _HolidayPage createState() => _HolidayPage();
}

class _HolidayPage extends State<HolidayPage>
    with SingleTickerProviderStateMixin {
  final _hscaffoldKey = GlobalKey<ScaffoldState>();
  List<HolidayModel> holidayList = [];
  bool isholidayList = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ///List<TowDModel> items=[];
  @override
  void initState() {
    super.initState();

    getHoliday();
  }

  Future<void> getHoliday() async {
    holidayList = await context.read<TwoDProvider>().getHoliday(context);
    holidayList.sort((a, b) => a.date.compareTo(b.date));
  }

  refresh() async {
    holidayList = await context.read<TwoDProvider>().getHoliday(context);
    _refreshController.refreshCompleted();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // holidayList = context.watch<TwoDProvider>().holidayLists;
    return Scaffold(
      key: _hscaffoldKey,
      appBar: AppBar(
        title: const Text("Holidays"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: context.watch<TwoDProvider>().isholidayLists
          ? const SpinKitChasingDots(color: mainColor, size: 50)
          : Container(
              // color: const Color(0xFFf4f2f2),
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              alignment: Alignment.center,
              child: (context.watch<TwoDProvider>().isholidayLists)
                  ? const Center(
                      child: SpinKitChasingDots(
                        color: mainColor,
                        size: 50.0,
                      ),
                    )
                  : (holidayList != null && holidayList.isNotEmpty)
                      ? GroupedListView<HolidayModel, String>(
                          elements: holidayList,
                          groupBy: (element) => getMonth(element.date),
                          // itemExtent: 80,
                          groupComparator: (value1, value2) =>
                              getSortMonth(value1)
                                  .compareTo(getSortMonth(value2)),
                          itemComparator: (item1, item2) => getMonth(item1.date)
                              .compareTo(getMonth(item2.date)),
                          shrinkWrap: true,
                          floatingHeader: false,
                          order: GroupedListOrder.ASC,
                          sort: false,
                          // useStickyGroupSeparators: true,

                          padding: const EdgeInsets.all(0),
                          groupSeparatorBuilder: (String value) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: Text(
                              value,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                          ),
                          //             itemBuilder: (c, element) {
                          // itemCount: holidayList.length,
                          itemBuilder: (context, element) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              child: Card(
                                // color: mainColor,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: const BorderSide(
                                      color: mainColor,
                                      width: 1,
                                      style: BorderStyle.solid),
                                ),
                                elevation: 2,

                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  child: element.date == null
                                      ? Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                element.description.trim() ??
                                                    " ",
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: mainColor,
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "(${getDayFormat(element.date)})",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: mainColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    element.description
                                                            .trim() ??
                                                        " ",
                                                    softWrap: true,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: mainColor,
                                                      fontSize: 14,
                                                      // fontWeight:FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("Please wait..."),
                        ),
            ),
    );
  }

  getDayFormat(DateTime date) {
    var date1 = DateFormat("dd-MM-yyyy").format(date);
    return date1;
  }

  getMonth(DateTime date) {
    var date1 = DateFormat("MMMM").format(date);
    return date1;
  }

  String getSortMonth(String date) {
    Map<String, String> map = {
      "January": "01",
      "February": "02",
      "March": "03",
      "April": "04",
      "May": "05",
      "June": "06",
      "July": "07",
      "August": "08",
      "September": "09",
      "October": "10",
      "November": "11",
      "December": "12"
    };
    var date1 = map[date];
    // var date1 = DateFormat("MM").format(date);
    return date1;
  }
}
