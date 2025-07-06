import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/map_controller.dart';
import '../../elements/CardsCarouselWidget.dart';
import '../../models/restaurant.dart';
import '../../models/route_argument.dart';

class MapWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  MapWidget({Key? key, this.routeArgument, this.parentScaffoldKey})
    : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends StateMVC<MapWidget> {
  late MapController _con;

  _MapWidgetState() : super(MapController()) {
    _con = controller as MapController;
  }

  @override
  void initState() {
    super.initState();
    _con.getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.routeArgument?.param is Restaurant) {
        // Single restaurant view with directions
        _con.currentRestaurant = widget.routeArgument?.param as Restaurant;
        _con.getRestaurantLocation();
        _con.getDirectionSteps();
      } else {
        // Show all nearby restaurants
        _con.currentRestaurant = Restaurant(id: 'all');
        _con.getCurrentLocation();
        _con.getRestaurantsOfArea();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: Theme.of(context).appBarTheme.centerTitle ?? true,
        leading: _con.currentRestaurant.latitude == null
            ? IconButton(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        )
            : IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.of(context).pushNamed('/Pages', arguments: 2),
        ),
        title: Text(
          S.of(context).maps_explorer,
          style: Theme.of(context).appBarTheme.titleTextStyle?.merge(
            const TextStyle(letterSpacing: 1.3),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.my_location, color: Theme.of(context).appBarTheme.iconTheme?.color),
            onPressed: _con.goCurrentLocation,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Theme.of(context).appBarTheme.iconTheme?.color),
            onPressed: () => widget.parentScaffoldKey?.currentState?.openEndDrawer(),
          ),
        ],
      ),

      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          _con.cameraPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                mapToolbarEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition:
                    _con.cameraPosition ??
                    CameraPosition(target: LatLng(40, 3), zoom: 4),
                markers: Set.from(_con.allMarkers),
                onMapCreated: (GoogleMapController controller) {
                  _con.mapController.complete(controller);
                },
                onCameraMove: _con.onCameraMove,
                onCameraIdle: () {},
                polylines: _con.polylines,
                minMaxZoomPreference: MinMaxZoomPreference(10, 18),
              ),
          if (_con.topRestaurants.isNotEmpty)
            CardsCarouselWidget(
              restaurantsList: _con.topRestaurants,
              heroTag: 'map_restaurants',
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _con.dispose();
    super.dispose();
  }
}
