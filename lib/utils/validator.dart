// @dart=2.9
import 'package:flutter/material.dart';

class Validator {
  static String verifyCode(
      BuildContext context, String value, bool isRequired) {
    if (isRequired) {
      if (value.isEmpty) {
        return "Code is Required!";
      }
    }

    if (value.isEmpty) {
      return "Enter 6-digit verification code";
    } else if (value.length != 6) {
      return "The verification code must have 6 digits.";
    }

    return null;
  }

  // static String registerPhone(
  //     BuildContext context, String value, bool isRequired) {
  //   // String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  //   // RegExp regExp =  RegExp(patttern);

  //   if (isRequired) {
  //     if (value.isEmpty) {
  //       return "Phone Number is Required!";
  //     }
  //   }
  //   RegExp phoneExp = RegExp(r'^09\d{6,9}$');

  //   if (value.isEmpty) {
  //     return "Enter mobile number";
  //   } else if (!phoneExp.hasMatch(value)) {
  //     return "Enter valid mobile number";
  //   }

  //   return null;
  // }

  static String registerPhone(
      BuildContext context, String value, String countryCode, bool isRequired) {
    RegExp phoneExp =
        RegExp(r'(^09\d{6,9}|^08\d{6,9}|^06\d{6,9}|^1[0-9]{10})$');

    RegExp mmPhoneExp = RegExp(r'^09\d{6,9}$');
    RegExp sgPhoneExp = RegExp(r'^(6|8|9)\d{7}$');
    RegExp chPhoneExp = RegExp(
        r'^1(?:3(?:4[^9\D]|[5-9]\d)|5[^3-6\D]\d|7[28]\d|8[23478]\d|9[578]\d)\d{7}$');
    RegExp mlPhoneExp = RegExp(r'^(1)[0-46-9]*[0-9]{7,8}$');

    RegExp thPhoneExp = RegExp(r'^9\d{6,9}|^8\d{6,9}|^6\d{6,9}$');
    RegExp regExp = RegExp(r'^09\d{6,9}$');
    switch (countryCode) {
      case "+95":
        regExp = mmPhoneExp;
        break;
      case "+65":
        regExp = sgPhoneExp;
        break;
      case "+60":
        regExp = mlPhoneExp;
        break;
      case "+66":
        regExp = thPhoneExp;
        break;
      case "+86":
        regExp = chPhoneExp;
        break;
    }

    if (isRequired) {
      if (value.isEmpty) {
        return "Phone Number is Required!";
      }
    }

    if (value.isEmpty) {
      return "Enter mobile number";
    } else if (!regExp.hasMatch(value)) {
      return "Enter valid mobile number";
    }

    return null;
  }

  static String userName(
      BuildContext context, String value, String fileName, bool isRequired) {
    if (isRequired) {
      if (value.isEmpty) {
        return "User Name is Required!";
      }
    }
    if(value.contains("2D3D") || value.contains("2d3d") || value.contains("2D 3D")
        || value.contains("2d 3d") || value.contains("2D") || value.contains("3D")
        || value.contains("2d") || value.contains("3d")
        || value.contains("2D3d") || value.contains("2d3D")  || value.contains("2D 3d") || value.contains("2d 3D")
        || value.contains("3d2D") || value.contains("3D2d")  || value.contains("3d 2D") || value.contains("3D 2d")
    ){
      String tip = "User Name is not allowed 2D3D!";
      return tip;
    }
    if (value.length < 4) {
      String tip = "User Name must have at least 4 characters!";
      return tip;
    }
    // RegExp phoneExp = RegExp(r'^[A-Za-z0-9]*$'); //english and number only
    // if (!phoneExp.hasMatch(value)) {
    //   return "Account is not correct";
    //   // Tran.of(context).text("userInvaild");
    // }
    return null;
  }
}
