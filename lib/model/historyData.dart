class HistoryData {
  String code;
  Data data;

  HistoryData({this.code, this.data});

  HistoryData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<DataList> dataList;
  int currentPageNum;
  int totalElements;
  int totalPages;

  Data(
      {this.dataList,
        this.currentPageNum,
        this.totalElements,
        this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['dataList'] != null) {
      dataList = new List<DataList>();
      json['dataList'].forEach((v) {
        dataList.add(new DataList.fromJson(v));
      });
    }
    currentPageNum = json['currentPageNum'];
    totalElements = json['totalElements'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dataList != null) {
      data['dataList'] = this.dataList.map((v) => v.toJson()).toList();
    }
    data['currentPageNum'] = this.currentPageNum;
    data['totalElements'] = this.totalElements;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class DataList {
  int id;
  int userId;
  int count;
  double calories;
  String startTime;
  int duringTime;
  int mode;
  int equipmentType;

  DataList(
      {this.id,
        this.userId,
        this.count,
        this.calories,
        this.startTime,
        this.duringTime,
        this.mode,
        this.equipmentType});

  DataList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    count = json['count'];
    calories = json['calories'];
    startTime = json['startTime'];
    duringTime = json['duringTime'];
    mode = json['mode'];
    equipmentType = json['equipmentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['count'] = this.count;
    data['calories'] = this.calories;
    data['startTime'] = this.startTime;
    data['duringTime'] = this.duringTime;
    data['mode'] = this.mode;
    data['equipmentType'] = this.equipmentType;
    return data;
  }
}