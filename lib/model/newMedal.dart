class NewMedal {
  String code;
  List<Data> data;

  NewMedal({this.code, this.data});

  NewMedal.fromJson(Map<String, dynamic> json) {
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
  String image;
  String group;
  String name;
  String describe;
  int target;
  bool have;
  bool read;

  Data(
      {this.id,
        this.image,
        this.group,
        this.name,
        this.describe,
        this.target,
        this.have,
        this.read});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    group = json['group'];
    name = json['name'];
    describe = json['describe'];
    target = json['target'];
    have = json['have'];
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['group'] = this.group;
    data['name'] = this.name;
    data['describe'] = this.describe;
    data['target'] = this.target;
    data['have'] = this.have;
    data['read'] = this.read;
    return data;
  }
}