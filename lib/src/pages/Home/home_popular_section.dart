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
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            // leading: Icon(
            //   Icons.trending_up,
            //   color: Theme.of(context).hintColor,
            // ),
            title: Text(
              S.of(context).most_popular,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        CardsCarouselWidget(
          restaurantsList: restaurants,
          heroTag: 'home_popular_restaurants',
        ),
      ],
    );
  }
}