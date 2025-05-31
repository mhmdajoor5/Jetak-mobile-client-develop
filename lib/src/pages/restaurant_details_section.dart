import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart' show ImageThumbCarouselWidget;
import '../elements/ReviewsListWidget.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'menu_list.dart';
import '../controllers/restaurant_controller.dart';

class RestaurantDetailsSection extends StatelessWidget {
  final RestaurantController con;
  final List<Cart> cart;
  final void Function(Food) addToCart;

  const RestaurantDetailsSection({
    Key? key,
    required this.con,
    required this.cart,
    required this.addToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SvgPicture.asset('assets/img/star.svg'),
                const SizedBox(width: 6),
                Text(
                  con.restaurant?.rate ?? '0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 16, color: Colors.grey.shade300),
                const SizedBox(width: 10),
                SvgPicture.asset('assets/img/routing.svg'),
                const SizedBox(width: 4),
                Text(
                  Helper.getDistance(
                    con.restaurant!.distance,
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
          ),
          const SizedBox(height: 20),
          ImageThumbCarouselWidget(galleriesList: con.galleries),
          MenuWidget(routeArgument: RouteArgument(param: con.restaurant)),
          if (con.featuredFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.restaurant, color: Theme.of(context).hintColor),
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
                leading: Icon(Icons.recent_actors, color: Theme.of(context).hintColor),
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