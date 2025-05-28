import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Favorite {
  String id;
  Food food;
  List<Extra> extras;
  String? userId;

  Favorite({this.id = '', Food? food, List<Extra>? extras, this.userId}) : food = food ?? Food.fromJSON({}), extras = extras ?? [];

  factory Favorite.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Favorite(
        id: jsonMap?['id']?.toString() ?? '',
        food: jsonMap?['food'] != null ? Food.fromJSON(jsonMap!['food']) : Food.fromJSON({}),
        extras: jsonMap?['extras'] != null ? List<Extra>.from(jsonMap!['extras'].map((e) => Extra.fromJSON(e))) : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Favorite();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "food_id": food.id, "user_id": userId, "extras": extras.map((e) => e.id).toList()};
  }
}
