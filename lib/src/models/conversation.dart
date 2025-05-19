import 'user.dart';

class Conversation {
  String? id;
  String name;
  String lastMessage;
  int lastMessageTime;
  List<String?> readByUsers;
  List<String?> visibleToUsers;
  List<User> users;

  Conversation(this.users, {this.id, this.name = ''}) : readByUsers = [], visibleToUsers = users.map((user) => user.id).toList(), lastMessage = '', lastMessageTime = 0;

  factory Conversation.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Conversation(
          (jsonMap?['users'] != null
              ? List<User>.from(
                jsonMap!['users'].map((element) {
                  element['media'] = [
                    {'thumb': element['thumb']},
                  ];
                  return User.fromJSON(element);
                }),
              )
              : []),
          id: jsonMap?['id']?.toString(),
          name: jsonMap?['name']?.toString() ?? '',
        )
        ..readByUsers = jsonMap?['read_by_users'] != null ? List<String>.from(jsonMap!['read_by_users']) : []
        ..visibleToUsers = jsonMap?['visible_to_users'] != null ? List<String>.from(jsonMap!['visible_to_users']) : []
        ..lastMessage = jsonMap?['message']?.toString() ?? ''
        ..lastMessageTime = jsonMap?['time'] is int ? jsonMap!['time'] : 0;
    } catch (e) {
      print(e);
      return Conversation([], id: '', name: '');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "users": users.map((e) => e.toRestrictMap()).toSet().toList(),
      "visible_to_users": users.map((e) => e.id).toSet().toList(),
      "read_by_users": readByUsers,
      "message": lastMessage,
      "time": lastMessageTime,
    };
  }

  Map<String, dynamic> toUpdatedMap() {
    return {"message": lastMessage, "time": lastMessageTime, "read_by_users": readByUsers};
  }
}
