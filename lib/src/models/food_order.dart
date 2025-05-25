import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class FoodOrder {
  String id;
  double price;
  double quantity;
  List<Extra> extras;
  Food? food;
  DateTime dateTime;

  FoodOrder({this.id = '', this.price = 0.0, this.quantity = 0.0, List<Extra>? extras, Food? food, DateTime? dateTime})
    : extras = extras ?? [],
      food = food ?? Food.fromJSON({}),
      dateTime = dateTime ?? DateTime(0);

  factory FoodOrder.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return FoodOrder(
        id: jsonMap?['id']?.toString() ?? '',
        price: (jsonMap?['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (jsonMap?['quantity'] as num?)?.toDouble() ?? 0.0,
        food: jsonMap?['food'] != null ? Food.fromJSON(jsonMap!['food']) : Food.fromJSON({}),
        dateTime: jsonMap?['updated_at'] != null ? DateTime.tryParse(jsonMap!['updated_at']) ?? DateTime(0) : DateTime(0),
        extras: jsonMap?['extras'] != null ? List<Extra>.from(jsonMap!['extras'].map((e) => Extra.fromJSON(e))) : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return FoodOrder();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "price": price, "quantity": quantity, "food_id": food?.id, "extras": extras.map((e) => e.id).toList()};
  }
}
