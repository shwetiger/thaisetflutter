// @dart=2.9
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static SharedPreferences _db;
  static Future<SharedPreferences> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  static initDb() async {
    _db = await SharedPreferences.getInstance();
    return _db;
  }

  static Future<bool> setData(String data, String keyName) async {
    var dbClient = await db;
    dbClient.setString(keyName, data);
    return true;
  }

  static Future<String> getData(String keyName) async {
    try {
      var dbClient = await db;
      return dbClient.getString(keyName);
    } catch (ex) {
      return null;
    }
  }

  // static Future<void> clearStorage() async {
  //   await _db.clear();
  // }


}
