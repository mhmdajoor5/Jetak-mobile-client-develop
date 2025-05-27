import '../helpers/custom_trace.dart';

class ExtraGroup {
  String id;
  String name;

  ExtraGroup({this.id = '', this.name = ''});

  factory ExtraGroup.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return ExtraGroup(id: jsonMap?['id']?.toString() ?? '', name: jsonMap?['name']?.toString() ?? '');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return ExtraGroup();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name};
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is ExtraGroup && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
