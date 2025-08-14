import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/FoodsCarouselWidget.dart' show FoodsCarouselWidget;
import '../../models/cuisine.dart';
import '../../models/route_argument.dart';
import '../../repository/settings_repository.dart' as settingsRepo;

// الأقسام المفصولة
import '../Home/home_categories_section.dart' show HomeCategoriesSection;
import '../Home/home_cuisines_section.dart' show HomeCuisinesSection;
import '../Home/home_delivery_pickup_section.dart' show HomeDeliveryPickupSection;
import '../Home/home_header_section.dart' show HomeHeaderSection;
import '../Home/home_order_again_section.dart' show HomeOrderAgainSection;
import '../Home/home_popular_section.dart' show HomePopularSection;
import '../Home/home_newly_added_section.dart' show HomeNewlyAddedSection;
import '../Home/home_search_section.dart' show HomeSearchSection;
import '../Home/home_slider_section.dart' show HomeSliderSection;
import '../Home/home_top_restaurants_section.dart' show HomeTopRestaurantsSection;
import '../Home/home_trending_section.dart' show HomeTrendingSection;
import '../Home/home_suggested_products_section.dart' show HomeSuggestedProductsSection;

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
  }

  @override
  void initState() {
    super.initState();
    _con.getCurrentLocation().then((_) => setState(() {}));
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
                      return _con.slides.isEmpty ? SizedBox.shrink() : HomeSliderSection(slides: _con.slides);
                    case 'top_restaurants_heading':
                      return HomeDeliveryPickupSection(
                        scaffoldKey: widget.parentScaffoldKey,
                        onRefresh: _con.refreshHome,
                      );
                    case 'top_restaurants':
                      return _con.topRestaurants.isEmpty && _con.storeCuisines.isEmpty && _con.nearbyStores.isEmpty
                          ? SizedBox.shrink()
                          : Column(
                        children: [
                          if (_con.topRestaurants.isNotEmpty)
                            HomeTopRestaurantsSection(
                              restaurants: _con.topRestaurants,
                            ),
                          // إضافة قسم "ماذا ترغب اليوم؟" لمطابخ المتاجر (type=store)
                          if (_con.storeCuisines.isNotEmpty) _buildCravingSection(),
                          // // إضافة قسم المتاجر
                          // _buildStoresSection(),
                          // إضافة قسم "القريبة منك"
                          if (_con.nearbyStores.isNotEmpty || _con.isLoadingNearbyStores)
                            _buildNearbyStoresSection(),
                          // إضافة قسم "إعادة الطلب"
                          // إظهار "إعادة الطلب" دائماً غير متعلق ببيانات
                          HomeOrderAgainSection(),
                          // إضافة قسم "جديد في التطبيق"
                          HomeNewlyAddedSection(),
                          // إضافة قسم "المنتجات المقترحة"
                          if (_con.suggestedProducts.isNotEmpty)
                            HomeSuggestedProductsSection(
                              suggestedProducts: _con.suggestedProducts,
                            ),
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
                      // إضافة قسم منفصل للمطابخ العامة
                      return Column(
                        children: [
                          // قسم مطابخ المطاعم
                          if (_con.restaurantCuisines.isNotEmpty)
                            HomeCuisinesSection(
                              cuisines: _con.restaurantCuisines,
                            ),
                        ],
                      );
                    case 'popular':
                      return _con.popularRestaurants.isEmpty
                          ? SizedBox.shrink()
                          : HomePopularSection(
                              restaurants: _con.popularRestaurants,
                            );
                    case 'order_again':
                      return HomeOrderAgainSection();
                    case 'newly_added':
                      return HomeNewlyAddedSection();
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
    // استخدام مطابخ المتاجر القادمة من API (type=store)
    final List<Cuisine> quickOptions = _con.storeCuisines.take(7).toList();

    // إذا لم توجد بيانات من API، إخفاء القسم تماماً
    if (quickOptions.isEmpty) {
      print("mElkerm Debug: No cuisines available, hiding craving section");
      return SizedBox.shrink(); // إخفاء القسم إذا لم توجد بيانات
    }

    print("mElkerm Debug: Showing craving section with ${quickOptions.length} cuisines");

    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              S.of(context).what_would_you_like_today,
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: quickOptions.length,
              itemBuilder: (context, index) {
                final cuisine = quickOptions[index];
                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _navigateToCuisineRestaurants(cuisine);
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
                                  // صورة المطبخ أو أيقونة افتراضية
                                  cuisine.image.url.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            cuisine.image.url,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return _getDefaultEmoji(cuisine.name);
                                            },
                                          ),
                                        )
                                      : _getDefaultEmoji(cuisine.name),
                                  SizedBox(height: 3),
                                  // اسم المطبخ
                                  Text(
                                    cuisine.name,
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

  // دالة مساعدة لإرجاع أيقونة افتراضية بناءً على اسم المطبخ
  Widget _getDefaultEmoji(String cuisineName) {
    String emoji = '🍽️'; // أيقونة افتراضية
    
    // تحديد الأيقونة المناسبة بناءً على اسم المطبخ
    if (cuisineName.toLowerCase().contains('fast') || cuisineName.toLowerCase().contains('سريع')) {
      emoji = '🍔';
    } else if (cuisineName.toLowerCase().contains('dessert') || cuisineName.toLowerCase().contains('حلو')) {
      emoji = '🍰';
    } else if (cuisineName.toLowerCase().contains('grill') || cuisineName.toLowerCase().contains('مشوي')) {
      emoji = '🍗';
    } else if (cuisineName.toLowerCase().contains('italian') || cuisineName.toLowerCase().contains('إيطالي')) {
      emoji = '🍝';
    } else if (cuisineName.toLowerCase().contains('vegetarian') || cuisineName.toLowerCase().contains('نباتي')) {
      emoji = '🥗';
    } else if (cuisineName.toLowerCase().contains('sushi') || cuisineName.toLowerCase().contains('سوشي')) {
      emoji = '🍣';
    } else if (cuisineName.toLowerCase().contains('beverage') || cuisineName.toLowerCase().contains('عصير')) {
      emoji = '🥤';
    }
    
    return Text(
      emoji,
      style: TextStyle(fontSize: 20),
    );
  }

  Widget _buildNearbyStoresSection() {
    // إخفاء القسم إذا لم توجد متاجر قريبة
    if (_con.nearbyStores.isEmpty && !_con.isLoadingNearbyStores) {
      print("mElkerm Debug: No nearby stores available, hiding nearby stores section");
      return SizedBox.shrink();
    }

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
                  S.of(context).near_you,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  S.of(context).shops_near_you,
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
                      S.of(context).searching_for_nearby_stores,
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
                padding: EdgeInsets.symmetric(horizontal: 20),
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
            ),
        ],
      ),
    );
  }

  // إضافة قسم منفصل للمتاجر
  Widget _buildStoresSection() {
    final List<Cuisine> storeOptions = _con.storeCuisines.take(7).toList();

    if (storeOptions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              S.of(context).nearby_stores,
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: storeOptions.length,
              itemBuilder: (context, index) {
                final store = storeOptions[index];
                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _navigateToStoreCuisine(store);
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  store.image.url.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            store.image.url,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.store, size: 20);
                                            },
                                          ),
                                        )
                                      : Icon(Icons.store, size: 20),
                                  SizedBox(height: 3),
                                  Text(
                                    store.name,
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

  // تحديث دالة التنقل
  void _navigateToCuisineRestaurants(Cuisine cuisine) {
    Navigator.pushNamed(
      context, 
      '/Cuisine',
      arguments: RouteArgument(id: cuisine.id, param: cuisine),
    );
  }

  void _navigateToStoreCuisine(Cuisine store) {
    // يمكن تخصيص التنقل للمتاجر هنا
    Navigator.pushNamed(
      context, 
      '/Cuisine',
      arguments: RouteArgument(id: store.id, param: store),
    );
  }
}