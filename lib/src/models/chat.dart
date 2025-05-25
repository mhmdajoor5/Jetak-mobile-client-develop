import 'package:flutter/material.dart';
import 'user.dart';

class Chat {
  String id;
  String text;
  int time;
  String? userId;
  User? user;

  Chat({String? id, required this.text, required this.time, this.userId, this.user}) : id = id ?? UniqueKey().toString();

  factory Chat.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Chat(id: jsonMap?['id']?.toString(), text: jsonMap?['text']?.toString() ?? '', time: jsonMap?['time'] is int ? jsonMap!['time'] : 0, userId: jsonMap?['user']?.toString());
    } catch (e) {
      print(e);
      return Chat(text: '', time: 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "text": text, "time": time, "user": userId};
  }
}
