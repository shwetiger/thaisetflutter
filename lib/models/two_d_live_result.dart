// @dart=2.9
class TwoDLiveResult {
  String section;
  String set;
  String value;
  String result;
  bool isManual;
  bool switchManual;
  String from;
  String to;
  String fromDateTime;
  String toDateTime;
  String toDisplayDateTime;
  bool isDone = false;
  bool isShowHistory =false;

  TwoDLiveResult(
      {this.section,
      this.set,
      this.value,
      this.result,
      this.isManual,
      this.switchManual,
      this.from,
      this.to,
      this.fromDateTime,
      this.toDateTime,
      this.toDisplayDateTime,
      this.isDone = false,
      this.isShowHistory = false});

  TwoDLiveResult.fromJson(Map<String, dynamic> json) {
    section = json['section'];
    set = json['set'];
    value = json['value'];
    result = json['result'];
    isManual = json['isManual'];
    switchManual = json['switchManual'];
    from = json['from'];
    to = json['to'];
    fromDateTime = json['fromDateTime'];
    toDateTime = json['toDateTime'];
    toDisplayDateTime = json['toDisplayDateTime'];
    isDone = json['isDone'];
    isShowHistory = json['isShowHistory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['section'] = section;
    data['set'] = set;
    data['value'] = value;
    data['result'] = result;
    data['isManual'] = isManual;
    data['switchManual'] = switchManual;
    data['from'] = from;
    data['to'] = to;
    data['fromDateTime'] = fromDateTime;
    data['toDateTime'] = toDateTime;
    data['toDisplayDateTime'] = toDisplayDateTime;
    data['isDone'] = isDone;
    data['isShowHistory'] = isShowHistory;
    return data;
  }
}
