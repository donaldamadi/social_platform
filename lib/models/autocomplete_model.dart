// To parse this JSON data, do
//
//     final autocomplete = autocompleteFromJson(jsonString);

import 'dart:convert';

List<Autocomplete> autocompleteFromJson(String str) => List<Autocomplete>.from(json.decode(str).map((x) => Autocomplete.fromJson(x)));

String autocompleteToJson(List<Autocomplete> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Autocomplete {
    Autocomplete({
        this.id,
        this.display,
        this.institution,
        this.profilepic,
        this.firstname,
        this.lastname,
    });

    String? id;
    String? display;
    String? institution;
    String? profilepic;
    String? firstname;
    String? lastname;

    factory Autocomplete.fromJson(Map<String, dynamic> json) => Autocomplete(
        id: json["_id"],
        display: json["username"],
        institution: json["institution"],
        profilepic: json["profilepic"],
        firstname: json["firstname"],
        lastname: json["lastname"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "username": display,
        "institution": institution,
        "profilepic": profilepic,
        "firstname": firstname,
        "lastname": lastname,
    };
}
