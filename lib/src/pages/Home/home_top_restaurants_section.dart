import 'package:flutter/material.dart';
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
                  //fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 21,
                  height: 1.6,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/OffersNearYou');
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    //fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    height: 1.6,
                    color: Color(0xFF26386A),
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