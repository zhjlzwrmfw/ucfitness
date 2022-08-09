class CourseList {
  String code;
  Data data;

  CourseList({this.code, this.data});

  CourseList.fromJson(Map<String, dynamic> json) {
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
  String title;
  String cover;
  String describe;
  int expectCalorie;
  int during;
  int level;
  List<String> tags;
  int interactiveEquipment;
  String createTime;
  bool timing;
  int version;

  DataList(
      {this.id,
        this.title,
        this.cover,
        this.describe,
        this.expectCalorie,
        this.during,
        this.level,
        this.tags,
        this.interactiveEquipment,
        this.createTime,
        this.timing,
        this.version});

  DataList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    cover = json['cover'];
    describe = json['describe'];
    expectCalorie = json['expectCalorie'];
    during = json['during'];
    level = json['level'];
    tags = json['tags'].cast<String>();
    interactiveEquipment = json['interactiveEquipment'];
    createTime = json['createTime'];
    timing = json['timing'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['cover'] = this.cover;
    data['describe'] = this.describe;
    data['expectCalorie'] = this.expectCalorie;
    data['during'] = this.during;
    data['level'] = this.level;
    data['tags'] = this.tags;
    data['interactiveEquipment'] = this.interactiveEquipment;
    data['createTime'] = this.createTime;
    data['timing'] = this.timing;
    data['version'] = this.version;
    return data;
  }
}