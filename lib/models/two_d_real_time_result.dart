// @dart=2.9
class TwoDRealTimeResult {
  String set;
  String value;
  String result;
  String date;

  TwoDRealTimeResult(
      {

      this.set,
      this.value,
      this.result,
      this.date,
     });

  TwoDRealTimeResult.fromJson(Map<String, dynamic> json) {

    set = json['set'];
    value = json['value'];
    result = json['result'];
    date = json['date'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['set'] = set;
    data['value'] = value;
    data['result'] = result;
    data['date'] = date;

    return data;
  }
}
