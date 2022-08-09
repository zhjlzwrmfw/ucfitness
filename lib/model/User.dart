class UserInfos {
  String code;
  Data data;

  UserInfos({this.code, this.data});

  UserInfos.fromJson(Map<String, dynamic> json) {
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
  UserInfo userInfo;
  List<ThirdPartInfos> thirdPartInfos;

  Data({this.userInfo, this.thirdPartInfos});

  Data.fromJson(Map<String, dynamic> json) {
    userInfo = json['userInfo'] != null
        ? new UserInfo.fromJson(json['userInfo'])
        : null;
    if (json['thirdPartInfos'] != null) {
      thirdPartInfos = new List<ThirdPartInfos>();
      json['thirdPartInfos'].forEach((v) {
        thirdPartInfos.add(new ThirdPartInfos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo.toJson();
    }
    if (this.thirdPartInfos != null) {
      data['thirdPartInfos'] =
          this.thirdPartInfos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserInfo {
  int id;
  String nickName;
  bool sex;
  String birthday;
  int height;
  int weight;
  String headImage;
  String mailAddress;
  String phoneNumber;
  String phoneArea;
  bool disabled;

  UserInfo(
      {this.id,
        this.nickName,
        this.sex,
        this.birthday,
        this.height,
        this.weight,
        this.headImage,
        this.mailAddress,
        this.phoneNumber,
        this.phoneArea,
        this.disabled});

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nickName'];
    sex = json['sex'];
    birthday = json['birthday'];
    height = json['height'];
    weight = json['weight'];
    headImage = json['headImage'];
    mailAddress = json['mailAddress'];
    phoneNumber = json['phoneNumber'];
    phoneArea = json['phoneArea'];
    disabled = json['disabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nickName'] = this.nickName;
    data['sex'] = this.sex;
    data['birthday'] = this.birthday;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['headImage'] = this.headImage;
    data['mailAddress'] = this.mailAddress;
    data['phoneNumber'] = this.phoneNumber;
    data['phoneArea'] = this.phoneArea;
    data['disabled'] = this.disabled;
    return data;
  }
}

class ThirdPartInfos {
  String city;
  String country;
  String headImgUrl;
  int id;
  String nickName;
  String openId;
  String province;
  bool sex;
  int type;
  String unionId;
  int userId;

  ThirdPartInfos(
      {this.city,
        this.country,
        this.headImgUrl,
        this.id,
        this.nickName,
        this.openId,
        this.province,
        this.sex,
        this.type,
        this.unionId,
        this.userId});

  ThirdPartInfos.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    headImgUrl = json['headImgUrl'];
    id = json['id'];
    nickName = json['nickName'];
    openId = json['openId'];
    province = json['province'];
    sex = json['sex'];
    type = json['type'];
    unionId = json['unionId'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['country'] = this.country;
    data['headImgUrl'] = this.headImgUrl;
    data['id'] = this.id;
    data['nickName'] = this.nickName;
    data['openId'] = this.openId;
    data['province'] = this.province;
    data['sex'] = this.sex;
    data['type'] = this.type;
    data['unionId'] = this.unionId;
    data['userId'] = this.userId;
    return data;
  }
}