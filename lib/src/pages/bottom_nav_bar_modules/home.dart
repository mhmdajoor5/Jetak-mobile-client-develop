import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/FoodsCarouselWidget.dart' show FoodsCarouselWidget;
import '../../repository/settings_repository.dart' as settingsRepo;

// الأقسام المفصولة
import '../Home/home_categories_section.dart' show HomeCategoriesSection;
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
                      return HomeTopRestaurantsSection(
                        restaurants: _con.topRestaurants,
                      );
                    case 'trending_week':
                      return _con.trendingFoods.isEmpty
                          ? SizedBox()
                          : FoodsCarouselWidget(
                        foodsList: _con.trendingFoods,
                        heroTag: 'home_food_carousel',
                      );
                    case 'categories':
                      return HomeCategoriesSection(
                        categories: _con.categories,
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
}