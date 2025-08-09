import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/extra.dart';
import '../models/food.dart';
import 'extra_group.dart';

class Cart {
  String? id;
  Food? food;
  double quantity;
  List<Extra> extras;
  String? userId;

  Cart({this.id, this.food, this.quantity = 0.0, List<Extra>? extras, this.userId}) : extras = extras ?? [];

  factory Cart.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      if (jsonMap == null) {
        return Cart(id: '', food: Food.fromJSON({}), quantity: 0.0, extras: []);
      }

      return Cart(
        id: jsonMap['id']?.toString() ?? '',
        quantity: (jsonMap['quantity'] is num) ? (jsonMap['quantity'] as num).toDouble() : 0.0,
        food: jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food.fromJSON({}),
        extras: jsonMap['extras'] != null ? List<Extra>.from(jsonMap['extras'].map((e) => Extra.fromJSON(e))) : [],
        userId: jsonMap['user_id']?.toString(),
      );
    } catch (e, stackTrace) {
      print(CustomTrace(stackTrace, message: e.toString()));
      return Cart(id: '', food: Food.fromJSON({}), quantity: 0.0, extras: []);
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "quantity": quantity, "food_id": food?.id, "user_id": userId, "extras": extras.map((e) => e.id).toList()};
  }

  double getFoodPrice() {
    double result = food?.price ?? 0.0;
    
    if (extras.isEmpty) {
      return result;
    }

    // تجميع الإضافات حسب المجموعة
    Map<String, List<Extra>> extrasByGroup = {};
    for (var extra in extras) {
      if (!extrasByGroup.containsKey(extra.extraGroupId)) {
        extrasByGroup[extra.extraGroupId] = [];
      }
      extrasByGroup[extra.extraGroupId]!.add(extra);
    }

    // حساب السعر لكل مجموعة إضافات
    for (var groupId in extrasByGroup.keys) {
      List<Extra> groupExtras = extrasByGroup[groupId]!;
      
      // البحث عن ExtraGroup المقابل
      ExtraGroup? extraGroup = food?.extraGroups.firstWhere(
        (group) => group.id == groupId,
        orElse: () => ExtraGroup(),
      );

      if (extraGroup!.id.isEmpty) {
        // إذا لم نجد المجموعة، نستخدم السعر العادي
        for (var extra in groupExtras) {
          result += extra.price;
        }
        continue;
      }

      // تطبيق منطق max_allowed و max_charge
      if (extraGroup!.maxAllowed != null && groupExtras.length > extraGroup.maxAllowed!) {
        // عدد الإضافات يتجاوز الحد المسموح
        int allowedCount = extraGroup!.maxAllowed!;
        int extraCount = groupExtras.length - allowedCount;
        
        // حساب سعر الإضافات المسموحة
        for (int i = 0; i < allowedCount && i < groupExtras.length; i++) {
          result += groupExtras[i].price;
        }
        
        // إضافة الرسوم الإضافية للإضافات التي تتجاوز الحد
        for (int i = allowedCount; i < groupExtras.length; i++) {
          result += groupExtras[i].price + extraGroup.maxCharge;
        }
      } else {
        // عدد الإضافات ضمن الحد المسموح أو لا يوجد حد
        for (var extra in groupExtras) {
          result += extra.price;
        }
      }
    }

    return result;
  }

  bool isSame(Cart cart) {
    if (food?.id != cart.food?.id || extras.length != cart.extras.length) return false;
    for (var extra in extras) {
      if (!cart.extras.contains(extra)) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Cart && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
