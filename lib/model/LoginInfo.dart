class LoginInfo {
  String code;
  Data data;

  LoginInfo({this.code, this.data});

  LoginInfo.fromJson(Map<String, dynamic> json) {
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
  String token;

  Data({this.userInfo, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    userInfo = json['userInfo'] != null
        ? new UserInfo.fromJson(json['userInfo'])
        : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo.toJson();
    }
    data['token'] = this.token;
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
  bool hasPsw;

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
        this.disabled,
        this.hasPsw});

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
    hasPsw = json['hasPsw'];
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
    data['hasPsw'] = this.hasPsw;
    return data;
  }
}