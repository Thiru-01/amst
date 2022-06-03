// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(Map<String, dynamic> str) =>
    UserModel.fromJson(str);

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel(
      {required this.id,
      required this.nickname,
      required this.photoUrl,
      required this.email,
      required this.chattingWith,
      required this.messageToken});

  String id;
  String nickname;
  String photoUrl;
  String email;
  String? chattingWith;
  String messageToken;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json["id"],
      nickname: json["nickname"],
      photoUrl: json["photoUrl"],
      email: json["email"],
      chattingWith: json["chattingWith"],
      messageToken: json["messageToken"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "nickname": nickname,
        "photoUrl": photoUrl,
        "email": email,
        "messageToken": messageToken,
        "chattingWith": chattingWith
      };
}
