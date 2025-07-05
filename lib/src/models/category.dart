import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'food.dart';

class Category {
  String? id;
  String? name;
  Media? image;
  List<Food>? foods ;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      foods = jsonMap['foods'] != null
          ? (jsonMap['foods'] as List)
              .map((food) => Food.fromJSON(food as Map<String, dynamic>))
              .toList()
          : <Food>[];
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      print(CustomTrace(StackTrace.current, message: '$e'));
    }
  }
}
