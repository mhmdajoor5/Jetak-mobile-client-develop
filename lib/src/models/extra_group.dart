import '../helpers/custom_trace.dart';

class ExtraGroup {
  String id;
  String name;
  int? maxAllowed; // عدد العناصر المسموح اختيارها بدون رسوم إضافية
  double maxCharge; // الرسوم الإضافية لكل عنصر يتجاوز الحد المسموح

  ExtraGroup({
    this.id = '', 
    this.name = '', 
    this.maxAllowed, 
    this.maxCharge = 0.0
  });

  factory ExtraGroup.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return ExtraGroup(
        id: jsonMap?['id']?.toString() ?? '', 
        name: jsonMap?['name']?.toString() ?? '',
        maxAllowed: jsonMap?['max_allowed'] != null ? int.tryParse(jsonMap!['max_allowed'].toString()) : null,
        maxCharge: (jsonMap?['max_charge'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return ExtraGroup();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id, 
      "name": name,
      "max_allowed": maxAllowed,
      "max_charge": maxCharge,
    };
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
