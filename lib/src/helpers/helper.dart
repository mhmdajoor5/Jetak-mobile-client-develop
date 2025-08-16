import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/src/style.dart' as style;
// import 'package:flutter_html/src/style/marker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import '../models/card_item.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/restaurant.dart';
import '../repository/settings_repository.dart';
import 'custom_trace.dart';

class Helper {
  late BuildContext context;
  late DateTime currentBackPressTime;

  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in km
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Save a list of cards to SharedPreferences
  static Future<void> saveCardsToSP(List<CardItem> cards) async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Remove duplicates before saving
      final uniqueCards = cards.toSet().toList();

      // Convert to JSON-serializable format
      final cardListMap = uniqueCards.map((card) => card.toMap()).toList();

      // Save to shared preferences
      await prefs.setString('user_credit_cards', json.encode(cardListMap));

      // Debug print
      if (kDebugMode) {
        print("CARDS SAVED (${uniqueCards.length} unique cards): ${uniqueCards.map((c) => c.cardNumber).join(', ')}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving cards: $e");
      }
      rethrow;
    }
  }

  /// Clear all saved cards from SharedPreferences
  static Future<void> clearSavedCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_credit_cards');
    if (kDebugMode) {
      print("All saved cards cleared.");
    }
  }

  /// Add a single card to the list
  static Future<void> addCardToSP(CardItem card) async {
    List<CardItem> cards = await getSavedCards();
    if (!cards.contains(card)) {
      cards.add(card);
      await saveCardsToSP(cards);
    }
  }

  /// Retrieve the list of saved cards
  static Future<List<CardItem>> getSavedCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cardListJson = prefs.getString('user_credit_cards');
    if (cardListJson == null) {
      return [];
    }

    List<dynamic> cardListMap = json.decode(cardListJson);
    return cardListMap.map((card) => CardItem.fromMap(card)).toList();
  }

  /// Remove a card from the list by index
  static Future<void> removeCardFromSP(int index) async {
    List<CardItem> cards = await getSavedCards();
    if (index >= 0 && index < cards.length) {
      cards.removeAt(index);
      await saveCardsToSP(cards);
    }
  }

  static String skipHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  /// Check if there are any saved cards
  static Future<bool> hasSavedCards() async {
    List<CardItem> cards = await getSavedCards();
    return cards.isNotEmpty;
  }

  // for mapping data retrieved from json array (handles both list and paginated map)
  static getData(Map<String, dynamic>? data) {
    if (data == null) return [];
    final dynamic inner = data['data'];
    if (inner is List) {
      return inner;
    }
    if (inner is Map<String, dynamic>) {
      // Common paginated shape: { data: { current_page, data: [ ... ] } }
      final dynamic nested = inner['data'];
      if (nested is List) return nested;
    }
    // Fallbacks: sometimes APIs return items directly without wrapping
    if (data is List) return data;
    return [];
  }

  static int getIntData(Map<String, dynamic>? data) {
    return (data?['data'] as int) ?? 0;
  }

  static double getDoubleData(Map<String, dynamic>? data) {
    return (data?['data'] as double) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic>? data) {
    return (data?['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic>? data) {
    return data?['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  static Future<map.Marker> getMarker(Map<String, dynamic> res) async {
    final Uint8List? markerIcon =
    await getBytesFromAsset('assets/img/marker.png', 120);
    final map.Marker marker = map.Marker(
        markerId: map.MarkerId(res['id']),
        // icon: BitmapDescriptor.fromBytes(markerIcon),
//        onTap: () {
//          //print(res.name);
//        },
        anchor: Offset(0.5, 0.5),
        infoWindow: map.InfoWindow(
            title: res['name'],
            snippet: getDistance(
                res['distance'].toDouble(), setting.value.distanceUnit),
            onTap: () {
              print(CustomTrace(StackTrace.current, message: 'Info Window'));
            }),
        position: map.LatLng(
            double.parse(res['latitude']), double.parse(res['longitude'])));

    return marker;
  }

  static Future<map.Marker> getMyPositionMarker(
      double latitude, double longitude) async {
    final Uint8List? markerIcon =
    await getBytesFromAsset('assets/img/my_marker.png', 120);
    final map.Marker marker = map.Marker(
        markerId: map.MarkerId('my_position'), // Use consistent ID
        icon: map.BitmapDescriptor.fromBytes(markerIcon!),
        anchor: Offset(0.5, 0.5),
        infoWindow: map.InfoWindow(title: 'موقعي'),
        position: map.LatLng(latitude, longitude));

    return marker;
  }

  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
          return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
        }));
    return list;
  }

  static Widget getPrice(double myPrice, BuildContext context,
      {TextStyle? style, String zeroPlaceholder = '-'}) {
    if (style != null) {
      style = style.merge(TextStyle(fontSize: (style.fontSize)! + 2));
    }
    try {
      if (myPrice == 0) {
        return Text(zeroPlaceholder,
            style: style ?? Theme.of(context).textTheme.titleMedium);
      }
      return RichText(
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        text: setting.value.currencyRight == false
            ? TextSpan(
          text: setting.value.defaultCurrency,
          style: style == null
              ? Theme.of(context).textTheme.titleMedium!.merge(
            TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: Theme.of(context)
                    .textTheme
                    .titleMedium
                !.fontSize! -
                    6),
          )
              : style.merge(TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: style.fontSize! - 6)),
          children: <TextSpan>[
            TextSpan(
                text: myPrice.toStringAsFixed(
                    setting.value.currencyDecimalDigits),
                style: style ?? Theme.of(context).textTheme.titleMedium),
          ],
        )
            : TextSpan(
          text: myPrice.toStringAsFixed(
              setting.value.currencyDecimalDigits),
          style: style ?? Theme.of(context).textTheme.titleMedium,
          children: <TextSpan>[
            TextSpan(
              text: setting.value.defaultCurrency,
              style: style == null
                  ? Theme.of(context).textTheme.titleMedium?.merge(
                TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: Theme.of(context)
                        .textTheme
                        .titleMedium
                    !.fontSize! -
                        6),
              )
                  : style.merge(TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: style.fontSize! - 6)),
            ),
          ],
        ),
      );
    } catch (e) {
      return Text('');
    }
  }

  static double getTotalOrderPrice(FoodOrder foodOrder) {
    double total = foodOrder.price;
    
    // استخدام الدالة الجديدة لحساب سعر الإضافات مع مراعاة max_allowed و extra_charge
    if (foodOrder.food != null && foodOrder.food!.extraGroups.isNotEmpty) {
      total += calculateExtrasPrice(foodOrder.extras, foodOrder.food!.extraGroups);
    } else {
      // الحساب القديم إذا لم تكن هناك مجموعات إضافات
      if (foodOrder.extras.isNotEmpty) {
        foodOrder.extras.forEach((extra) {
          total += extra.price;
        });
      }
    }
    
    total *= foodOrder.quantity;
    return total;
  }

  static double getOrderPrice(FoodOrder foodOrder) {
    double total = foodOrder.price;
    
    // استخدام الدالة الجديدة لحساب سعر الإضافات مع مراعاة max_allowed و extra_charge
    if (foodOrder.food != null && foodOrder.food!.extraGroups.isNotEmpty) {
      total += calculateExtrasPrice(foodOrder.extras, foodOrder.food!.extraGroups);
    } else {
      // الحساب القديم إذا لم تكن هناك مجموعات إضافات
      if (foodOrder.extras.isNotEmpty) {
        foodOrder.extras.forEach((extra) {
          total += extra.price;
        });
      }
    }
    
    return total;
  }

  static double getTaxOrder(Order order) {
    // تم إزالة حساب الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
    print('🔍 تم إزالة حساب الضريبة للطلب ${order.id} لأن الأسعار تدخل مع الضريبة مسبقاً');
    return 0.0;
  }

  static double getFoodTotalPrice(Order order) {
    print('🔍 حساب إجمالي الطعام للطلب ${order.id}:');
    print('   - عدد الأطعمة: ${order.foodOrders.length}');
    
    double foodTotal = 0;
    if (order.foodOrders.isNotEmpty) {
      order.foodOrders.forEach((foodOrder) {
        double foodPrice = getTotalOrderPrice(foodOrder);
        foodTotal += foodPrice;
        print('   - سعر الطعام: $foodPrice');
      });
    } else {
      print('   - ⚠️ لا توجد أطعمة في الطلب');
    }
    
    print('   - إجمالي الطعام: $foodTotal');
    return foodTotal;
  }

  static double getTotalOrdersPrice(Order order) {
    print('🔍 حساب المجموع الكلي للطلب ${order.id}:');
    print('   - عدد الأطعمة: ${order.foodOrders.length}');
    print('   - رسوم التوصيل: ${order.deliveryFee}');
    
    double foodTotal = 0;
    if (order.foodOrders.isNotEmpty) {
      order.foodOrders.forEach((foodOrder) {
        double foodPrice = getTotalOrderPrice(foodOrder);
        foodTotal += foodPrice;
        print('   - سعر الطعام: $foodPrice');
      });
    } else {
      print('   - ⚠️ لا توجد أطعمة في الطلب');
    }
    
    // تم إزالة حساب الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
    // المجموع الكلي = سعر الطعام + رسوم التوصيل
    double total = foodTotal + order.deliveryFee;
    
    print('   - إجمالي الطعام: $foodTotal');
    print('   - المجموع الكلي: $total');
    
    return total;
  }

  static String getDistance(double distance, String unit) {
    print('🔍 ===== GET DISTANCE DEBUG START =====');
    print('🔍 INPUT DISTANCE: $distance');
    print('🔍 INPUT UNIT: $unit');
    
    // تحويل المسافة للوحدة المطلوبة
    if (unit == 'km' || unit.contains('km')) {
      // إذا كانت المسافة بالمايل، نحولها للكيلومتر
      distance *= 1.60934;
    }
    
    print('🔍 CONVERTED DISTANCE: $distance');
    print('🔍 FINAL RESULT: ${distance.toStringAsFixed(2)} $unit');
    print('🔍 ===== GET DISTANCE DEBUG END =====');
    
    return distance.toStringAsFixed(2) + " " + unit;
  }

  static bool canDelivery(Restaurant _restaurant, {List<Cart> carts = const []}) {
    print('🔍 ===== CAN DELIVERY DEBUG START =====');
    print('🔍 RESTAURANT: ${_restaurant.name}');
    print('🔍 RESTAURANT LATITUDE: ${_restaurant.latitude}');
    print('🔍 RESTAURANT LONGITUDE: ${_restaurant.longitude}');
    print('🔍 RESTAURANT DELIVERY RANGE: ${_restaurant.deliveryRange}');
    print('🔍 RESTAURANT AVAILABLE FOR DELIVERY: ${_restaurant.availableForDelivery}');
    
    bool _can = true;
    String _unit = setting.value.distanceUnit;
    double _deliveryRange = _restaurant.deliveryRange;
    double _distance = _restaurant.distance;
    
    print('🔍 INITIAL DISTANCE: $_distance');
    print('🔍 DELIVERY RANGE: $_deliveryRange');
    print('🔍 DELIVERY ADDRESS: ${deliveryAddress.value.address}');
    print('🔍 DELIVERY ADDRESS LATITUDE: ${deliveryAddress.value.latitude}');
    print('🔍 DELIVERY ADDRESS LONGITUDE: ${deliveryAddress.value.longitude}');
    
    // التحقق من أن الطعام قابل للتوصيل
    for (Cart _cart in carts) {
      _can &= _cart.food!.deliverable;
    }
    
    // تحويل الوحدة إذا لزم الأمر
    if (_unit == 'km') {
      _deliveryRange /= 1.60934;
    }
    
    // حساب المسافة إذا لم تكن محسوبة
    if (_distance == 0 && !deliveryAddress.value.isUnknown()) {
      try {
        double restaurantLat = double.tryParse(_restaurant.latitude) ?? 0.0;
        double restaurantLng = double.tryParse(_restaurant.longitude) ?? 0.0;
        double userLat = deliveryAddress.value.latitude ?? 0.0;
        double userLng = deliveryAddress.value.longitude ?? 0.0;
        
        if (restaurantLat != 0.0 && restaurantLng != 0.0 && userLat != 0.0 && userLng != 0.0) {
          _distance = sqrt(pow(
            69.1 * (restaurantLat - userLat), 2) +
            pow(69.1 * (userLng - restaurantLng) * cos(restaurantLat / 57.3), 2));
        }
      } catch (e) {
        print('🔍 ERROR CALCULATING DISTANCE: $e');
        _distance = 0.0;
      }
    }
    
    print('🔍 CALCULATED DISTANCE: $_distance');
    print('🔍 FINAL DELIVERY RANGE: $_deliveryRange');
    print('🔍 DISTANCE < DELIVERY RANGE: ${_distance < _deliveryRange}');
    
    // التحقق من شروط التوصيل
    _can &= _restaurant.availableForDelivery &&
        (_distance < _deliveryRange) &&
        !deliveryAddress.value.isUnknown();
    
    print('🔍 FINAL RESULT: $_can');
    print('🔍 ===== CAN DELIVERY DEBUG END =====');
    
    return _can;
  }

  static String skipHtml(String htmlString) {
    try {
      var document = parse(htmlString);
      String parsedString = parse(document.body!.text).documentElement!.text;
      return parsedString;
    } catch (e) {
      return '';
    }
  }

  static Html applyHtml(context, String html, {TextStyle? style}) {
    return Html(
      data: html ?? '',
      style: {
        "*": Style(
          padding: HtmlPaddings.all(0),
          margin: Margins.all(0),
          color: Theme.of(context).hintColor,
          fontSize: FontSize(16.0),
          display: Display.inlineBlock,
          width: Width(100),//config.App(context).appWidth(100),
        ),
        "h4,h5,h6": Style(
          fontSize: FontSize(18.0),
        ),
        "h1,h2,h3": Style(
          fontSize: FontSize.xLarge,
        ),
        "br": Style(
          height: Height(0), //0,
        ),
        "p": Style(
          fontSize: FontSize(16.0),
        )
      },
    );
  }

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Theme.of(context).primaryColor.withOpacity(0.85),
          child: CircularLoadingWidget(height: 200),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader.remove();
      } catch (e) {}
    });
  }

  static String limitString(String text,
      {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) +
        (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(GlobalConfiguration().getValue('base_url')).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(GlobalConfiguration().getValue('base_url')).scheme,
        host: Uri.parse(GlobalConfiguration().getValue('base_url')).host,
        port: Uri.parse(GlobalConfiguration().getValue('base_url')).port,
        path: _path + path);
    return uri;
  }

  Color getColorFromHex(String hex) {
    if (hex.contains('#')) {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } else {
      return Color(int.parse("0xFF" + hex));
    }
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static AlignmentDirectional getAlignmentDirectional(
      String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: S.of(context).tapAgainToLeave);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return S.of(context).order_status_changed;
      case "App\\Notifications\\NewOrder":
        return S.of(context).new_order_from_client;
      case "App\\Notifications\\NewMessage":
        return S.of(context).newMessageFrom;
      case "App\\Notifications\\OrderCancelled":
        return "Order Cancelled";
      case "App\\Notifications\\OrderCompleted":
        return "Order Completed";
      case "App\\Notifications\\OrderDelivered":
        return "Order Delivered";
      case "App\\Notifications\\PaymentReceived":
        return "Payment Received";
      case "km":
        return S.of(context).km;
      case "mi":
        return S.of(context).mi;
      default:
        return text.split('\\').last.replaceAll('_', ' ');
    }
  }

  /// حساب سعر الإضافات مع مراعاة max_allowed و max_charge
  static double calculateExtrasPrice(List<Extra> extras, List<ExtraGroup> extraGroups) {
    if (extras.isEmpty) {
      return 0.0;
    }

    double totalPrice = 0.0;

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
      ExtraGroup? extraGroup = extraGroups.firstWhere(
        (group) => group.id == groupId,
        orElse: () => ExtraGroup(),
      );

      if (extraGroup.id.isEmpty) {
        // إذا لم نجد المجموعة، نستخدم السعر العادي
        for (var extra in groupExtras) {
          totalPrice += extra.price;
        }
        continue;
      }

      // تطبيق منطق max_allowed و max_charge
      if (extraGroup.maxAllowed != null && groupExtras.length > extraGroup.maxAllowed!) {
        // عدد الإضافات يتجاوز الحد المسموح
        int allowedCount = extraGroup.maxAllowed!;
        
        // حساب سعر الإضافات المسموحة
        for (int i = 0; i < allowedCount && i < groupExtras.length; i++) {
          totalPrice += groupExtras[i].price;
        }
        
        // إضافة الرسوم الإضافية للإضافات التي تتجاوز الحد
        for (int i = allowedCount; i < groupExtras.length; i++) {
          final extra = groupExtras[i];
          final perItemCharge = (extra.extraCharge > 0) ? extra.extraCharge : extraGroup.maxCharge;
          totalPrice += extra.price + perItemCharge;
        }
      } else {
        // عدد الإضافات ضمن الحد المسموح أو لا يوجد حد
        for (var extra in groupExtras) {
          totalPrice += extra.price;
        }
      }
    }

    return totalPrice;
  }
}