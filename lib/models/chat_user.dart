//@dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  Timestamp createdAt;
  String name;
  String id;
  String phoneNo;
  String imageUrl;
  String fcmtoken;

  ChatUser({
    this.createdAt,
    this.name,
    this.id,
    this.phoneNo,
    this.imageUrl,
    this.fcmtoken,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    name = json['name'];
    id = json['id'];
    phoneNo = json['phoneNo'];
    imageUrl = json['imageUrl'];
    fcmtoken = json['fcmtoken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['createdAt'] = createdAt;
    data['name'] = name;
    data['id'] = id;
    data['phoneNo'] = phoneNo;
    data['imageUrl'] = imageUrl;
    data['fcmtoken'] = fcmtoken;
    return data;
  }
}
