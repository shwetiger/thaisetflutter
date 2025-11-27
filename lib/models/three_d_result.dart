// @dart=2.9
class ThreeDResult {
  DateTime date;
  String number;

  ThreeDResult({this.date, this.number});

  ThreeDResult.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(json['date']);
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date.toString();
    data['number'] = number;
    return data;
  }
}
