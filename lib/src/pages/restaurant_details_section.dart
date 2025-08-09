import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart' show ImageThumbCarouselWidget;
import '../elements/ReviewsListWidget.dart';
import '../helpers/app_colors.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/resturant/most_order_model.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'food.dart';
import 'menu_list.dart';
import '../controllers/restaurant_controller.dart';

class RestaurantDetailsSection extends StatelessWidget {
  final RestaurantController con;
  final List<Cart> cart;
  final void Function(Food) addToCart;
  final double userLat;
  final double userLon;

   RestaurantDetailsSection({
    Key? key,
    required this.con,
    required this.cart,
    required this.addToCart,
    required this.userLat,
    required this.userLon,
  }) : super(key: key);

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  @override
  Widget build(BuildContext context) {
    // التحقق من وجود المطعم
    if (con.restaurant == null || con.restaurant!.id.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد بيانات للمطعم',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final restLat = double.tryParse(con.restaurant?.latitude ?? '0') ?? 0.0;
    final restLon = double.tryParse(con.restaurant?.longitude ?? '0') ?? 0.0;
    final distance = calculateDistance(userLat, userLon, restLat, restLon);
    
    print('🔍 ===== RESTAURANT DISTANCE DEBUG START =====');
    print('🔍 USER LATITUDE: $userLat');
    print('🔍 USER LONGITUDE: $userLon');
    print('🔍 RESTAURANT LATITUDE: $restLat');
    print('🔍 RESTAURANT LONGITUDE: $restLon');
    print('🔍 CALCULATED DISTANCE: $distance');
    print('🔍 DISTANCE UNIT: ${setting.value.distanceUnit}');
    print('🔍 ===== RESTAURANT DISTANCE DEBUG END =====');

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              con.restaurant?.name ?? '',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Visibility(
                  visible: false,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/img/star.svg'),
                      SizedBox(width: 6),
                      Text(
                        con.restaurant!.rate ?? '0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 16, width: 1, color: Colors.grey.shade300),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/img/routing.svg'),
                    SizedBox(width: 4),
                    Text(
                      // Helper.getDistance(
                      //   con.restaurant!.distance,
                      //   Helper.of(context).trans(setting.value.distanceUnit),
                      // ),
                      Helper.getDistance(
                        distance,
                        Helper.of(context).trans(setting.value.distanceUnit),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(height: 16, width: 1, color: Colors.grey.shade300),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(
                      con.restaurant!.closed!
                          ? S.of(context).closed
                          : con.restaurant!.closingTime != null && con.restaurant!.closingTime!.isNotEmpty
                          ? S.of(context).open_until(con.restaurant!.closingTime!)
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(height: 16, width: 1, color: Colors.grey.shade300),
                GestureDetector(
                  onTap: () {
                    print('More info tapped!');
                  },
                  child: Text(
                    S.of(context).more,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff26386A),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 2.0,
                      ),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: SvgPicture.asset('assets/img/truck-fast2.svg'),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //SizedBox(width: 5),
                          Text(
                            S.of(context).delivery_20_30_mnt,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          //SizedBox(width: 5),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black87,
                            size: 23,
                          ),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFF0F0F0),
                        side: BorderSide(color: Colors.white, width: 5.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        fixedSize: Size.fromHeight(60),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 5.0),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/img/user-cirlce-add.svg',
                        height: 25,
                        width: 25,
                      ),
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 5.0),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/img/icon-color.svg',
                        width: 18,
                      ),
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          con.popularFoodForRest.isEmpty || con.popularFoodForRest == null
              ? SizedBox()
              : const SizedBox(height: 20),
          con.popularFoodForRest.isEmpty || con.popularFoodForRest == null
              ? SizedBox()
              : MostPopularOrderSection(
                con: con,
                cart: cart,
                addToCart: addToCart,
              ),
          const SizedBox(height: 20),
          ImageThumbCarouselWidget(galleriesList: con.galleries),
          MenuWidget(routeArgument: RouteArgument(param: con.restaurant)),
          if (con.featuredFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).featured_foods,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: con.featuredFoods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final food = con.featuredFoods[index];
                return FoodItemWidget(
                  heroTag: 'details_featured_food',
                  food: food,
                  onAdd: () => addToCart(food),
                );
              },
            ),
          ],
          if (con.reviews.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.recent_actors,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).what_they_say,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class MostPopularOrderSection extends StatelessWidget {
  final RestaurantController con;
  final List<Cart> cart;
  final void Function(Food) addToCart;

  const MostPopularOrderSection({
    Key? key,
    required this.con,
    required this.cart,
    required this.addToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 15.0),
              child: Text(
                S.of(context).most_ordered,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                primary: false,
                itemCount: con.popularFoodForRest.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final _mostOrderModel = con.popularFoodForRest[index];
                  return DessertCard(mostOrderModel: _mostOrderModel);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DessertCard extends StatelessWidget {
  final MostOrderModel mostOrderModel;

  const DessertCard({Key? key, required this.mostOrderModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/Food',
          arguments: RouteArgument(
            id: mostOrderModel.id.toString(),
            heroTag: 'DessertCard_${mostOrderModel.id}',
          ),
        );
      },
      child: Container(
        width: 160,
        height: MediaQuery.of(context).size.height * 0.26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/img/carry-eats-hub-logo.png',
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mostOrderModel.name.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${mostOrderModel.price.toString()}${setting.value.defaultCurrency}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.color26386A,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.color26386A,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
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
    );
  }
}
