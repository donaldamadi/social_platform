// import 'package:flutter/cupertino.dart';

class HomeFeed {
  HomeFeed({
    required this.success,
    required this.data,
    required this.total,
    required this.totalPages,
    required this.status,
  });
  late final bool success;
  late final List<Data> data;
  late final int total;
  late final int totalPages;
  late final int status;
  
  HomeFeed.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    total = json['total'];
    totalPages = json['totalPages'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['total'] = total;
    _data['totalPages'] = totalPages;
    _data['status'] = status;
    return _data;
  }
}

class Data {
  Data({
    required this.answers,
    required this.reposter,
    required this.reasker,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
    required this.deleted,
    required this.id,
    required this.body,
    required this.title,
    required this.topic,
    required this.createdBy,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });
  late final List<String> answers;
  late final List<String> reposter;
  late final List<String> reasker;
  late final List<String> upvotes;
  late final List<String> downvotes;
  late final List<String> comments;
  late final bool deleted;
  late final String? id;
  late final String body;
  late final String? title;
  late final Topic topic;
  late final CreatedBy? createdBy;
  late final String type;
  late final String? createdAt;
  late final String updatedAt;
  late final int? v;
  
  Data.fromJson(Map<String, dynamic> json){
    answers = List.castFrom<dynamic, dynamic>(json['answers']) as List<String>;
    reposter = List.castFrom<dynamic, String>(json['reposter']);
    reasker = List.castFrom<dynamic, dynamic>(json['reasker']) as List<String>;
    upvotes = List.castFrom<dynamic, String>(json['upvotes']);
    downvotes = List.castFrom<dynamic, dynamic>(json['downvotes']) as List<String>;
    comments = List.castFrom<dynamic, dynamic>(json['comments']) as List<String>;
    deleted = json['deleted'];
    id = json['_id'];
    body = json['body'];
    title = json['title'];
    topic = Topic.fromJson(json['topic']);
    createdBy = json['createdBy'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['answers'] = answers;
    _data['reposter'] = reposter;
    _data['reasker'] = reasker;
    _data['upvotes'] = upvotes;
    _data['downvotes'] = downvotes;
    _data['comments'] = comments;
    _data['deleted'] = deleted;
    _data['_id'] = id;
    _data['body'] = body;
    _data['title'] = title;
    _data['topic'] = topic.toJson();
    _data['createdBy'] = createdBy;
    _data['type'] = type;
    _data['createdAt'] = createdAt;
    _data['updatedAt'] = updatedAt;
    _data['__v'] = v;
    return _data;
  }
}

class Answers {
  Answers({
    required this.url,
    required this.domain,
    required this.img,
    required this.title,
    required this.description,
  });
  late final String url;
  late final String domain;
  late final String img;
  late final String title;
  late final String description;
  
  Answers.fromJson(Map<String, dynamic> json){
    url = json['url'];
    domain = json['domain'];
    img = json['img'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['url'] = url;
    _data['domain'] = domain;
    _data['img'] = img;
    _data['title'] = title;
    _data['description'] = description;
    return _data;
  }
}

class Title {
  Title({
    required this.answers,
    required this.reposter,
    required this.reasker,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
    required this.deleted,
    required this.id,
    required this.body,
    required this.title,
    required this.topic,
    required this.createdBy,
    required this.type,
    required this.isAnswered,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });
  late final List<String> answers;
  late final List<dynamic> reposter;
  late final List<String> reasker;
  late final List<dynamic> upvotes;
  late final List<String> downvotes;
  late final List<dynamic> comments;
  late final bool deleted;
  late final String id;
  late final String body;
  late final String title;
  late final String topic;
  late final CreatedBy createdBy;
  late final String type;
  late final bool isAnswered;
  late final String createdAt;
  late final String updatedAt;
  late final int v;
  
  Title.fromJson(Map<String, dynamic> json){
    answers = List.castFrom<dynamic, String>(json['answers']);
    reposter = List.castFrom<dynamic, dynamic>(json['reposter']);
    reasker = List.castFrom<dynamic, String>(json['reasker']);
    upvotes = List.castFrom<dynamic, dynamic>(json['upvotes']);
    downvotes = List.castFrom<dynamic, dynamic>(json['downvotes']) as List<String>;
    comments = List.castFrom<dynamic, dynamic>(json['comments']);
    deleted = json['deleted'];
    id = json['_id'];
    body = json['body'];
    title = json['title'];
    topic = json['topic'];
    createdBy = CreatedBy.fromJson(json['createdBy']);
    type = json['type'];
    isAnswered = json['isAnswered'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['answers'] = answers;
    _data['reposter'] = reposter;
    _data['reasker'] = reasker;
    _data['upvotes'] = upvotes;
    _data['downvotes'] = downvotes;
    _data['comments'] = comments;
    _data['deleted'] = deleted;
    _data['_id'] = id;
    _data['body'] = body;
    _data['title'] = title;
    _data['topic'] = topic;
    _data['createdBy'] = createdBy.toJson();
    _data['type'] = type;
    _data['isAnswered'] = isAnswered;
    _data['createdAt'] = createdAt;
    _data['updatedAt'] = updatedAt;
    _data['__v'] = v;
    return _data;
  }
}

class CreatedBy {
  CreatedBy({
    required this.profilepic,
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.institution,
  });
  late final String profilepic;
  late final String id;
  late final String firstname;
  late final String lastname;
  late final String username;
  late final String institution;
  
