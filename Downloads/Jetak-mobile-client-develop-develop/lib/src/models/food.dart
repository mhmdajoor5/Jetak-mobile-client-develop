import '../helpers/custom_trace.dart';
import '../models/category.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/media.dart';
import '../models/nutrition.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'coupon.dart';

class Food {
  String id;
  String name;
  double price;
  double discountPrice;
  int estTime;
  Media? image;
  String description;
  String ingredients;
  String weight;
  String unit;
  String packageItemsCount;
  bool featured;
  bool deliverable;
  Restaurant restaurant;
  Category category;
  List<Extra> extras;
  List<ExtraGroup> extraGroups;
  List<Review> foodReviews;
  List<Nutrition> nutritions;

  Food({
    this.id = '',
    this.name = '',
    this.price = 0.0,
    this.discountPrice = 0.0,
    this.estTime = 0,
    this.image,
    this.description = '',
    this.ingredients = '',
    this.weight = '',
    this.unit = '',
    this.packageItemsCount = '',
    this.featured = false,
    this.deliverable = false,
    Restaurant? restaurant,
    Category? category,
    List<Extra>? extras,
    List<ExtraGroup>? extraGroups,
    List<Review>? foodReviews,
    List<Nutrition>? nutritions,
  }) : restaurant = restaurant ?? Restaurant.fromJSON({}),
       category = category ?? Category.fromJSON({}),
       extras = extras ?? [],
       extraGroups = extraGroups ?? [],
       foodReviews = foodReviews ?? [],
       nutritions = nutritions ?? [];

  factory Food.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      double basePrice = (jsonMap?['price'] as num?)?.toDouble() ?? 0.0;
      double discount = (jsonMap?['discount_price'] as num?)?.toDouble() ?? 0.0;
      return Food(
        id: jsonMap?['id']?.toString() ?? '',
        name: jsonMap?['name']?.toString() ?? '',
        price: discount != 0 ? discount : basePrice,
        discountPrice: discount != 0 ? basePrice : 0.0,
        description: jsonMap?['description']?.toString() ?? '',
        estTime: jsonMap?['estimated_time'] ?? 0,
        ingredients: jsonMap?['ingredients']?.toString() ?? '',
        weight: jsonMap?['weight']?.toString() ?? '',
        unit: jsonMap?['unit']?.toString() ?? '',
        packageItemsCount: jsonMap?['package_items_count']?.toString() ?? '',
        featured: jsonMap?['featured'] ?? false,
        deliverable: jsonMap?['deliverable'] ?? false,
        restaurant: jsonMap?['restaurant'] != null ? Restaurant.fromJSON(jsonMap!['restaurant']) : Restaurant.fromJSON({}),
        category: jsonMap?['category'] != null ? Category.fromJSON(jsonMap!['category']) : Category.fromJSON({}),
        image: jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty ? Media.fromJSON(jsonMap['media'][0]) : Media(),
        extras: jsonMap?['extras'] != null ? List<Extra>.from(jsonMap!['extras'].map((e) => Extra.fromJSON(e))).toSet().toList() : [],
        extraGroups: jsonMap?['extra_groups'] != null ? List<ExtraGroup>.from(jsonMap!['extra_groups'].map((e) => ExtraGroup.fromJSON(e))).toSet().toList() : [],
        foodReviews: jsonMap?['food_reviews'] != null ? List<Review>.from(jsonMap!['food_reviews'].map((e) => Review.fromJSON(e))).toSet().toList() : [],
        nutritions: jsonMap?['nutrition'] != null ? List<Nutrition>.from(jsonMap!['nutrition'].map((e) => Nutrition.fromJSON(e))).toSet().toList() : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Food();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "price": price, "discountPrice": discountPrice, "description": description, "ingredients": ingredients, "weight": weight, "estimated_time": estTime};
  }

  double getRate() {
    if (foodReviews.isEmpty) return 0;
    double total = foodReviews.fold(0.0, (sum, e) => sum + (double.tryParse(e.rate) ?? 0.0));
    return total / foodReviews.length;
  }

  Coupon applyCoupon(Coupon coupon) {
    if (coupon.code != null && coupon.code!.isEmpty) return coupon;

    if (!coupon.valid) {
      for (var element in coupon.discountables) {
        if (element.discountableType == "App\\Models\\Food" && element.discountableId == id ||
            element.discountableType == "App\\Models\\Restaurant" && element.discountableId == restaurant.id ||
            element.discountableType == "App\\Models\\Category" && element.discountableId == category.id) {
          return _couponDiscountPrice(coupon);
        }
      }
    }

    return coupon;
  }

  Coupon _couponDiscountPrice(Coupon coupon) {
    coupon.valid = true;
    discountPrice = price;
    if (coupon.discountType == 'fixed') {
      price -= coupon.discount ?? 0;
    } else {
      price -= (price * (coupon.discount ?? 0) / 100);
    }
    if (price < 0) price = 0;
    return coupon;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Food && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
