import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:restaurantcustomer/generated/l10n.dart';

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

  String _tr(BuildContext context, {required String en, required String ar, required String he}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return ar;
    if (code == 'he') return he;
    return en;
  }

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
      print("🆕 Loading newly added restaurants...");
      final restaurants = await getNewlyAddedRestaurants();
      
      setState(() {
        newlyAddedRestaurants = restaurants;
        isLoading = false;
      });
      
          print("✅ Loaded ${restaurants.length} newly added restaurants");
    } catch (e) {
      print("❌ Error loading newly added restaurants: $e");
      setState(() {
        errorMessage = _tr(context,
            en: 'Error loading newly added restaurants',
            ar: 'حدث خطأ في تحميل المطاعم الجديدة',
            he: 'שגיאה בטעינת המסעדות החדשות');
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
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      _tr(context,
                          en: 'New in the app',
                          ar: 'جديد في التطبيق',
                          he: 'חדש באפליקציה'),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.6,
                        letterSpacing: 0,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/NewlyAddedAll');
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pushNamed(context, '/NewlyAddedAll');
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
                              S.of(context).see_all,
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
          SizedBox(height: 12),
          
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _tr(context,
                  en: 'New restaurants and stores recently added',
                  ar: 'مطاعم ومتاجر جديدة مضافة حديثاً',
                  he: 'מסעדות וחנויות שנוספו לאחרונה'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
          ),
          SizedBox(height: 12),
          
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
                _tr(context,
                    en: 'Loading newly added restaurants...',
                    ar: 'جاري تحميل المطاعم الجديدة...',
                    he: 'טוען מסעדות חדשות...'),
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
                errorMessage ?? _tr(context, en: 'Error', ar: 'حدث خطأ', he: 'שגיאה'),
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
                child: Text(_tr(context, en: 'Retry', ar: 'إعادة المحاولة', he: 'נסה שוב')),
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
                _tr(context,
                    en: 'No new restaurants or stores for now',
                    ar: 'لا توجد مطاعم أو متاجر جديدة حالياً',
                    he: 'אין כרגע מסעדות או חנויות חדשות'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
              Text(
                _tr(context,
                    en: 'New restaurants and stores will be added soon',
                    ar: 'سيتم إضافة مطاعم ومتاجر جديدة قريباً',
                    he: 'מסעדות וחנויות חדשות יתווספו בקרוב'),
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
        padding: EdgeInsets.symmetric(horizontal: 16),
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
                    param: restaurant,
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
                  // "New" badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _tr(context, en: 'New', ar: 'جديد', he: 'חדש'),
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