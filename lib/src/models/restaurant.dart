import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'coupon.dart';
import 'discountable.dart';
import 'user.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool closed;
  bool availableForDelivery;
  double deliveryRange;
  double distance;
  String closingTime;
  List<User> users;
  Coupon? coupon;
  List<Discountable> discountables;

  Restaurant({
    this.id = '',
    this.name = '',
    Media? image,
    this.rate = '0',
    this.address = '',
    this.description = '',
    this.phone = '',
    this.mobile = '',
    this.information = '',
    this.deliveryFee = 0.0,
    this.adminCommission = 0.0,
    this.defaultTax = 0.0,
    this.latitude = '0',
    this.longitude = '0',
    this.closed = false,
    this.availableForDelivery = false,
    this.deliveryRange = 0.0,
    this.distance = 0.0,
    this.closingTime = '22:00',
    this.coupon,
    List<User>? users,
    List<Discountable>? discountables,
  })  : image = image ?? Media(),
        users = users ?? [],
        discountables = discountables ?? [];

  factory Restaurant.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      print('Raw restaurant JSON: $jsonMap');
      return Restaurant(
        id: jsonMap?['id']?.toString() ?? '',
        name: jsonMap?['name']?.toString() ?? '',
        image: (jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty)
            ? Media.fromJSON(jsonMap['media'][0])
            : Media(),
        rate: jsonMap?['rate']?.toString() ?? '0',
        deliveryFee: (jsonMap?['delivery_fee'] as num?)?.toDouble() ?? 0.0,
        adminCommission: (jsonMap?['admin_commission'] as num?)?.toDouble() ?? 0.0,
        deliveryRange: (jsonMap?['delivery_range'] as num?)?.toDouble() ?? 0.0,
        address: jsonMap?['address']?.toString() ?? '',
        description: jsonMap?['description']?.toString() ?? '',
        phone: jsonMap?['phone']?.toString() ?? '',
        mobile: jsonMap?['mobile']?.toString() ?? '',
        defaultTax: (jsonMap?['default_tax'] as num?)?.toDouble() ?? 0.0,
        information: jsonMap?['information']?.toString() ?? '',
        latitude: jsonMap?['latitude']?.toString() ?? '0',
        longitude: jsonMap?['longitude']?.toString() ?? '0',
        closed: jsonMap?['closed'] ?? false,
        availableForDelivery: jsonMap?['available_for_delivery'] ?? false,
        closingTime: jsonMap?['closing_time']?.toString() ?? '22:00',
        distance: (jsonMap?['distance'] != null)
            ? double.tryParse(jsonMap!['distance'].toString()) ?? 0.0
            : 0.0,
        users: jsonMap?['users'] != null
            ? List<User>.from(jsonMap!['users'].map((e) => User.fromJSON(e))).toSet().toList()
            : [],
        coupon: _parseBestDiscount(jsonMap),
        discountables: jsonMap?['discountables'] != null
            ? List<Discountable>.from(jsonMap?['discountables'].map((e) => Discountable.fromJSON(e)))
            : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Restaurant();
    }
  }
  static Coupon? _parseBestDiscount(Map<String, dynamic>? json) {
    if (json?['discount'] != null && json!['discount']['best_discount'] != null) {
      final best = json['discount']['best_discount'];
      return Coupon(
        valid: true,
        discount: (best['discount'] as num?)?.toDouble(),
        discountType: best['discount_type'] ?? 'percent',
      );
    }
    return null;
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance
    };
  }
}
