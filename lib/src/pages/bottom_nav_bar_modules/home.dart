import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/FoodsCarouselWidget.dart' show FoodsCarouselWidget;
import '../../models/route_argument.dart';
import '../../repository/settings_repository.dart' as settingsRepo;

// الأقسام المفصولة
import '../Home/home_categories_section.dart' show HomeCategoriesSection;
import '../Home/home_cuisines_section.dart' show HomeCuisinesSection;
import '../Home/home_delivery_pickup_section.dart' show HomeDeliveryPickupSection;
import '../Home/home_header_section.dart' show HomeHeaderSection;
import '../Home/home_popular_section.dart' show HomePopularSection;
import '../Home/home_search_section.dart' show HomeSearchSection;
import '../Home/home_slider_section.dart' show HomeSliderSection;
import '../Home/home_top_restaurants_section.dart' show HomeTopRestaurantsSection;
import '../Home/home_trending_section.dart' show HomeTrendingSection;

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  const HomeWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  late HomeController _con;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller as HomeController;

    @override
    void initState() {
      super.initState();
      _con.getCurrentLocation().then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderSection(
                  currentLocationName: _con.currentLocationName,
                  onChangeLocation: () async {
                    await _con.getCurrentLocation();
                    setState(() {});
                  },
                  parentScaffoldKey: widget.parentScaffoldKey,
                ),
                ...settingsRepo.setting.value.homeSections.map((section) {
                  switch (section) {
                    case 'search':
                      return HomeSearchSection(
                        onClickFilter: (event) {
                          widget.parentScaffoldKey?.currentState?.openEndDrawer();
                        },
                      );
                    case 'slider':
                      return HomeSliderSection(slides: _con.slides);
                    case 'top_restaurants_heading':
                      return HomeDeliveryPickupSection(
                        scaffoldKey: widget.parentScaffoldKey,
                        onRefresh: _con.refreshHome,
                      );
                    case 'top_restaurants':
                      return Column(
                        children: [
                          HomeTopRestaurantsSection(
                            restaurants: _con.topRestaurants,
                          ),
                          // إضافة قسم "ماذا ترغب اليوم؟"
                          _buildCravingSection(),
                          // إضافة قسم "القريبة منك"
                          _buildNearbyStoresSection(),
                        ],
                      );
                    case 'trending_week':
                      return _con.trendingFoods.isEmpty
                          ? SizedBox()
                          : FoodsCarouselWidget(
                        foodsList: _con.trendingFoods,
                        heroTag: 'home_food_carousel',
                      );
                    case 'categories':
                      return HomeCuisinesSection(
                        cuisines: _con.cuisines,
                      );
                    case 'popular':
                      return HomePopularSection(
                        restaurants: _con.popularRestaurants,
                      );
                    default:
                      return SizedBox.shrink();
                  }
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCravingSection() {
    // قائمة الخيارات السريعة مع الأيقونات
    final List<Map<String, dynamic>> quickOptions = [
      {'name': 'وجبة سريعة', 'emoji': '🍔', 'cuisineType': 'fast_food'},
      {'name': 'حلويات', 'emoji': '🍰', 'cuisineType': 'desserts'},
      {'name': 'مشاوي', 'emoji': '🍗', 'cuisineType': 'grill'},
      {'name': 'إيطالي', 'emoji': '🍝', 'cuisineType': 'italian'},
      {'name': 'نباتي', 'emoji': '🥗', 'cuisineType': 'vegetarian'},
      {'name': 'سوشي', 'emoji': '🍣', 'cuisineType': 'sushi'},
      {'name': 'عصائر', 'emoji': '🥤', 'cuisineType': 'beverages'},
    ];

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '🔹 ماذا ترغب اليوم؟',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: quickOptions.length,
              itemBuilder: (context, index) {
                final option = quickOptions[index];
                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _navigateToCuisineRestaurants(option['cuisineType'], option['name']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Main content area
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Emoji icon
                                  Text(
                                    option['emoji'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 3),
                                  // Name text - centered
                                  Text(
                                    option['name'],
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: Color(0xFF272727),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyStoresSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔹 القريبة منك',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Shops Near You',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          
          // عرض حالة التحميل
          if (_con.isLoadingNearbyStores)
            Container(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'جاري البحث عن المتاجر القريبة...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // عرض المطاعم إذا وجدت
          else if (_con.nearbyStores.isNotEmpty)
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 15),
                itemCount: _con.nearbyStores.length,
                itemBuilder: (context, index) {
                  final restaurant = _con.nearbyStores[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/Details',
                          arguments: RouteArgument(
                            id: "0",
                            param: restaurant.id,
                            heroTag: 'nearby_stores',
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).focusColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // صورة المطعم
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(
                                restaurant.image.url,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // معلومات المطعم
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF272727),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    restaurant.address,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9D9FA4),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Color(0xFF9D9FA4),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${restaurant.distance.toStringAsFixed(1)} km',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9D9FA4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          // عرض رسالة إذا لم توجد مطاعم
          else
            Container(
              height: 150,
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
                      'لا توجد متاجر قريبة حالياً',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'سيتم إضافة المتاجر القريبة قريباً',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToCuisineRestaurants(String cuisineType, String cuisineName) {
    // البحث عن المطاعم المرتبطة بهذا النوع من المطبخ
    final matchingCuisines = _con.cuisines.where((cuisine) => 
      cuisine.name.toLowerCase().contains(cuisineType.toLowerCase()) ||
      cuisine.description.toLowerCase().contains(cuisineType.toLowerCase())
    ).toList();

    if (matchingCuisines.isNotEmpty) {
      // إذا وجد مطابخ مطابقة، انتقل إلى صفحة تفاصيل المطبخ
      Navigator.pushNamed(
        context, 
        '/Cuisine',
        arguments: RouteArgument(id: matchingCuisines.first.id, param: matchingCuisines.first),
      );
    } else {
      // إذا لم يجد مطابخ مطابقة، انتقل إلى صفحة المطاعم عبر bottom navigation
      // يمكن إضافة فلتر لاحقاً
      Navigator.pushNamed(context, '/Pages', arguments: 1);
    }
  }
}