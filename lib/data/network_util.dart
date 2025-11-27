// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thai2dlive/utils/message_handel.dart';

class NetworkUtil {
  static final NetworkUtil _instance = NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;
  Future<http.Response> get(
      BuildContext context, String url, Map<String, String> headers) async {
    try {
      return http
          .get(Uri.parse(url), headers: headers)
          .then((http.Response response) async {
        return handleResponse(context, response, url);
      }).catchError((onError) async {
        try {
          MessageHandel.showMessageDuration(
              context, "Tip", "Check your internet connection or close VPN", 2);
          // ignore: empty_catches
        } catch (e) {}
        //"Check your internet connection or close VPN"
        return null;
      });
    } catch (ex) {
      MessageHandel.showError(
          context, "Tip", "Check your internet connection or close VPN");
      return null;
    }
  }

  Future<http.Response> handleResponse(
      BuildContext context, http.Response response, String url) async {
    final int statusCode = response.statusCode;

    if (response.statusCode == 410) {
      var body = json.decode(response.body);
      if (body != null && body["Message"] != null) {
        MessageHandel.showError(context, "Tip", body["Message"]);
      }
      return response;
    }
    if (statusCode == 401 || statusCode == 304 || statusCode == 416) {
      return response;
    }

    if (statusCode == 404) {
      MessageHandel.showError(context, "Tip", "Not found");
      return response;
    }

    if (statusCode == 500) {
      MessageHandel.showError(context, "Tip", "Internal server error");

      return response;
    }
    if (statusCode == 400) {
      return response;
    }
    if (statusCode != 200) {
      var body = json.decode(response.body);
      String msg = body["error_description"];
      msg = msg == null || msg == "" ? body["Message"] : msg;
      if (msg != null && msg.isNotEmpty) {
        MessageHandel.showError(context, "Tip", msg);
        return null;
      }
      MessageHandel.showError(context, "Tip", "System Data Error");
      return response;
    }
    return response;
  }
}
