// @dart=2.9
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thai2dlive/api/twod_threed_api.dart';
import 'package:thai2dlive/data/data_key_name.dart';
import 'package:thai2dlive/data/database_helper.dart';
import 'package:thai2dlive/models/holiday_model.dart';
import 'package:thai2dlive/models/three_d_result.dart';
import 'package:thai2dlive/models/two_d_result.dart';

import '../models/two_d_modern_result.dart';

class TwoDProvider with ChangeNotifier, DiagnosticableTreeMixin {
  // TwoDNumberModel _twodNumberModel;
  TwoDThreeDApi _api;
  final bool _isPosting = false;
  bool get isPosting => _isPosting;
  // TwoDNumberModel get twodNumber => _twodNumberModel;

  List<TwoDResult> _twoDLists;
  List<TwoDResult> get twoDLists => _twoDLists;

  bool _istwoDResultLists = false;
  bool get istwoDResultLists => _istwoDResultLists;

  List<ThreeDResult> _threeDLists;
  List<ThreeDResult> get threeDLists => _threeDLists;

  bool _isthreeDResultLists = false;
  bool get isthreeDResultLists => _isthreeDResultLists;

  bool _isLoadingLastResult = true;
  bool get isLoadingLastResult => _isLoadingLastResult;

  Duration _duration;
  Duration get duration => _duration;

  List<HolidayModel> _holidayLists = [];
  List<HolidayModel> get holidayLists => _holidayLists;

  bool _isholidayLists = false;
  bool get isholidayLists => _isholidayLists;

  HolidayModel _holiday;
  HolidayModel get holiday => _holiday;

  bool _isHoliday = false;
  bool get isHoliday => _isHoliday;

  Future<List<TwoDResult>> getTwoDResult(BuildContext context) async {
    _istwoDResultLists = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(DataKeyValue.twoDResultList);
    if (rawData != null && rawData != "") {
      _twoDLists = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _twoDLists.add(TwoDResult.fromJson(item));
      }
      _istwoDResultLists = false;
      notifyListeners();
    }
    _api = TwoDThreeDApi(context);
    _twoDLists = await _api.getTwoDResult();
    print("Twodresultlist>>>>" + _twoDLists.toString());
    _istwoDResultLists = false;
    notifyListeners();
    return _twoDLists;
  }

  Future<List<ThreeDResult>> getThreeDResult(BuildContext context) async {
    _isthreeDResultLists = true;
    // notifyListeners();
    var rawData = await DatabaseHelper.getData(DataKeyValue.threeDResultList);
    if (rawData != null && rawData != "") {
      _threeDLists = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _threeDLists.add(ThreeDResult.fromJson(item));
      }
      _isthreeDResultLists = false;
      notifyListeners();
    }
    _api = TwoDThreeDApi(context);
    _threeDLists = await _api.get3DResult();
    _isthreeDResultLists = false;
    notifyListeners();
    return _threeDLists;
  }

  Future<List<HolidayModel>> getHoliday(BuildContext context) async {
    _isholidayLists = true;
    // notifyListeners();

    var rawData = await DatabaseHelper.getData(DataKeyValue.holidayList);
    if (rawData != null && rawData != "") {
      _holidayLists = [];
      var obj = json.decode(rawData);
      for (var item in obj) {
        _holidayLists.add(HolidayModel.fromJson(item));
      }
      _isholidayLists = false;
      notifyListeners();
    }
    _api = TwoDThreeDApi(context);
    _holidayLists = await _api.getHoliday();

    _isholidayLists = false;
    notifyListeners();
    return _holidayLists;
  }

  Future<HolidayModel> checkTdyHoliday(
    BuildContext context,
  ) async {
    _api = TwoDThreeDApi(context);
    _holidayLists = await _api.getHoliday();
    DateTime myDate = await _api.getDateTime(context);

    if (myDate != null) {
      var currentDate = DateFormat('yyyy-MM-dd').format(myDate);

      List<HolidayModel> holidayList = _holidayLists.where((e) {
        String edate = DateFormat('yyyy-MM-dd').format(e.date);
        return edate == currentDate;
      }).toList();
      // List<HolidayModel> holidayList = _holidayLists
      //     .where((e) => e.date.split("T")[0].toString() == currentDate)
      //     .toList();

      if (holidayList.isNotEmpty) {
        _holiday = holidayList.first;
        notifyListeners();
        _isHoliday = true;
        notifyListeners();
        return _holiday;
      }
    }
    notifyListeners();
    return null;
  }
}
