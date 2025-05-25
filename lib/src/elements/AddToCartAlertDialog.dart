import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/food.dart';

typedef FoodBoolFunc = void Function(Food food, {bool reset});

class AddToCartAlertDialogWidget extends StatelessWidget {
  final Food oldFood;
  final Food newFood;
  final FoodBoolFunc onPressed;

  const AddToCartAlertDialogWidget({Key? key, required this.oldFood, required this.newFood, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).reset_cart),
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
            child: Text(S.of(context).you_must_add_foods_of_the_same_restaurants_choose_one, style: Theme.of(context).textTheme.bodySmall),
          ),
          _buildRestaurantOption(context, newFood, isNew: true),
          const SizedBox(height: 20),
          _buildRestaurantOption(context, oldFood, isNew: false),
        ],
      ),
      actions: [
        TextButton(
          child: Text(S.of(context).reset),
          onPressed: () {
            onPressed(newFood, reset: true);
            Navigator.of(context).pop();
          },
        ),
        TextButton(child: Text(S.of(context).close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildRestaurantOption(BuildContext context, Food food, {required bool isNew}) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      onTap: () {
        if (isNew) {
          onPressed(newFood, reset: true);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Hero(
              tag: (isNew ? 'new_restaurant' : 'old_restaurant') + (food.restaurant.id ?? ''),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), image: DecorationImage(image: NetworkImage(food.restaurant.image?.thumb ?? ''), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.restaurant.name ?? '', overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(isNew ? S.of(context).reset_your_cart_and_order_meals_form_this_restaurant : S.of(context).keep_your_old_meals_of_this_restaurant, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
