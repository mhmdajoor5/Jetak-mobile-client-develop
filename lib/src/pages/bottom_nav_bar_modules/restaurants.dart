import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/GridWidget.dart';

/// mElkerm : Bottom nav bar item popular resturant


class RestaurantsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _RestaurantsWidgetState createState() => _RestaurantsWidgetState();
}

class _RestaurantsWidgetState extends StateMVC<RestaurantsWidget> {
  late HomeController _con;

  _RestaurantsWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Theme
              .of(context)
              .hintColor),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S
              .of(context)
              .restaurants,
          style: Theme
              .of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _con.getPopularRestaurants? GridWidget(
                restaurantsList: _con.popularRestaurants,
                heroTag: 'home_restaurants',
                itemCount: 6,
                // shrinkWrap: true,
                // isScrollable: false,
              ) : Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}