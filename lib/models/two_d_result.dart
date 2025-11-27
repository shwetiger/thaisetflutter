//@dart=2.9

class TwoDResult {
  String time1030;
  String set1030;
  String val1030;
  String result1030;
  DateTime date;

  TwoDResult({
    this.set1030,
    this.val1030,
    this.result1030,
    this.time1030,
    this.date,
  });

  TwoDResult.fromJson(Map<String, dynamic> json) {
    time1030 = json['time_1030'];
    set1030 = json['set_1030'];
    val1030 = json['val_1030'];
    result1030 = json['result_1030'];
    date = DateTime.parse(json['date']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time_1030'] = time1030;
    data['set1030'] = set1030;
    data['val1030'] = val1030;
    data['result1030'] = result1030;
    data['date'] = date.toString();
    return data;
  }
}
