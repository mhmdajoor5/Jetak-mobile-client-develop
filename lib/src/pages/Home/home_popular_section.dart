import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/GridWidget.dart';
import '../../models/restaurant.dart';

class HomePopularSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const HomePopularSection({
    Key? key,
    required this.restaurants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.trending_up,
              color: Theme.of(context).hintColor,
            ),
            title: Text(
              S.of(context).most_popular,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridWidget(
            restaurantsList: restaurants,
            heroTag: 'home_restaurants',
          ),
        ),
      ],
    );
  }
}