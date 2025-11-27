//@dart=2.9

class HolidayModel {
  String description;
  DateTime date;

  HolidayModel({
    this.date,
    this.description,
  });

  HolidayModel.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(json['date']);
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date.toString();
    data['description'] = description;
    return data;
  }
}
