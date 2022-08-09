class StatisticsData {
  String code;
  List<Data> data;

  StatisticsData({this.code, this.data});

  StatisticsData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int sportCount;
  double calorie;
  int duringTime;
  double sportStrength;
  String startTime;
  String endTime;

  Data(
      {this.sportCount,
        this.calorie,
        this.duringTime,
        this.sportStrength,
        this.startTime,
        this.endTime});

  Data.fromJson(Map<String, dynamic> json) {
    sportCount = json['sportCount'];
    calorie = json['calorie'];
    duringTime = json['duringTime'];
    sportStrength = json['sportStrength'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sportCount'] = this.sportCount;
    data['calorie'] = this.calorie;
    data['duringTime'] = this.duringTime;
    data['sportStrength'] = this.sportStrength;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    return data;
  }
}