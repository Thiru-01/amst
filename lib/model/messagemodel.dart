// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(Map<String, dynamic> str) =>
    MessageModel.fromJson(str);

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  MessageModel({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  String idFrom;
  String idTo;
  String timestamp;
  String content;
  String type;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        idFrom: json["idFrom"],
        idTo: json["idTo"],
        timestamp: json["timestamp"],
        content: json["content"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "idFrom": idFrom,
        "idTo": idTo,
        "timestamp": timestamp,
        "content": content,
        "type": type,
      };
}
