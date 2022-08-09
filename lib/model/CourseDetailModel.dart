class CourseDetailModel {
  String code;
  List<Data> data;

  CourseDetailModel({this.code, this.data});

  CourseDetailModel.fromJson(Map<String, dynamic> json) {
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
  int actionId;
  int actionType;
  String video;
  String cover;
  String actionName;
  String actionVoice;
  String actionIntroduce;
  String actionIntroduceVoice;
  int targetAmount;
  int during;

  Data(
      {this.actionId,
        this.actionType,
        this.video,
        this.cover,
        this.actionName,
        this.actionVoice,
        this.actionIntroduce,
        this.actionIntroduceVoice,
        this.targetAmount,
        this.during});

  Data.fromJson(Map<String, dynamic> json) {
    actionId = json['actionId'];
    actionType = json['actionType'];
    video = json['video'];
    cover = json['cover'];
    actionName = json['actionName'];
    actionVoice = json['actionVoice'];
    actionIntroduce = json['actionIntroduce'];
    actionIntroduceVoice = json['actionIntroduceVoice'];
    targetAmount = json['targetAmount'];
    during = json['during'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['actionId'] = this.actionId;
    data['actionType'] = this.actionType;
    data['video'] = this.video;
    data['cover'] = this.cover;
    data['actionName'] = this.actionName;
    data['actionVoice'] = this.actionVoice;
    data['actionIntroduce'] = this.actionIntroduce;
    data['actionIntroduceVoice'] = this.actionIntroduceVoice;
    data['targetAmount'] = this.targetAmount;
    data['during'] = this.during;
    return data;
  }
}