import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/CardsCarouselWidget.dart';
import '../../models/restaurant.dart';

class HomeTopRestaurantsSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const HomeTopRestaurantsSection({
    Key? key,
    required this.restaurants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).offers_near_you,
                style: TextStyle(
                  //fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 21,
                  height: 1.6,
                  color: Colors.black,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(context, '/OffersNearYou');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF2196F3).withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          S.of(context).see_all,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF2196F3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CardsCarouselWidget(
          restaurantsList: restaurants,
          heroTag: 'home_top_restaurants',
        ),
      ],
    );
  }
}