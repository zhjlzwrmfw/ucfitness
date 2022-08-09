class AbilityRank {
  String code;
  List<Data> data;

  AbilityRank({this.code, this.data});

  AbilityRank.fromJson(Map<String, dynamic> json) {
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
  int id;
  int userId;
  double power;
  double agile;
  double endurance;
  double physique;
  double perseverance;
  double total;
  int rank;
  String nickName;
  String headImg;

  Data(
      {this.id,
        this.userId,
        this.power,
        this.agile,
        this.endurance,
        this.physique,
        this.perseverance,
        this.total,
        this.rank,
        this.nickName,
        this.headImg});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    power = json['power'];
    agile = json['agile'];
    endurance = json['endurance'];
    physique = json['physique'];
    perseverance = json['perseverance'];
    total = json['total'];
    rank = json['rank'];
    nickName = json['nickName'];
    headImg = json['headImg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['power'] = this.power;
    data['agile'] = this.agile;
    data['endurance'] = this.endurance;
    data['physique'] = this.physique;
    data['perseverance'] = this.perseverance;
    data['total'] = this.total;
    data['rank'] = this.rank;
    data['nickName'] = this.nickName;
    data['headImg'] = this.headImg;
    return data;
  }
}