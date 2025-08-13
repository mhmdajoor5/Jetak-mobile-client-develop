import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../models/restaurant.dart';
import '../../models/media.dart';
import '../../models/route_argument.dart';
import '../../elements/CardWidget.dart';
import '../../repository/home/get_newly_added_restaurants_repo.dart';

class HomeNewlyAddedSection extends StatefulWidget {
  const HomeNewlyAddedSection({Key? key}) : super(key: key);

  @override
  _HomeNewlyAddedSectionState createState() => _HomeNewlyAddedSectionState();
}

class _HomeNewlyAddedSectionState extends StateMVC<HomeNewlyAddedSection> {
  List<Restaurant> newlyAddedRestaurants = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNewlyAddedRestaurants();
  }

  Future<void> _loadNewlyAddedRestaurants() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print("🆕 جاري تحميل المطاعم الجديدة...");
      final restaurants = await getNewlyAddedRestaurants();
      
      setState(() {
        newlyAddedRestaurants = restaurants;
        isLoading = false;
      });
      
      print("✅ تم تحميل ${restaurants.length} مطعم جديد");
    } catch (e) {
      print("❌ خطأ في تحميل المطاعم الجديدة: $e");
      setState(() {
        errorMessage = 'حدث خطأ في تحميل المطاعم الجديدة';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'جديد في التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // التنقل إلى صفحة جميع المطاعم الجديدة
                    Navigator.pushNamed(context, '/Restaurants', arguments: {'type': 'new'});
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // التنقل إلى صفحة جميع المطاعم الجديدة
                        Navigator.pushNamed(context, '/Restaurants', arguments: {'type': 'new'});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF2196F3).withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'يشمل الكل',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          
          // النص التوضيحي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'مطاعم ومتاجر جديدة مضافة حديثاً',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // قائمة المطاعم والمتاجر الجديدة
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState()
          else if (newlyAddedRestaurants.isEmpty)
            _buildEmptyState()
          else
            _buildRestaurantsList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF2196F3),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل المطاعم الجديدة...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red[400],
            ),
            SizedBox(height: 10),
            Text(
              errorMessage ?? 'حدث خطأ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadNewlyAddedRestaurants,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(height: 10),
            Text(
              'لا توجد مطاعم أو متاجر جديدة حالياً',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'سيتم إضافة مطاعم ومتاجر جديدة قريباً',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 26),
        itemCount: newlyAddedRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = newlyAddedRestaurants[index];
          
          return Container(
            width: 292,
            margin: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                // التنقل إلى صفحة تفاصيل المطعم
                Navigator.pushNamed(
                  context,
                  '/Details',
                  arguments: RouteArgument(
                    id: restaurant.id,
                    param: restaurant, // تمرير كائن المطعم مباشرة
                    heroTag: 'home_newly_added_${restaurant.id}',
                  ),
                );
              },
              child: Stack(
                children: [
                  CardWidget(
                    restaurant: restaurant,
                    heroTag: 'home_newly_added_',
                  ),
                  // علامة "جديد" على المطاعم الجديدة
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 