import '../helpers/custom_trace.dart';

class Discountable {
  String id;
  String? discountableType;
  String? discountableId;

  Discountable({this.id = '', this.discountableType, this.discountableId});

  factory Discountable.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Discountable(id: jsonMap?['id']?.toString() ?? '', discountableType: jsonMap?['discountable_type']?.toString(), discountableId: jsonMap?['discountable_id']?.toString());
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Discountable();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "discountable_type": discountableType, "discountable_id": discountableId};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Discountable && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
