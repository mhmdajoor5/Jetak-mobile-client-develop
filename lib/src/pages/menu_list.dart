import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';

// import '../elements/DrawerWidget.dart'; // لم تعد مستخدمة في هذا الجزء
import '../elements/FoodItemWidget.dart';

// import '../elements/FoodsCarouselWidget.dart'; // لم تعد مستخدمة في هذا الجزء
// import '../elements/SearchBarWidget.dart'; // لم تعد مستخدمة في هذا الجزء
// import '../elements/ShoppingCartButtonWidget.dart'; // لم تعد مستخدمة في هذا الجزء
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  MenuWidget({Key? key, this.parentScaffoldKey, this.routeArgument})
    : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  late RestaurantController _con;

  _MenuWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument?.param as Restaurant;
    // _con.listenForTrendingFoods(_con.restaurant!.id);
    _con.listenForCategories(_con.restaurant!.id);
    // selectedCategories = ['0'];
    // _con.listenForFoods(_con.restaurant!.id, 1);
    // _con.foodPagingController.addPageRequestListener((pageKey) {
    //   _con.listenForFoods(_con.restaurant!.id, pageKey,
    //       categoriesId: selectedCategories);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._con.categories.map((category) {
                final foods = category.foods ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        category.name ?? '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (foods.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(S.of(context).no_items_in_this_category),
                      )
                    else
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foods.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final food = foods[index];
                          return FoodItemWidget(
                            heroTag: 'menu_food_${food.id}_${category.id}',
                            food: food,
                            onAdd: () {},
                          );
                        },
                      ),
                    const SizedBox(height: 30),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
