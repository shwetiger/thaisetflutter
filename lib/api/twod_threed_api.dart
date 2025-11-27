// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:thai2dlive/data/data_key_name.dart';
import 'package:thai2dlive/data/database_helper.dart';
import 'package:thai2dlive/data/network_util.dart';
import 'package:thai2dlive/models/holiday_model.dart';
import 'package:thai2dlive/models/three_d_result.dart';
import 'package:thai2dlive/models/two_d_result.dart';

import '../models/two_d_modern_result.dart';

class TwoDThreeDApi {
  BuildContext context;
  TwoDThreeDApi(context);

  final NetworkUtil _netUtil = NetworkUtil();

  Future<List<TwoDResult>> getTwoDResult() async {
    List<TwoDResult> result = [];
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('TwoDWeeklyLiveResult'));

    var response = await query.query();
    print("successresponse>>>>" + response.toString());
    if (response.success) {
      if (response.results.isNotEmpty) {
        for (var item in response.results) {
          TwoDResult model = TwoDResult(
            date: item['date'],
            time1030: item['time_1030'],
            set1030: item['set_1030'],
            val1030: item['val_1030'],
            result1030: item['result_1030'],
          );
          result.add(model);
        }
        var data = jsonEncode(result.map((e) => e.toJson()).toList());
        DatabaseHelper.setData(data, DataKeyValue.twoDResultList);
      }
    } else {}
    print("Result>>>>" + result.toString());
    return result;
  }

  Future<List<ThreeDResult>> get3DResult() async {
    List<ThreeDResult> result = [];
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('ThreeDResult'));
    var response = await query.query();
    if (response.success) {
      if (response.results.isNotEmpty) {
        for (var item in response.results) {
          ThreeDResult model = ThreeDResult(
            date: item['date'],
            number: item['number'],
          );
          result.add(model);
        }
        var data = jsonEncode(result.map((e) => e.toJson()).toList());
        DatabaseHelper.setData(data, DataKeyValue.threeDResultList);
      }
    } else {}
    return result;
  }

  Future<List<HolidayModel>> getHoliday() async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('Holidays'));
    List<HolidayModel> result = [];
    var response = await query.query();
    if (response.success) {
      if (response.results.isNotEmpty) {
        for (var item in response.results) {
          HolidayModel model = HolidayModel(
            date: item['date'],
            description: item['description'],
          );
          result.add(model);
        }

        var data = jsonEncode(result.map((e) => e.toJson()).toList());
        DatabaseHelper.setData(data, DataKeyValue.holidayList);
      }
    } else {}

    return result;
  }

  // Future<String> getDateTime() async {
  //   var url = "$backendUrl/value/getDateTime";
  //   // var _header = await getHeadersWithOutToken();
  //   var _header = null;
  //   http.Response response = await _netUtil.get(context, url, _header);
  //   if (response != null) {
  //     if (response.statusCode == 200) {
  //       // var data = response.body.toString(); //["data"];
  //       var obj = json.decode(response.body); //["d
  //       var dataObj = OnlineDateTime.fromJson(obj);
  //       return dataObj.utcDatetime;
  //     }
  //   }
  //   return null;
  // }

  Future<DateTime> getDateTime(BuildContext context) async {
    var url = "https://www.microsoft.com";

    http.Response response = await _netUtil.get(context, url, null);
    if (response != null) {
      if (response.statusCode == 200) {
        DateTime date = getDateFromStr(response.headers['date'])
            .add(const Duration(hours: 6, minutes: 30));
        return date;
      }
    }
    return DateTime.now();
  }

  Future<TwoDModernNumberModel> getTwodModernNumber(
      BuildContext context, url) async {
    var liveDataUrl =
        url; //"https://luke.2dboss.com/api/luke/twod-result-live";
    print("liveDataUrl>>>>" + liveDataUrl.toString());
    TwoDModernNumberModel result;
    http.Response response = await _netUtil.get(context, liveDataUrl, null);
    print("LivelinkResponse>>>>" + response.body.toString());
    if (response != null) {
      if (response.body != null && response.body != "") {
        var obj = json.decode(response.body); //["data"];
        print("objresult>>>>" + obj.toString());
        if (obj != null && obj["result"] == 1 && obj["message"] == "success") {
          result = TwoDModernNumberModel.fromJson(obj["data"]);
          return result;
        }
      }
      return null;
    }
    return null;
  }

  DateTime getDateFromStr(String str) {
    return DateFormat('EEE, d MMM yyyy hh:mm:ss').parse(str);
  }
}
