//@dart=2.9

class NotificationPageObj {
  String title;
  String currentdate;
  String fortime;
  String number;
  String type;
  String body;
  int id;
  String status;
  String clickAction;

  NotificationPageObj({
    this.id,
    this.title,
    this.type,
    this.body,
    this.clickAction,
    this.currentdate,
    this.fortime,
    this.number,
    this.status,
  });

  NotificationPageObj.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    body = json['body'];
    clickAction = json['click_action'];
    currentdate = json['currentdate'];
    fortime = json['fortime'];
    number = json['number'];
    status = json['status'] == null || json['status'] == "null"
        ? "0"
        : json['status'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['type'] = type;
    data['body'] = body;
    data['click_action'] = clickAction;
    data['currentdate'] = currentdate;
    data['fortime'] = fortime;
    data['number'] = number;
    data['status'] = status;
    return data;
  }
}
