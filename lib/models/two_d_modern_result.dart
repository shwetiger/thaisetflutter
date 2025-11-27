// @dart=2.9
class TwoDModernNumberModel {
  String set1200;
  String val1200;
  String set430;
  String val430;
  String result1200;
  String result430;
  String internet930;
  String modern930;
  String internet200;
  String modern200;
  String date;
  String time1200;
  String time430;
  String live;
  String liveSet; //XXX MH string to double 2023-03-16
  String liveVal;
  String status1200;
  String status430;
  String lastDate;
  String isCloseDay;
  String currentDate;
  String currentTime;

  TwoDModernNumberModel(
      {this.set1200,
      this.val1200,
      this.set430,
      this.val430,
      this.result1200,
      this.result430,
      this.internet930,
      this.modern930,
      this.internet200,
      this.modern200,
      this.date,
      this.time1200,
      this.time430,
      this.live,
      this.liveSet,
      this.liveVal,
      this.status1200,
      this.status430,
      this.lastDate,
      this.isCloseDay,
      this.currentDate,
      this.currentTime});

  TwoDModernNumberModel.fromJson(Map<String, dynamic> json) {
    set1200 = json['set_1200'];
    val1200 = json['val_1200'];
    set430 = json['set_430'];
    val430 = json['val_430'];
    result1200 = json['result_1200'].toString();
    result430 = json['result_430'].toString();
    internet930 = json['internet_930'];
    print("Resultset1200" + set1200);
    modern930 = json['modern_930'];
    internet200 = json['internet_200'];
    modern200 = json['modern_200'];
    print("Modern930>>>" + modern930);
    date = json['date'];
    time1200 = json['time_1200'];
    time430 = json['time_430'];
    live = json['live'];
    liveSet = json['live_set'];
    print("liveSet>>>" + liveSet);
    liveVal = json['live_val'];
    status1200 = json['status_1200'];
    status430 = json['status_430'];

    lastDate = json['last_date'];
    isCloseDay = json['is_close_day'].toString();
    currentDate = json['current_date'];
    currentTime = json['current_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['set_1200'] = this.set1200;
    data['val_1200'] = this.val1200;
    data['set_430'] = this.set430;
    data['val_430'] = this.val430;
    data['result_1200'] = this.result1200;
    data['result_430'] = this.result430;
    data['internet_930'] = this.internet930;
    data['modern_930'] = this.modern930;
    data['internet_200'] = this.internet200;
    data['modern_200'] = this.modern200;
    data['date'] = this.date;
    data['time_1200'] = this.time1200;
    data['time_430'] = this.time430;
    data['live'] = this.live;
    data['live_set'] = this.liveSet;
    data['live_val'] = this.liveVal;
    data['status_1200'] = this.status1200;
    data['status_430'] = this.status430;
    data['last_date'] = this.lastDate;
    data['is_close_day'] = this.isCloseDay;
    data['current_date'] = this.currentDate;
    data['current_time'] = this.currentTime;
    return data;
  }
}
