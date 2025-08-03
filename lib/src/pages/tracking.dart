import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../generated/l10n.dart';
import '../controllers/tracking_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/order_status.dart';
import '../models/route_argument.dart';
import 'restaurant_location_page.dart';

class TrackingWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  TrackingWidget({Key? key, required this.routeArgument}) : super(key: key);

  @override
  _TrackingWidgetState createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends StateMVC<TrackingWidget> with SingleTickerProviderStateMixin {
  late TrackingController _con;
  late TabController _tabController;
  int _tabIndex = 0;
  bool _showMap = false;
  String? _mapError;

  _TrackingWidgetState() : super(TrackingController()) {
    _con = controller as TrackingController;
  }

  @override
  void initState() {
    _con.listenForOrder(orderId: widget.routeArgument!.id!);
    _con.getOrderDetailsTracking(orderId: widget.routeArgument!.id!);
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this); // Changed to 3 tabs
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // إغلاق اتصال التراكنج المباشر
    _con.disconnectFromDriverTracking();
    super.dispose();
  }

  // void dispose() {
  //   _tabController.dispose();
  //   // إغلاق اتصال التراكنج المباشر
  //   _con.disconnectFromDriverTracking();
  //   super.dispose();
  // }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
        if (_tabIndex == 2) { // Map tab
          _loadDeliveryMap();
        }
      });
    }
  }

  Future<void> _loadDeliveryMap() async {
    // تحقق من إحداثيات العنوان
    bool hasDeliveryCoords = _con.order.deliveryAddress.latitude != null && 
                            _con.order.deliveryAddress.longitude != null &&
                            _con.order.deliveryAddress.latitude != 0.0 &&
                            _con.order.deliveryAddress.longitude != 0.0;
    
    // تحقق من إحداثيات المطعم
    bool hasRestaurantCoords = false;
    if (_con.order.foodOrders.isNotEmpty) {
      double? restaurantLat = double.tryParse(
        _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
      );
      double? restaurantLng = double.tryParse(
        _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
      );
      hasRestaurantCoords = restaurantLat != null && restaurantLng != null && 
                           restaurantLat != 0.0 && restaurantLng != 0.0;
    }
    
    // إذا لم تكن هناك أي إحداثيات متوفرة، اعرض رسالة خطأ
    if (!hasDeliveryCoords && !hasRestaurantCoords) {
      setState(() {
        _mapError = "No location data available for this order.";
      });
      print("❌ Map Error: No coordinates available");
      print("   - Delivery coordinates available: $hasDeliveryCoords");
      print("   - Restaurant coordinates available: $hasRestaurantCoords");
      return;
    }
    
    // إذا كانت هناك إحداثيات متوفرة، اعرض الخريطة
    print("✅ Showing map with available coordinates:");
    print("   - Delivery coordinates available: $hasDeliveryCoords");
    print("   - Restaurant coordinates available: $hasRestaurantCoords");

    try {
      setState(() {
        _showMap = true;
        _mapError = null;
      });
    } catch (e) {
      setState(() {
        _mapError = "Failed to load map: $e";
        _showMap = false;
      });
      print("❌ Map Error: $e");
    }
  }

  Widget _buildLiveTrackingTab() {
    if (_mapError != null) {
      return _buildMapError();
    }

    if (!_showMap) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Loading delivery map...", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return _buildDeliveryMap();
  }

  Widget _buildMapError() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            "Map Unavailable",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            _mapError ?? "Unable to load delivery map",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Possible reasons:",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text("• No location data available for this order"),
                SizedBox(height: 4),
                Text("• Missing delivery address coordinates"),
                SizedBox(height: 4),
                Text("• Restaurant location not available"),
                SizedBox(height: 4),
                Text("• Network connectivity issues"),
              ],
              // style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //   color: Colors.grey.shade600,
              // ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _mapError = null;
                    _showMap = false;
                  });
                  _loadDeliveryMap();
                },
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Open external map app
                  _openInExternalMap();
                },
                icon: Icon(Icons.open_in_new),
                label: Text("Open in Maps"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMap() {
    // تحقق من إحداثيات العنوان
    bool hasDeliveryCoords = _con.order.deliveryAddress.latitude != null &&
        _con.order.deliveryAddress.longitude != null &&
        _con.order.deliveryAddress.latitude != 0.0 &&
        _con.order.deliveryAddress.longitude != 0.0;

    // تحقق من إحداثيات المطعم
    bool hasRestaurantCoords = false;
    double restaurantLat = 0.0;
    double restaurantLng = 0.0;

    if (_con.order.foodOrders.isNotEmpty) {
      restaurantLat = double.tryParse(_con.order.foodOrders.first.food?.restaurant.latitude ?? '0') ?? 0.0;
      restaurantLng = double.tryParse(_con.order.foodOrders.first.food?.restaurant.longitude ?? '0') ?? 0.0;
      hasRestaurantCoords = restaurantLat != 0.0 && restaurantLng != 0.0;
    }

    final deliveryLat = _con.order.deliveryAddress.latitude ?? 0.0;
    final deliveryLng = _con.order.deliveryAddress.longitude ?? 0.0;

    // بناء العلامات المتوفرة فقط
    Set<Marker> markers = {};

    // إضافة علامة العنوان إذا كانت الإحداثيات متوفرة
    if (hasDeliveryCoords) {
      markers.add(
        Marker(
          markerId: MarkerId('delivery'),
          position: LatLng(deliveryLat, deliveryLng),
          infoWindow: InfoWindow(
            title: 'Delivery Address',
            snippet: _con.order.deliveryAddress.address ?? 'Your location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    // إضافة علامة المطعم إذا كانت الإحداثيات متوفرة
    if (hasRestaurantCoords) {
      markers.add(
        Marker(
          markerId: MarkerId('restaurant'),
          position: LatLng(restaurantLat, restaurantLng),
          infoWindow: InfoWindow(
            title: _con.order.foodOrders.first.food?.restaurant.name ?? 'Restaurant',
            snippet: 'Pickup location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // إضافة علامة السائق إذا كان متصلاً بالتراكنج المباشر
    bool hasDriverCoords = _con.driverLocation.latitude != 0.0 &&
        _con.driverLocation.longitude != 0.0;

    if (hasDriverCoords) {
      markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: _con.driverLocation,
          infoWindow: InfoWindow(
            title: 'Driver Location',
            snippet: 'Live tracking',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // حساب موقع الكاميرا بناءً على الإحداثيات المتوفرة
    LatLng cameraTarget = const LatLng(31.5, 35.1); // موقع افتراضي
    double zoom = 12;

    if (hasDriverCoords && hasDeliveryCoords) {
      cameraTarget = LatLng(
        (_con.driverLocation.latitude + deliveryLat) / 2,
        (_con.driverLocation.longitude + deliveryLng) / 2,
      );
      zoom = 13;
    } else if (hasDeliveryCoords && hasRestaurantCoords) {
      cameraTarget = LatLng(
        (deliveryLat + restaurantLat) / 2,
        (deliveryLng + restaurantLng) / 2,
      );
      zoom = 12;
    } else if (hasDeliveryCoords) {
      cameraTarget = LatLng(deliveryLat, deliveryLng);
      zoom = 14;
    } else if (hasDriverCoords) {
      cameraTarget = _con.driverLocation;
      zoom = 14;
    } else if (hasRestaurantCoords) {
      cameraTarget = LatLng(restaurantLat, restaurantLng);
      zoom = 14;
    }

    // إذا لم تتوفر أي إحداثيات، لا تغلق الصفحة بل اعرض رسالة ودية
    if (!hasDeliveryCoords && !hasRestaurantCoords && !hasDriverCoords) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'لا تتوفر بيانات كافية لعرض الخريطة حالياً.\nسيتم التحديث تلقائياً عند توفر البيانات.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          // Status info
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Icon(Icons.delivery_dining, size: 32, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order # ${_con.order.id}",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _con.order.orderStatus.status ?? '-',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (_con.order.active)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 4),
                    // مؤشر حالة التراكنج المباشر
                    GestureDetector(
                      onTap: () {
                        if (!_con.isDriverTrackingConnected) {
                          _con.reconnectToDriverTracking(_con.order.id ?? '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reconnecting to live tracking...'),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _con.isDriverTrackingConnected ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _con.isDriverTrackingConnected ? Icons.wifi : Icons.wifi_off,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _con.isDriverTrackingConnected ? "Live" : "Tap to reconnect",
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: cameraTarget,
                zoom: zoom,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.satellite,
              onMapCreated: (GoogleMapController controller) async {
                // Apply custom map style
                final mapStyle = await DefaultAssetBundle.of(context).loadString('assets/cfg/map_style.json');
                controller.setMapStyle(mapStyle);
              },
            ),
          ),
          // Address info
          if (_con.order.deliveryAddress.address != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  // معلومات العنوان
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _con.order.deliveryAddress.address!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // زر عرض موقع المطعم
                  if (_con.order.hasRestaurantData())
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Restaurant Location",
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _con.order.getRestaurantName(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RestaurantLocationPage(
                                    order: _con.order,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.map, size: 16),
                            label: Text("View"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // معلومات السائق إذا كان التراكنج المباشر متصل
                  if (_con.isDriverTrackingConnected &&
                      _con.driverLocation.latitude != 0.0 &&
                      _con.driverLocation.longitude != 0.0)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.delivery_dining, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Driver Location",
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Live tracking active",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "LIVE",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!_con.isDriverTrackingConnected)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.grey),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Live Tracking",
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Tap to reconnect",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openInExternalMap() async {
    final lat = _con.order.deliveryAddress.latitude;
    final lng = _con.order.deliveryAddress.longitude;
    
    if (lat != null && lng != null) {
      // This would open external maps - you'd need to add url_launcher dependency
      // final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
      // You can implement external map opening here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External map opening not implemented yet")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 135,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)],
        ),
        child: _con.orderStatus.isEmpty
            ? CircularLoadingWidget(height: 120)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(S.of(context).how_would_you_rate_this_restaurant, style: Theme.of(context).textTheme.titleMedium),
                  Text(S.of(context).click_on_the_stars_below_to_leave_comments, style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 5),
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/Reviews', arguments: RouteArgument(id: _con.order.id, heroTag: "restaurant_reviews"));
                    },
                    padding: EdgeInsets.symmetric(vertical: 5),
                    shape: StadiumBorder(),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: Helper.getStarsList(double.parse(_con.order.foodOrders[0].food?.restaurant.rate ?? '0'), size: 35)),
                  ),
                ],
              ),
      ),
      body: _con.orderStatus.isEmpty
          ? CircularLoadingWidget(height: 400)
          : CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  snap: true,
                  floating: true,
                  centerTitle: true,
                  title: Text(S.of(context).orderDetails, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3))),
                  actions: <Widget>[new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).colorScheme.secondary)],
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                    labelColor: Theme.of(context).primaryColor,
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).colorScheme.secondary),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2), width: 1)),
                          child: Align(alignment: Alignment.center, child: Text(S.of(context).details, style: TextStyle(fontSize: 12))),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2), width: 1)),
                          child: Align(alignment: Alignment.center, child: Text(S.of(context).tracking_order, style: TextStyle(fontSize: 12))),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2), width: 1)),
                          child: Align(alignment: Alignment.center, child: Text("Live Map", style: TextStyle(fontSize: 12))),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Details Tab
                    Offstage(
                      offstage: 0 != _tabIndex,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Opacity(
                              opacity: _con.order.active ? 1 : 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 14),
                                    padding: EdgeInsets.only(top: 20, bottom: 5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                                      boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
                                    ),
                                    child: Theme(
                                      data: theme,
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        title: Column(
                                          children: <Widget>[
                                            Text('${S.of(context).order_id}: #${_con.order.id}'),
                                            Text(DateFormat('dd-MM-yyyy | HH:mm').format(_con.order.dateTime), style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Helper.getPrice(Helper.getTotalOrdersPrice(_con.order), context, style: Theme.of(context).textTheme.headlineLarge),
                                            Text('${_con.order.payment.method}', style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                        ),
                                        children: <Widget>[
                                          Column(
                                            children: List.generate(_con.order.foodOrders.length, (indexFood) {
                                              return FoodOrderItemWidget(heroTag: 'my_order', order: _con.order, foodOrder: _con.order.foodOrders.elementAt(indexFood));
                                            }),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(child: Text(S.of(context).delivery_fee, style: Theme.of(context).textTheme.bodyLarge)),
                                                    Helper.getPrice(_con.order.deliveryFee, context, style: Theme.of(context).textTheme.titleMedium),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(child: Text('${S.of(context).tax} (${_con.order.tax}%)', style: Theme.of(context).textTheme.bodyLarge)),
                                                    Helper.getPrice(Helper.getTaxOrder(_con.order), context, style: Theme.of(context).textTheme.titleMedium),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(child: Text(S.of(context).total, style: Theme.of(context).textTheme.bodyLarge)),
                                                    Helper.getPrice(Helper.getTotalOrdersPrice(_con.order), context, style: Theme.of(context).textTheme.headlineLarge),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      children: <Widget>[
                                        if (_con.order.canCancelOrder())
                                          MaterialButton(
                                            elevation: 0,
                                            focusElevation: 0,
                                            highlightElevation: 0,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Wrap(
                                                      spacing: 10,
                                                      children: <Widget>[Icon(Icons.report, color: Colors.orange), Text(S.of(context).confirmation, style: TextStyle(color: Colors.orange))],
                                                    ),
                                                    content: Text(S.of(context).areYouSureYouWantToCancelThisOrder),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                                                    actions: <Widget>[
                                                      MaterialButton(
                                                        elevation: 0,
                                                        focusElevation: 0,
                                                        highlightElevation: 0,
                                                        child: new Text(S.of(context).yes, style: TextStyle(color: Theme.of(context).hintColor)),
                                                        onPressed: () {
                                                          _con.doCancelOrder();
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      MaterialButton(
                                                        elevation: 0,
                                                        focusElevation: 0,
                                                        highlightElevation: 0,
                                                        child: new Text(S.of(context).close, style: TextStyle(color: Colors.orange)),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            textColor: Theme.of(context).hintColor,
                                            child: Wrap(children: <Widget>[Text(S.of(context).cancelOrder + " ", style: TextStyle(height: 1.3)), Icon(Icons.clear)]),
                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 28,
                              width: 160,
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: _con.order.active ? Theme.of(context).colorScheme.secondary : Colors.redAccent),
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                _con.order.active ? '${_con.order.orderStatus.status}' : S.of(context).canceled,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tracking Tab
                    Offstage(
                      offstage: 1 != _tabIndex,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Theme(
                              data: ThemeData(primaryColor: Theme.of(context).colorScheme.secondary),
                              child: Stepper(
                                physics: ClampingScrollPhysics(),
                                controlsBuilder: (BuildContext context, ControlsDetails controls) {
                                  return SizedBox(height: 0);
                                },
                                steps: _con.getTrackingSteps(context, getCurrentOrderStatus(this._con.order.orderStatus)),
                                currentStep: getCurrentOrderStatus(this._con.order.orderStatus),
                              ),
                            ),
                          ),
                          _con.order.deliveryAddress.address != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: Theme.of(context).brightness == Brightness.light ? Colors.black38 : Theme.of(context).colorScheme.surface,
                                        ),
                                        child: Icon(Icons.place, color: Theme.of(context).primaryColor, size: 38),
                                      ),
                                      SizedBox(width: 15),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(_con.order.deliveryAddress.description ?? "", overflow: TextOverflow.fade, softWrap: false, style: Theme.of(context).textTheme.titleMedium),
                                            Text(
                                              _con.order.deliveryAddress.address ?? S.of(context).unknown,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(height: 0),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                    // Live Map Tab
                    Offstage(
                      offstage: 2 != _tabIndex,
                      child: _buildLiveTrackingTab(),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }

  int getCurrentOrderStatus(OrderStatus orderStatus) {
    switch (int.tryParse(this._con.order.orderStatus.id)! - 1) {
      case 0:
      case 1:
      case 5:
      case 6:
        return 0;
      case 2:
      case 3:
      case 4:
      case 5:
        return int.tryParse(this._con.order.orderStatus.id)! - 1;
      case 5:
      case 7:
        return 2;
    }
    return 0;
  }
}