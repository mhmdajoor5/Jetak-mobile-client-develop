import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'RestaurantWidget.dart';

class DetailsWidget extends StatefulWidget {
  late final RouteArgument routeArgument;
  dynamic currentTab;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  // DetailsWidget({Key? key, required this.currentTab}) {
  //   if (currentTab != null) {
  //     if (currentTab is RouteArgument) {
  //       routeArgument = currentTab;
  //       currentTab = int.parse(currentTab.id);
  //     }
  //   } else {
  //     currentTab = 0;
  //   }
  // }
  // Modified constructor

  // DetailsWidget({
  //   Key? key,
  //   this.currentTab,
  //   required this.routeArgument, // Receive routeArgument directly
  // }) : super(key: key);

  DetailsWidget({
    Key? key,
    required this.routeArgument,
  }) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  late RestaurantController _con;
  bool _isLoading = true;

  _DetailsWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  void _loadRestaurant() async {
    try {
      if (widget.routeArgument.param is Restaurant) {
        if (mounted) {
          setState(() {
            _con.restaurant = widget.routeArgument.param as Restaurant;
            _isLoading = false;
          });
        }
      } else if (widget.routeArgument.param is String) {
        final value = await _con.listenForRestaurant(
          id: widget.routeArgument.param as String,
        );
        if (mounted) {
          setState(() {
            _con.restaurant = value as Restaurant;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading restaurant: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // @override
  // void didUpdateWidget(DetailsWidget oldWidget) {
  // _selectTab(oldWidget.currentTab);
  // super.didUpdateWidget(oldWidget);
  // }

  // void _selectTab(int tabItem) {
  //   setState(() {
  //     widget.currentTab = tabItem;
  //     switch (tabItem) {
  //       case 0:
  //         _con.listenForRestaurant(id: widget.routeArgument.param).then((
  //             value) {
  //           setState(() {
  //             _con.restaurant = value as Restaurant;
  //             print(_con.restaurant.toMap());
  //             widget.currentPage = ;
  //           });
  //         });
  //         break;
  //       case 1:
  //         if (currentUser.value.apiToken == null) {
  //           widget.currentPage = PermissionDeniedWidget();
  //         } else {
  //           Conversation _conversation = new Conversation(
  //               _con.restaurant.users.map((e) {
  //                 e.image = _con.restaurant.image;
  //                 return e;
  //               }).toList(),
  //               name: _con.restaurant.name);
  //           widget.currentPage = ChatWidget(
  //               parentScaffoldKey: widget.scaffoldKey,
  //               routeArgument: RouteArgument(
  //                   id: _con.restaurant.id, param: _conversation));
  //         }
  //         break;
  //       case 2:
  //         widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey,
  //             routeArgument: RouteArgument(param: _con.restaurant));
  //         break;
  //     // case 3:
  //     //   widget.currentPage = MenuWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: RouteArgument(param: _con.restaurant));
  //     //   break;
  //     }
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   if (_isLoading) {
  //     return Scaffold(
  //       key: widget.scaffoldKey,
  //       drawer: DrawerWidget(),
  //       body: CircularLoadingWidget(height: 500),
  //     );
  //   }
  //
  //   if (_con.restaurant!.id.isEmpty) {
  //     return Scaffold(
  //       key: widget.scaffoldKey,
  //       drawer: DrawerWidget(),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               Icons.error_outline,
  //               size: 48,
  //               color: Theme.of(context).colorScheme.error,
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               S.of(context).verify_your_internet_connection,
  //               textAlign: TextAlign.center,
  //               style: Theme.of(context).textTheme.titleMedium,
  //             ),
  //             SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: _loadRestaurant,
  //               child: Text(S.of(context).verify),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Scaffold(
  //     key: widget.scaffoldKey,
  //     drawer: DrawerWidget(),
  //     body: RestaurantWidget(
  //       parentScaffoldKey: widget.scaffoldKey,
  //       routeArgument: RouteArgument(param: _con.restaurant),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: CircularLoadingWidget(height: 500),
      );
    }

    if (_con.restaurant == null || _con.restaurant!.id.isEmpty) {
      return Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).verify_your_internet_connection,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRestaurant,
                child: Text(S.of(context).verify),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: widget.scaffoldKey,
      drawer: DrawerWidget(),
      body: RestaurantWidget(
        parentScaffoldKey: widget.scaffoldKey,
        routeArgument: RouteArgument(param: _con.restaurant),
      ),
    );
  }
}

