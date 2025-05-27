import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Cuisine {
  String id;
  String name;
  String description;
  Media image;
  bool selected;

  Cuisine({this.id = '', this.name = '', this.description = '', Media? image, this.selected = false}) : image = image ?? Media();

  factory Cuisine.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Cuisine(
        id: jsonMap?['id']?.toString() ?? '',
        name: jsonMap?['name']?.toString() ?? '',
        description: jsonMap?['description']?.toString() ?? '',
        image: (jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap['media'][0]) : Media(),
        selected: jsonMap?['selected'] ?? false,
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Cuisine();
    }
  }

  Map<String, dynamic> toMap() {
    return {'id': id};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Cuisine && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
