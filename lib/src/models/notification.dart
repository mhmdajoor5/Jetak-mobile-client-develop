import '../helpers/custom_trace.dart';

class Notification {
  String id;
  String type;
  Map<String, dynamic> data;
  bool read;
  DateTime createdAt;

  Notification({this.id = '', this.type = '', this.data = const {}, this.read = false, DateTime? createdAt}) : createdAt = createdAt ?? DateTime(0);

  factory Notification.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Notification(
        id: jsonMap?['id']?.toString() ?? '',
        type: jsonMap?['type']?.toString() ?? '',
        data: jsonMap?['data'] is Map<String, dynamic> ? jsonMap!['data'] : {},
        read: jsonMap?['read_at'] != null,
        createdAt: jsonMap?['created_at'] != null ? DateTime.tryParse(jsonMap!['created_at']) ?? DateTime(0) : DateTime(0),
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Notification();
    }
  }

  Map<String, dynamic> markReadMap() {
    return {"id": id, "read_at": !read};
  }
}
