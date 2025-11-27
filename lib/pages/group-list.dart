// @dart=2.9

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/data/database_helper.dart';
import 'package:thai2dlive/models/chat_msg.dart';
import 'package:thai2dlive/models/chat_user.dart';
import 'package:thai2dlive/models/two_d_live_result.dart';
import 'package:thai2dlive/pages/profile_edit.dart';
import 'package:thai2dlive/pages/twod_page.dart';
import 'package:provider/provider.dart';
import 'package:thai2dlive/pages/user_photo.dart';
import 'package:thai2dlive/providers/login_provider.dart';
import 'package:thai2dlive/providers/twod_provider.dart';

import 'user_ph_login.dart';
class GroupListViewDemo extends StatefulWidget {
  @override
  _GroupListViewDemoState createState() => _GroupListViewDemoState();
}

class _GroupListViewDemoState extends State<GroupListViewDemo> {
  List _elements = [
    {'topicName': 'GridView.count', 'group': 'GridView Type'},
    {'topicName': 'GridView.builder', 'group': 'GridView Type'},
    {'topicName': 'GridView.custom', 'group': 'GridView Type'},
    {'topicName': 'GridView.extent', 'group': 'GridView Type'},
    {'topicName': 'ListView.builder', 'group': 'ListView Type'},
    {'topicName': 'StatefulWidget', 'group': 'Type of Widget'},
    {'topicName': 'ListView', 'group': 'ListView Type'},
    {'topicName': 'ListView.separated', 'group': 'ListView Type'},
    {'topicName': 'ListView.custom', 'group': 'ListView Type'},
    {'topicName': 'StatelessWidget', 'group': 'Type of Widget'},
  ];

  @override
  Widget build(BuildContext context) {
    return GroupedListView<dynamic, String>(
      elements: _elements,
      groupBy: (element) => element['group'],
      groupComparator: (value1,
          value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) =>
          item1['topicName'].compareTo(item2['topicName']),
      order: GroupedListOrder.DESC,
      // useStickyGroupSeparators: true,
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
      itemBuilder: (c, element) {
        return Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0,
              vertical: 6.0),
          child: Container(
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0,
                  vertical: 10.0),
              //leading: Icon(Icons.account_circle),
              title: Text(
                element['topicName'],
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );

  }
}