  CreatedBy.fromJson(Map<String, dynamic> json){
    profilepic = json['profilepic'];
    id = json['_id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    username = json['username'];
    institution = json['institution'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['profilepic'] = profilepic;
    _data['_id'] = id;
    _data['firstname'] = firstname;
    _data['lastname'] = lastname;
    _data['username'] = username;
    _data['institution'] = institution;
    return _data;
  }
}

class Topic {
  Topic({
    required this.id,
    required this.name,
  });
  late final String id;
  late final String name;
  
  Topic.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class CreatedAt {
  CreatedAt({
    required this.id,
    required this.name,
  });
  late final String id;
  late final String name;
  
  CreatedAt.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_id'] = id;
    _data['name'] = name;
    return _data;
  }
}

// class HomeFeed {
//   HomeFeed({
//     required this.success,
//     required this.data,
//     required this.total,
//     required this.status,
//   });
//   late final bool success;
//   late final List<Data> data;
//   late final int total;
//   late final int status;
  
//   HomeFeed.fromJson(Map<String, dynamic> json){
//     success = json['success'];
//     data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
//     total = json['total'];
//     status = json['status'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['success'] = success;
//     _data['data'] = data.map((e)=>e.toJson()).toList();
//     _data['total'] = total;
//     _data['status'] = status;
//     return _data;
//   }
// }

// class Data {
//   Data({
//     required this.id,
//     required this.comments,
//     required this.answers,
//     required this.reposter,
//     required this.reasker,
//     required this.upvotes,
//     required this.downvotes,
//     required this.filtercount,
//     required this.title,
//     required this.topic,
//     required this.createdBy,
//     required this.type,
//     required this.isAnswered,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//   });
//   late final String id;
//   late final List<dynamic> comments;
//   late final List<dynamic> answers;
//   late final List<String> reposter;
//   late final List<dynamic> reasker;
//   late final List<dynamic> upvotes;
//   late final List<String> downvotes;
//   late final int filtercount;
//   late final String? title;
//   late final Topic? topic;
//   late final CreatedBy createdBy;
//   late final String? type;
//   late final bool? isAnswered;
//   late final String createdAt;
//   late final String updatedAt;
//   late final int v;
  
//   Data.fromJson(Map<String, dynamic> json){
//     id = json['id'];
//     comments = List.castFrom<dynamic, dynamic>(json['comments']);
//     answers = List.castFrom<dynamic, dynamic>(json['answers']);
//     reposter = List.castFrom<dynamic, String>(json['reposter']);
//     reasker = List.castFrom<dynamic, dynamic>(json['reasker']);
//     upvotes = List.castFrom<dynamic, dynamic>(json['upvotes']);
//     downvotes = List.castFrom<dynamic, String>(json['downvotes']);
//     filtercount = json['filtercount'];
//     title = json['title'];
//     topic = json['topic'];
//     createdBy = CreatedBy.fromJson(json['createdBy']);
//     type = json['type'];
//     isAnswered = json['isAnswered'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     v = json['__v'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     _data['comments'] = comments;
//     _data['answers'] = answers;
//     _data['reposter'] = reposter;
//     _data['reasker'] = reasker;
//     _data['upvotes'] = upvotes;
//     _data['downvotes'] = downvotes;
//     _data['filtercount'] = filtercount;
//     _data['title'] = title;
//     _data['topic'] = topic;
//     _data['createdBy'] = createdBy.toJson();
//     _data['type'] = type;
//     _data['isAnswered'] = isAnswered;
//     _data['createdAt'] = createdAt;
//     _data['updatedAt'] = updatedAt;
//     _data['__v'] = v;
//     return _data;
//   }
// }

// class Title {
//   Title({
//     required this.path,
//     required this.mimetype,
//     required this.caption,
//   });
//   late final String path;
//   late final String mimetype;
//   late final String caption;
  
//   Title.fromJson(Map<String, dynamic> json){
//     path = json['path'];
//     mimetype = json['mimetype'];
//     caption = json['caption'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['path'] = path;
//     _data['mimetype'] = mimetype;
//     _data['caption'] = caption;
//     return _data;
//   }
// }

// class Topic {
//   Topic({
//     required this.id,
//     required this.name,
//   });
//   late final String id;
//   late final String name;
  
//   Topic.fromJson(Map<String, dynamic> json){
//     id = json['id'];
//     name = json['name'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     _data['name'] = name;
//     return _data;
//   }
// }

// class CreatedBy {
//   CreatedBy({
//     required this.id,
//     required this.profilepic,
//   });
//   late final String id;
//   late final String profilepic;
  
//   CreatedBy.fromJson(Map<String, dynamic> json){
//     id = json['id'];
//     profilepic = json['profilepic'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     _data['profilepic'] = profilepic;
//     return _data;
//   }
// }

// class Type {
//   Type({
//     required this.id,
//     required this.profilepic,
//   });
//   late final String id;
//   late final String profilepic;
  
//   Type.fromJson(Map<String, dynamic> json){
//     id = json['id'];
//     profilepic = json['profilepic'];
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['id'] = id;
//     _data['profilepic'] = profilepic;
//     return _data;
//   }
// }