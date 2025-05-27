import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';


import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/CardsCarouselWidget.dart';
import '../../elements/CaregoriesCarouselWidget.dart';
import '../../elements/DeliveryAddressBottomSheetWidget.dart';
import '../../elements/FoodsCarouselWidget.dart';
import '../../elements/GridWidget.dart';
import '../../elements/HomeSliderWidget.dart';
import '../../elements/NotificationsButtonWidget.dart';
import '../../elements/SearchBarWidget.dart';
import '../../elements/ShoppingCartButtonWidget.dart';
import '../../repository/settings_repository.dart' as settingsRepo;

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  HomeWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  late HomeController _con;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
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
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your location",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9D9FA4),
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Color(0xFF1F2F56), size: 20),
                                SizedBox(width: 4),
                                Text(
                                  "4140 Parker Rd...",
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2F56),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF1F2F56)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Row(
                          children: [
                            NotificationsButtonWidget(notificationCount: 5),
                            SizedBox(width: 15),
                            ShoppingCartButtonWidget(iconColor: Color(0xFF292D32), labelColor: Colors.red),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ...List.generate(settingsRepo.setting.value.homeSections.length, (index) {
                  String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
                  switch (_homeSection) {
                    case 'slider':
                      return HomeSliderWidget(slides: _con.slides);
                    case 'search':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SearchBarWidget(
                          onClickFilter: (event) {
                            widget.parentScaffoldKey?.currentState?.openEndDrawer();
                          },
                        ),
                      );
                    case 'top_restaurants_heading':
                      return Visibility(
                        visible: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      S.of(context).top_restaurants,
                                      style: Theme.of(context).textTheme.headlineLarge,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      var bottomSheetController = widget.parentScaffoldKey?.currentState?.showBottomSheet(
                                            (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey!),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                        ),
                                      );
                                      bottomSheetController?.closed.then((value) {
                                        _con.refreshHome();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: settingsRepo.deliveryAddress.value?.address == null
                                            ? Theme.of(context).focusColor.withOpacity(0.1)
                                            : Theme.of(context).colorScheme.secondary,
                                      ),
                                      child: Text(
                                        S.of(context).delivery,
                                        style: TextStyle(
                                          color: settingsRepo.deliveryAddress.value?.address == null
                                              ? Theme.of(context).hintColor
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        settingsRepo.deliveryAddress.value?.address = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: settingsRepo.deliveryAddress.value?.address != null
                                            ? Theme.of(context).focusColor.withOpacity(0.1)
                                            : Theme.of(context).colorScheme.secondary,
                                      ),
                                      child: Text(
                                        S.of(context).pickup,
                                        style: TextStyle(
                                          color: settingsRepo.deliveryAddress.value?.address != null
                                              ? Theme.of(context).hintColor
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (settingsRepo.deliveryAddress.value?.address != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    S.of(context).near_to + " " + settingsRepo.deliveryAddress.value!.address!,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                    case 'top_restaurants':
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Offers near you',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500, // 500
                                    fontSize: 21, // 16px
                                    height: 1.6, // line height 160%
                                    color: Colors.black, // #000000
                                  ),
                                ),
                                Text(
                                  'See all',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w400, // 400
                                    fontSize: 18, // 14px
                                    height: 1.6, // line height 160%
                                    color: Color(0xFF26386A), // #26386A
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          CardsCarouselWidget(
                            restaurantsList: _con.topRestaurants,
                            heroTag: 'home_top_restaurants',
                          ),
                        ],
                      );

                    case 'trending_week_heading':
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        leading: Icon(Icons.trending_up, color: Theme.of(context).hintColor),
                        title: Text(
                          S.of(context).trending_this_week,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontFamily: 'Nunito',
                          ),
                        ),
                        subtitle: Text(
                          S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Nunito',
                          ),
                        ),
                      );

                    case 'trending_week':
                      return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');
                    // case 'categories_heading':
                    //   return Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 20),
                    //     child: ListTile(
                    //       dense: true,
                    //       contentPadding: EdgeInsets.symmetric(vertical: 0),
                    //       leading: Icon(Icons.category, color: Theme.of(context).hintColor),
                    //       title: Text(S.of(context).food_categories, style: Theme.of(context).textTheme.headlineLarge),
                    //     ),
                    //   );
                    case 'categories':
                      return CategoriesCarouselWidget(categories: _con.categories);
                    case 'popular_heading':
                      return Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(Icons.trending_up, color: Theme.of(context).hintColor),
                          title: Text(S.of(context).most_popular, style: Theme.of(context).textTheme.headlineLarge),
                        ),
                      );
                    case 'popular':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridWidget(restaurantsList: _con.popularRestaurants, heroTag: 'home_restaurants'),
                      );
                    default:
                      return SizedBox(height: 0);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
