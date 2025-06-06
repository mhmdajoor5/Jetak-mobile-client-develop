import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/FoodsCarouselWidget.dart';
import '../../models/food.dart';

class HomeTrendingSection extends StatelessWidget {
  final List<Food> trendingFoods;

  const HomeTrendingSection({
    Key? key,
    required this.trendingFoods,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(
            Icons.trending_up,
            color: Theme.of(context).hintColor,
          ),
          title: Text(
            S.of(context).trending_this_week,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFamily: 'Nunito'),
          ),
          subtitle: Text(
            S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Nunito'),
          ),
        ),
        FoodsCarouselWidget(
          foodsList: trendingFoods,
          heroTag: 'home_food_carousel',
        ),
      ],
    );
  }
}