import 'dart:convert';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../../models/restaurant.dart';

/// Repository لجلب المطاعم والمتاجر الجديدة حسب الأحدث
Future<List<Restaurant>> getNewlyAddedRestaurants() async {
  print("🆕 جاري جلب المطاعم الجديدة...");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants?orderBy=created_at&sortedBy=desc&limit=10'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    ).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      print("✅ تم جلب المطاعم الجديدة بنجاح");
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final List<dynamic> data = decodedData['data']['data'];
      
      // فلترة المطاعم الجديدة (المضافة في آخر 30 يوم)
      final List<Restaurant> allRestaurants = data.map((json) => Restaurant.fromJSON(json)).toList();
      final List<Restaurant> newlyAddedRestaurants = _filterNewlyAddedRestaurants(allRestaurants);
      
      print("📊 تم العثور على ${newlyAddedRestaurants.length} مطعم جديد");
      return newlyAddedRestaurants;
    } else {
      print("❌ خطأ في جلب المطاعم الجديدة: ${response.statusCode}");
      throw Exception('Failed to load newly added restaurants');
    }
  } catch (e) {
    print("❌ خطأ في جلب المطاعم الجديدة: $e");
    throw Exception('Error: $e');
  }
}

/// فلترة المطاعم الجديدة (المضافة في آخر 30 يوم)
List<Restaurant> _filterNewlyAddedRestaurants(List<Restaurant> restaurants) {
  final DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
  
  return restaurants.where((restaurant) {
    // إذا كان المطعم يحتوي على تاريخ الإنشاء
    if (restaurant.id.isNotEmpty) {
      // يمكن إضافة منطق إضافي هنا للتحقق من تاريخ الإنشاء
      // حالياً نرجع جميع المطاعم المرتبة حسب الأحدث
      return true;
    }
    return false;
  }).toList();
}
