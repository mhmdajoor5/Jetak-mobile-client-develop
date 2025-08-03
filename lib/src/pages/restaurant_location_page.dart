import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order.dart';
import 'restaurant_info_page.dart';

class RestaurantLocationPage extends StatefulWidget {
  final Order order;

  const RestaurantLocationPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<RestaurantLocationPage> createState() => _RestaurantLocationPageState();
}

class _RestaurantLocationPageState extends State<RestaurantLocationPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    final restaurantLocation = widget.order.getRestaurantLocation();
    if (restaurantLocation != null) {
      _addRestaurantMarker(restaurantLocation);
    }
  }

  void _addRestaurantMarker(Map<String, double> location) {
    final marker = Marker(
      markerId: const MarkerId('restaurant'),
      position: LatLng(location['latitude']!, location['longitude']!),
      infoWindow: InfoWindow(
        title: widget.order.getRestaurantName(),
        snippet: widget.order.getRestaurantAddress(),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantLocation = widget.order.getRestaurantLocation();
    
    if (restaurantLocation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('موقع المطعم'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'إحداثيات المطعم غير متوفرة',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('موقع المطعم'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RestaurantInfoPage(
                    order: widget.order,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(restaurantLocation['latitude']!, restaurantLocation['longitude']!),
                  15.0,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // معلومات المطعم
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.getRestaurantName(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.order.getRestaurantAddress(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // الخريطة
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  restaurantLocation['latitude']!,
                  restaurantLocation['longitude']!,
                ),
                zoom: 15.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 