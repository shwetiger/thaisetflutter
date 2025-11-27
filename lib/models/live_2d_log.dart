//@dart=2.9
class Live2DLog {
  String set;
  String section;
  DateTime date;
  String value;
  String result;
  bool isReference = false;

  Live2DLog(
      {this.set,
      this.section,
      this.date,
      this.value,
      this.result,
      this.isReference});

  Live2DLog.fromJson(Map<String, dynamic> json) {
    set = json['set'];
    section = json['section'];
    date = json['date'];
    value = json['value'];
    result = json['result'];
    isReference = json['isReference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['set'] = set;
    data['section'] = section;
    data['date'] = date;
    data['value'] = value;
    data['result'] = result;
    data['isReference'] = isReference;
    return data;
  }
}
