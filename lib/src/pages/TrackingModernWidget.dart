import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/tracking_controller.dart';
import '../models/route_argument.dart';

class TrackingModernWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const TrackingModernWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _TrackingModernWidgetState createState() => _TrackingModernWidgetState();
}

class _TrackingModernWidgetState extends StateMVC<TrackingModernWidget> {
  late TrackingController _con;
  GoogleMapController? _mapController;

  _TrackingModernWidgetState() : super(TrackingController()) {
    _con = controller as TrackingController;
  }

  @override
  void initState() {
    super.initState();
    if (widget.routeArgument != null && widget.routeArgument!.id != null) {
      _con.listenForOrder(orderId: widget.routeArgument!.id!);
      _con.getOrderDetailsTracking(orderId: widget.routeArgument!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('order.id: [32m[1m[4m[7m${widget.routeArgument?.id}[0m');
    print('foodOrders.length: [34m${_con.order.foodOrders.length}[0m');
    print('address: [35m${_con.order.deliveryAddress.address}[0m');
    // حماية من محاولة قراءة بيانات غير جاهزة
    if (_con.order.id == null || _con.order.foodOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Tracking",
            style: TextStyle(
              fontFamily: "Nunito",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF272727),
            ),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFE7E7E9)),
              ),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // استخراج الإحداثيات إذا توفرت
    double? restaurantLat;
    double? restaurantLng;
    double? clientLat;
    double? clientLng;
    try {
      if (_con.order.foodOrders.isNotEmpty) {
        restaurantLat = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
        );
        restaurantLng = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
        );
      }
      clientLat = _con.order.deliveryAddress.latitude;
      clientLng = _con.order.deliveryAddress.longitude;
    } catch (e) {}

    Set<Marker> markers = {};
    List<LatLng> polylinePoints = [];
    if (restaurantLat != null && restaurantLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('restaurant'),
          position: LatLng(restaurantLat, restaurantLng),
          infoWindow: InfoWindow(title: 'Restaurant'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      polylinePoints.add(LatLng(restaurantLat, restaurantLng));
    }
    if (clientLat != null && clientLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('client'),
          position: LatLng(clientLat, clientLng),
          infoWindow: InfoWindow(title: 'Client'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      polylinePoints.add(LatLng(clientLat, clientLng));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Tracking",
          style: TextStyle(
            fontFamily: "Nunito",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF272727),
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFE7E7E9)),
            ),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child:
                (restaurantLat != null &&
                        restaurantLng != null &&
                        clientLat != null &&
                        clientLng != null)
                    ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          (restaurantLat + clientLat) / 2,
                          (restaurantLng + clientLng) / 2,
                        ),
                        zoom: 13,
                      ),
                      markers: markers,
                      polylines: {
                        if (polylinePoints.length == 2)
                          Polyline(
                            polylineId: PolylineId('route'),
                            points: polylinePoints,
                            color: Colors.blue,
                            width: 4,
                          ),
                      },
                      onMapCreated: (controller) => _mapController = controller,
                    )
                    : Center(
                      child: Text("Map Here", style: TextStyle(fontSize: 20)),
                    ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          "assets/images/image-removebg-preview.png",
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TODO : driver name
                          Text(
                            _con.trackingOrderDetails?.data.driver?.name ?? "not available now",

                            // TODO: استبدل باسم الكابتن الحقيقي عند توفره
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.0,
                              letterSpacing: -0.02,
                              color: Color(0xFF272727),
                            ),
                          ),
                          SizedBox(height: 4),
                          /// TODO : driver type
                          Text(
                            "Courier",
                            // TODO: استبدل بنوع الكابتن الحقيقي عند توفره
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.4,
                              letterSpacing: -0.02,
                              color: Color(0xFF9D9FA4),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      _buildActionIconPhone(),
                      SizedBox(width: 10),
                      Stack(
                        children: [
                          _buildActionIconMassge(),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.red,
                              child: Text(
                                "3",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  LayoutBuilder(
                    builder:
                        (context, constraints) => Row(
                          children: List.generate(
                            (constraints.maxWidth / 10).floor(),
                            (index) {
                              return Container(
                                width: 6,
                                height: 1,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                color: Color(0xFFE7E7E9),
                              );
                            },
                          ),
                        ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:
                        _buildStepProgress(), // TODO: اربطه بمراحل الطلب الحقيقية
                  ),
                  SizedBox(height: 20),
                  /// TODO: delivery time
                  _buildInfoTile(
                    "Delivery time",
                    "assets/img/clock.svg",
                    _con.trackingOrderDetails?.data.estimatedTime ?? "not available now",
                  ),
                  // TODO: اربطه بوقت التوصيل المتوقع الحقيقي
                  _buildInfoTile(
                    "Delivery address",
                    "assets/img/locationorder.svg",
                    _con.order.deliveryAddress.address ?? "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    // TODO: اربط الخطوات بحالة الطلب الحقيقية من _con.orderStatus
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/reserve.svg', true),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/truck-fast.svg', false),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/tick-circle.svg', false),
      ],
    );
  }

  Widget _buildDashedLine(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 5),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
          Row(
            children: List.generate(4, (index) {
              return Container(
                width: 3,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 2),
                color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              );
            }),
          ),
          SizedBox(width: 7),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(String asset, bool active) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionIconPhone() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.phone, color: Color(0xFF26386A)),
    );
  }

  Widget _buildActionIconMassge() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.message, color: Color(0xFF26386A)),
    );
  }

  Widget _buildInfoTile(String title, String icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: Color(0xFF26386A),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Color(0xFF9D9FA4)),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF26386A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
