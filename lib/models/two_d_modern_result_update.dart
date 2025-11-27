// @dart=2.9
class TwoDModernNumberUpdateModel {
  String internet;
  String modern;
  String internet230;
  String modern230;

  TwoDModernNumberUpdateModel(
      {this.internet, this.modern, this.internet230, this.modern230});

  TwoDModernNumberUpdateModel.fromJson(Map<String, dynamic> json) {
    internet = json['internet'];
    modern = json['modern'];
    internet230 = json['internet_230'];
    modern230 = json['modern_230'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['internet'] = this.internet;
    data['modern'] = this.modern;
    data['internet_230'] = this.internet230;
    data['modern_230'] = this.modern230;
    return data;
  }
}
