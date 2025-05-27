import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../elements/GridItemWidget.dart';
import '../models/restaurant.dart';
import 'CardWidget.dart' show CardWidget;
import 'grid_card_widget.dart' show GridCardWidget;

class GridWidget extends StatelessWidget {
  final List<Restaurant> restaurantsList;
  final String heroTag;
  final bool shrinkWrap;
  final bool isScrollable;

  GridWidget({Key? key, required this.restaurantsList, required this.heroTag,this.shrinkWrap = false,
    this.isScrollable = true,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return StaggeredGridView.countBuilder(
    //   primary: false,
    //   shrinkWrap: true,
    //   crossAxisCount: 4,
    //   itemCount: restaurantsList.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return GridItemWidget(
    //         restaurant: restaurantsList.elementAt(index), heroTag: heroTag);
    //   },
    //   staggeredTileBuilder: (int index) => StaggeredTile.fit(
    //       MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4),
    //   mainAxisSpacing: 15.0,
    //   crossAxisSpacing: 15.0,
    // );
    return  MasonryGridView.count(
      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      shrinkWrap: shrinkWrap,
      physics: isScrollable ? ScrollPhysics() : NeverScrollableScrollPhysics(),
      //physics: NeverScrollableScrollPhysics(),
      itemCount: restaurantsList.length,
      itemBuilder: (context, index) {
        return GridCardWidget(restaurant: restaurantsList[index]);

      },
    );
  }
}
