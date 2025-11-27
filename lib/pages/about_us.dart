import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  TextStyle style = const TextStyle(
    fontSize: 14,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
        centerTitle: true,
        backgroundColor: Color(0xFF1685a0),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Thai SET 2D is a real time live App for checking 2D results. The data are from Official Thai Stock Exchange https://www.set.or.th/. Set Index real-time data updated time :(Myanmar Time UTC +6:30 : 10:30 AM , 12:01 PM, 2:30 PM and 4:30 PM), and can also check detail for each section result data. It provides for every section : 2D results history and also the highlight details for every section results, 3D results history, API for developers, Live Chat room and Holidays.",
                style: style,
              ),
              Text(
                "Main Menu of Thai SET 2D App:",
                style: style,
              ),
              SizedBox(),
              Text(
                "1. Live Chat : To talk and to discuss 2D/3D tips with each other easily by looking at 2D Live.",
                style: style,
              ),
              Text(
                "2. 2D : To view 2D results history by daily and highlight history as details.",
                style: style,
              ),
              Text(
                "3. 3D : To view 3D results history by monthly.                                            ",
                style: style,
              ),
              Text(
                "4. Calendar : To get the information of 2D holidays for a year.                             ",
                style: style,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Sub menu buttons of Thai SET 2D App :",
                style: style,
              ),
              Text(
                "1. API for Developer : To provides daily Live set(index) API, result API  and history API document for developers that will make your Web and App more easily to connect with 2D live and result. ",
                style: style,
              ),
              Text(
                "2. Version : To check version update and to download if the updated version is available.",
                style: style,
              ),
              Text(
                "Remark : Data provided for educational purpose or personal use only, not intended for trading purpose.",
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
