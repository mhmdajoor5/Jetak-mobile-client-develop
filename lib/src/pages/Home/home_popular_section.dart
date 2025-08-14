import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/CardsCarouselWidget.dart';
import '../../models/restaurant.dart';

class HomePopularSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const HomePopularSection({
    Key? key,
    required this.restaurants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return SizedBox.shrink();
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
        // استخدام نفس كرت المنتجات المقترحة (CardWidget) عبر CardsCarouselWidget
        CardsCarouselWidget(
          restaurantsList: restaurants,
          heroTag: 'home_popular_restaurants',
        ),
      ],
    );
  }
}