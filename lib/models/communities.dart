class Communities {
  Communities({
    required this.success,
    required this.data,
    required this.total,
    required this.status,
  });
  late final bool success;
  late final List<Data> data;
  late final int total;
  late final int status;
  
  Communities.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    total = json['total'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['total'] = total;
    _data['status'] = status;
    return _data;
  }
}

class Data {
  Data({
    required this.id,
    required this.department,
    required this.topics,
    required this.followers,
    required this.name,
    required this.v,
    required this.communityPicture,
    required this.updatedAt,
    required this.description,
  });
  late final String id;
  late final List<dynamic> department;
  late final List<String> topics;
  late final List<String> followers;
  late final String name;
  late final int v;
  late final String communityPicture;
  late final String updatedAt;
  late final String description;
  
  Data.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    department = List.castFrom<dynamic, dynamic>(json['department']);
    topics = List.castFrom<dynamic, String>(json['topics']);
    followers = List.castFrom<dynamic, dynamic>(json['followers']) as List<String>;
    name = json['name'];
    v = json['__v'];
    communityPicture = json['communityPicture'];
    updatedAt = json['updatedAt'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_id'] = id;
    _data['department'] = department;
    _data['topics'] = topics;
    _data['followers'] = followers;
    _data['name'] = name;
    _data['__v'] = v;
    _data['communityPicture'] = communityPicture;
    _data['updatedAt'] = updatedAt;
    _data['description'] = description;
    return _data;
  }
}