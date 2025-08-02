import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/cart.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'RestaurantAppBar.dart';
import 'restaurant_details_section.dart';
import 'restaurant_bottom_cart.dart';

class RestaurantWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantWidget({Key? key, this.parentScaffoldKey, this.routeArgument})
    : super(key: key);

  @override
  _RestaurantWidgetState createState() => _RestaurantWidgetState();
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  late RestaurantController _con;

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }
  double userLat = 0.0;
  double userLon = 0.0;
  bool locationLoaded = false; // إضافة loading state

  final List<Cart> _cart = [];

  // دالة للحصول على إحداثيات المستخدم
  Future<void> _getUserLocation() async {
    try {
      print('🔍 ===== GETTING USER LOCATION =====');
      
      // التحقق من صلاحيات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          setState(() {
            locationLoaded = true;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission denied forever');
        setState(() {
          locationLoaded = true;
        });
        return;
      }
      
      // التحقق من أن GPS مفعل
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        setState(() {
          locationLoaded = true;
        });
        return;
      }
      
      // محاولة الحصول على الموقع مع إعدادات مختلفة
      Position? position;
      
      // المحاولة الأولى: دقة عالية
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        print('✅ High accuracy location obtained');
      } catch (e) {
        print('⚠️ High accuracy failed, trying medium accuracy');
        
        // المحاولة الثانية: دقة متوسطة
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          );
          print('✅ Medium accuracy location obtained');
        } catch (e) {
          print('⚠️ Medium accuracy failed, trying low accuracy');
          
          // المحاولة الثالثة: دقة منخفضة
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 20),
            );
            print('✅ Low accuracy location obtained');
          } catch (e) {
            print('❌ All accuracy levels failed');
            throw e;
          }
        }
      }
      
      // التحقق من أن الإحداثيات صحيحة
      if (position != null && 
          position.latitude != 0.0 && 
          position.longitude != 0.0 &&
          position.latitude.abs() > 0.001 && 
          position.longitude.abs() > 0.001) {
        
        setState(() {
          userLat = position!.latitude;
          userLon = position!.longitude;
          locationLoaded = true;
        });
        
        print('✅ USER LOCATION OBTAINED:');
        print('   Latitude: $userLat');
        print('   Longitude: $userLon');
        print('   Accuracy: ${position!.accuracy} meters');
        print('🔍 ===== GETTING USER LOCATION END =====');
        
      } else {
        print('❌ Invalid coordinates received: ${position?.latitude}, ${position?.longitude}');
        throw Exception('Invalid coordinates');
      }
      
    } catch (e) {
      print('❌ ERROR GETTING USER LOCATION: $e');
      setState(() {
        locationLoaded = true;
      });
      print('⚠️ COULD NOT GET USER LOCATION - USING DEFAULT 0.0, 0.0');
    }
  }

  // دالة لإعادة المحاولة
  void _retryGetLocation() {
    setState(() {
      locationLoaded = false;
      userLat = 0.0;
      userLon = 0.0;
    });
    _getUserLocation();
  }

  int get cartCount =>
      _cart.fold(0, (sum, c) => (sum + (c.quantity ?? 1)).toInt());
  double get totalPrice => _cart.fold(
    0.0,
    (sum, c) => sum + (c.food?.price ?? 0) * (c.quantity ?? 1),
  );

  void _addToCart(Food food) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.food?.id == food.id);
      if (idx >= 0) {
        _cart[idx].quantity = (_cart[idx].quantity ?? 1) + 1;
      } else {
        _cart.add(Cart(food: food, quantity: 1));
      }
    });
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument?.param as Restaurant;
    _con.listenForFeaturedFoods(_con.restaurant!.id!);
    _con.listenForMostOrderRest(restId: _con.restaurant!.id!);
    
    // الحصول على إحداثيات المستخدم
    _getUserLocation();
    
    print('🔍 ===== RESTAURANT WIDGET DEBUG =====');
    print('🔍 USER LATITUDE SET: $userLat');
    print('🔍 USER LONGITUDE SET: $userLon');
    print('🔍 ===== RESTAURANT WIDGET DEBUG END =====');
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      body: _con.restaurant == null
          ? CircularLoadingWidget(height: 500)
          : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  RestaurantAppBar(
                    restaurant: _con.restaurant!,
                    routeArgument: widget.routeArgument,
                  ),
                  SliverToBoxAdapter(
                    child: locationLoaded 
                      ? (userLat == 0.0 && userLon == 0.0)
                        ? Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا يمكن تحديد موقعك',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'تأكد من تفعيل GPS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _retryGetLocation,
                                    child: Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RestaurantDetailsSection(
                            con: _con,
                            cart: _cart,
                            addToCart: _addToCart,
                            userLat: userLat,
                            userLon: userLon,
                          )
                      : Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('جاري تحديد موقعك...'),
                                SizedBox(height: 8),
                                Text(
                                  'تأكد من تفعيل GPS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ],
              ),
              // RestaurantBottomCart()
            ],
          ),
    );
  }
}
