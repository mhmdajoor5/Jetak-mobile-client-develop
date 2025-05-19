import '../helpers/custom_trace.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/user.dart';

class Review {
  String id;
  String review;
  String rate;
  User user;

  Review({this.id = '', this.review = '', this.rate = '0', User? user}) : user = user ?? User.fromJSON({});

  Review.init(this.rate) : id = '', review = '', user = User.fromJSON({});

  factory Review.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Review(
        id: jsonMap?['id']?.toString() ?? '',
        review: jsonMap?['review']?.toString() ?? '',
        rate: jsonMap?['rate']?.toString() ?? '0',
        user: jsonMap?['user'] != null ? User.fromJSON(jsonMap!['user']) : User.fromJSON({}),
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Review();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "review": review, "rate": rate, "user_id": user.id};
  }

  Map<String, dynamic> ofRestaurantToMap(Restaurant restaurant) {
    final map = toMap();
    map["restaurant_id"] = restaurant.id;
    return map;
  }

  Map<String, dynamic> ofFoodToMap(Food food) {
    final map = toMap();
    map["food_id"] = food.id;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Review && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
