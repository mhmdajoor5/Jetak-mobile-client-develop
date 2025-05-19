import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Extra {
  String id;
  String extraGroupId;
  String name;
  double price;
  Media image;
  String description;
  bool checked;

  Extra({this.id = '', this.extraGroupId = '0', this.name = '', this.price = 0.0, Media? image, this.description = '', this.checked = false}) : image = image ?? Media();

  factory Extra.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Extra(
        id: jsonMap?['id']?.toString() ?? '',
        extraGroupId: jsonMap?['extra_group_id']?.toString() ?? '0',
        name: jsonMap?['name']?.toString() ?? '',
        price: (jsonMap?['price'] as num?)?.toDouble() ?? 0.0,
        description: jsonMap?['description']?.toString() ?? '',
        image: (jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap['media'][0]) : Media(),
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Extra();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "price": price, "description": description};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Extra && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
