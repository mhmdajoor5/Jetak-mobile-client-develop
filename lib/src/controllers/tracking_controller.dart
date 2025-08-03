import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order/tracking_order_model.dart';
import '../models/order_status.dart';
import '../repository/order/order_track_repo.dart';
import '../repository/order_repository.dart';

class TrackingController extends ControllerMVC {
  Order order = Order();
  List<OrderStatus> orderStatus = <OrderStatus>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  /// TODO make it dynamic
  LatLng restaurantLocation = LatLng(0.0, 0.0);
  LatLng clientLocation = LatLng(0.0, 0.0);
  LatLng driverLocation = LatLng(0.0, 0.0); // إضافة موقع السائق

  // WebSocket للتراكنج المباشر
  WebSocketChannel? _driverTrackingChannel;
  bool _isDriverTrackingConnected = false;

  // دالة للاتصال بـ WebSocket للتراكنج المباشر
  void connectToDriverTracking(String orderId) {
    try {
      print("🚀 بدء الاتصال بـ WebSocket للتراكنج المباشر");
      print("📡 Channel: order-tracking.$orderId");
      
      // إغلاق الاتصال السابق إذا كان موجود
      _driverTrackingChannel?.sink.close();
      
      // إنشاء اتصال WebSocket جديد
      _driverTrackingChannel = WebSocketChannel.connect(
        Uri.parse('ws://carrytechnologies.co:6001'),
      );
      
      // الاستماع للرسائل الواردة
      _driverTrackingChannel!.stream.listen(
        (data) {
          print("📨 رسالة واردة من WebSocket: $data");
          _handleDriverTrackingMessage(data, orderId);
        },
        onError: (error) {
          print("❌ خطأ في WebSocket: $error");
          _isDriverTrackingConnected = false;
          setState(() {});
          
          // إظهار رسالة انقطاع الاتصال
          if (scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Live tracking connection lost. Tap to reconnect.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        onDone: () {
          print("✅ WebSocket connection closed");
          _isDriverTrackingConnected = false;
          setState(() {});
          
          // إظهار رسالة إغلاق الاتصال
          if (scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Live tracking connection closed.'),
                backgroundColor: Colors.grey,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
      
      // إرسال رسالة الاشتراك في channel
      _subscribeToDriverTracking(orderId);
      
      _isDriverTrackingConnected = true;
      setState(() {});
      
      print("✅ تم الاتصال بـ WebSocket بنجاح");
      
      // إظهار رسالة نجاح الاتصال
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Live tracking connected successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print("❌ خطأ في الاتصال بـ WebSocket: $e");
      _isDriverTrackingConnected = false;
      setState(() {});
    }
  }

  // دالة للاشتراك في channel التراكنج
  void _subscribeToDriverTracking(String orderId) {
    try {
      final subscribeMessage = {
        'event': 'subscribe',
        'channel': 'order-tracking.$orderId',
        'data': {
          'order_id': orderId,
        }
      };
      
      _driverTrackingChannel?.sink.add(json.encode(subscribeMessage));
      print("📡 تم الاشتراك في channel: order-tracking.$orderId");
      
    } catch (e) {
      print("❌ خطأ في الاشتراك: $e");
    }
  }

  // دالة لمعالجة الرسائل الواردة من WebSocket
  void _handleDriverTrackingMessage(dynamic data, String orderId) {
    try {
      final message = json.decode(data.toString());
      print("📨 معالجة رسالة التراكنج: $message");
      
      if (message['event'] == 'driver-location-update') {
        final driverData = message['data'];
        
        if (driverData != null) {
          final latitude = double.tryParse(driverData['latitude']?.toString() ?? '0') ?? 0.0;
          final longitude = double.tryParse(driverData['longitude']?.toString() ?? '0') ?? 0.0;
          
          print("📍 موقع السائق المحدث: lat=$latitude, lng=$longitude");
          
          setState(() {
            driverLocation = LatLng(latitude, longitude);
          });
          
          // إظهار رسالة تحديث موقع السائق (فقط في المرة الأولى)
          if (scaffoldKey.currentContext != null && 
              (driverLocation.latitude != 0.0 || driverLocation.longitude != 0.0)) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Driver location updated!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      } else if (message['event'] == 'order-status-update') {
        final statusData = message['data'];
        print("🔄 تحديث حالة الطلب: $statusData");
        
        // تحديث حالة الطلب
        if (statusData != null) {
          final oldStatus = order.orderStatus.status;
          setState(() {
            order.orderStatus.status = statusData['status'] ?? order.orderStatus.status;
            order.orderStatus.id = statusData['status_id']?.toString() ?? order.orderStatus.id;
          });
          
          // إظهار رسالة تحديث حالة الطلب
          if (scaffoldKey.currentContext != null && 
              statusData['status'] != null && 
              statusData['status'] != oldStatus) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Order status updated: ${statusData['status']}'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
      
    } catch (e) {
      print("❌ خطأ في معالجة رسالة WebSocket: $e");
    }
  }

  // دالة لإغلاق اتصال WebSocket
  void disconnectFromDriverTracking() {
    try {
      print("🔌 إغلاق اتصال WebSocket");
      _driverTrackingChannel?.sink.close();
      _isDriverTrackingConnected = false;
      setState(() {});
      
      // إظهار رسالة إغلاق الاتصال
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Live tracking disconnected.'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("❌ خطأ في إغلاق WebSocket: $e");
    }
  }

  // دالة لإعادة الاتصال بالتراكنج المباشر
  void reconnectToDriverTracking(String orderId) {
    print("🔄 إعادة الاتصال بالتراكنج المباشر");
    disconnectFromDriverTracking();
    Future.delayed(Duration(seconds: 2), () {
      connectToDriverTracking(orderId);
    });
    
    // إظهار رسالة إعادة الاتصال
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Reconnecting to live tracking...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // دالة للتحقق من حالة الاتصال
  bool get isDriverTrackingConnected => _isDriverTrackingConnected;

  Future<void> setClientLocationFromDevice() async {
    print("mElkerm Tracking Controller ▶ Getting current device location...");

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("mElkerm Tracking Controller ❌ Location services are disabled.");
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("mElkerm Tracking Controller ❌ Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
        "mElkerm Tracking Controller ❌ Location permission permanently denied.",
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print(
      "mElkerm Tracking Controller ✅ Location obtained: ${position.latitude}, ${position.longitude}",
    );

    setState(() {
      clientLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void listenForOrder({required String orderId, String? message}) async {
    print(
      "mElkerm Tracking Controller ▶ Starting listenForOrder for ID: $orderId",
    );
    
    // بدء التراكنج المباشر للسائق
    connectToDriverTracking(orderId);
    
    final Stream<Order> stream = await getOrder(orderId);
    print(
      "mElkerm Tracking Controller ✅ Stream obtained for order ID: $orderId",
    );

    stream.listen(
      (Order _order) {
        setState(() {
          print("mElkerm Tracking Controller ▶ Received order data");
          print("mElkerm Tracking Controller → order id: ${_order.id}");
          print(
            "mElkerm Tracking Controller → order status id: ${_order.orderStatus.id}",
          );
          print(
            "mElkerm Tracking Controller → order status: ${_order.orderStatus.status}",
          );
          print("mElkerm Tracking Controller → order date: ${_order.dateTime}");
          print(
            "mElkerm Tracking Controller → payment method: ${_order.payment.method}",
          );
          print("mElkerm Tracking Controller → active: ${_order.active}");
          print("mElkerm Tracking Controller → hint: ${_order.hint}");
          print(
            "mElkerm Tracking Controller → lat: ${_order.deliveryAddress.longitude}",
          );
          print(
            "mElkerm Tracking Controller → lang: ${_order.deliveryAddress.latitude}",
          );
          restaurantLocation = LatLng(
            double.tryParse(_order.deliveryAddress.latitude.toString()) ?? 0.0,
            35.4219985,
          );

          print(
            "mElkerm Tracking Controller → restaurant location: $restaurantLocation",
          );
          // setClientLocationFromDevice();

          restaurantLocation = LatLng(31.532640, 35.098614);
          clientLocation = LatLng(31.536833, 35.050363);
          print(
            "mElkerm Tracking Controller → restaurant location: $restaurantLocation",
          );

          order = _order;
        });
      },
      onError: (a) {
        print("mElkerm Tracking Controller ❌ Error in listenForOrder: $a");
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(S.of(state!.context).verify_your_internet_connection),
          ),
        );
      },
      onDone: () {
        print("mElkerm Tracking Controller ✅ listenForOrder stream done");
        listenForOrderStatus();
        if (message != null) {
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  TrackingOrderModel? trackingOrderDetails = null;

  Future<void> getOrderDetailsTracking({
    required String orderId,
    String? message,
  }) async {
    print(
      "mElkerm Tracking Controller ▶ Start getOrderDetailsTracking for ID: $orderId",
    );
    setState(() {
      // Optional: loading state
    });

    try {
      final result = await getTrackingOrderModel(orderId: orderId);
      print("mElkerm Tracking Controller ✅ Tracking data fetched successfully");

      setState(() {
        trackingOrderDetails = result;
      });

      if (message != null) {
        ScaffoldMessenger.of(
          scaffoldKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      listenForOrderStatus();
    } catch (error) {
      print(
        "mElkerm Tracking Controller ❌ Error fetching tracking data: $error",
      );
      
      // تحليل نوع الخطأ لتقديم رسالة أكثر وضوحاً
      String errorMessage = "Failed to load tracking information";
      
      if (error.toString().contains("User API token not available")) {
        errorMessage = "Please login again to view tracking information";
      } else if (error.toString().contains("Order not found")) {
        errorMessage = "Order not found. Please check the order ID.";
      } else if (error.toString().contains("Unauthorized")) {
        errorMessage = "Unauthorized. Please login again.";
      } else if (error.toString().contains("Empty response")) {
        errorMessage = "No tracking data available for this order.";
      } else if (error.toString().contains("Failed to load tracking data")) {
        errorMessage = "Tracking data is not available for this order.";
      }
      
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void listenForOrderStatus() async {
    print("mElkerm Tracking Controller ▶ Start listening for order statuses");
    final Stream<OrderStatus> stream = await getOrderStatus();
    print("mElkerm Tracking Controller ✅ OrderStatus stream obtained");

    stream.listen(
      (OrderStatus _orderStatus) {
        setState(() {
          print(
            "mElkerm Tracking Controller → Received status: ${_orderStatus.status} (ID: ${_orderStatus.id})",
          );
          orderStatus.add(_orderStatus);
        });
      },
      onError: (a) {
        print("mElkerm Tracking Controller ❌ Error in order status stream: $a");
      },
      onDone: () {
        print("mElkerm Tracking Controller ✅ Order status stream done");
      },
    );
  }

  // دالة لإغلاق جميع الاتصالات عند إغلاق الصفحة
  void dispose() {
    print("🧹 تنظيف موارد التراكنج");
    disconnectFromDriverTracking();
    super.dispose();
  }

  List<Step> getTrackingSteps(BuildContext context, int currentOrderStatus) {
    print("mElkerm Tracking Controller ▶ Building tracking steps");
    List<Step> _orderStatusSteps = [];
    List<OrderStatus> statuses = [...this.orderStatus];

    for (OrderStatus status in statuses) {
      print(
        "mElkerm Tracking Controller → Status name: ${status.status}, ID: ${status.id}",
      );
    }

    statuses.removeWhere((element) => element.id == "6" || element.id == "7");
    if (order.payment.method == "Pay on Pickup") {
      statuses.removeWhere((element) => element.id == "5" || element.id == "4");
    }

    statuses.forEach((OrderStatus _orderStatus) {
      _orderStatusSteps.add(
        Step(
          state: StepState.complete,
          title: Text(
            _orderStatus.status,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle:
              order.orderStatus.id == _orderStatus.id
                  ? Text(
                    '${DateFormat('HH:mm | yyyy-MM-dd').format(order.dateTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  )
                  : SizedBox(height: 0),
          content: SizedBox(
            width: double.infinity,
            child: Text('${Helper.skipHtml(order.hint)}'),
          ),
          isActive:
              (currentOrderStatus + 1) >= (int.tryParse(_orderStatus.id)!),
        ),
      );
    });

    print("mElkerm Tracking Controller ✅ Finished building steps");
    return _orderStatusSteps;
  }

  Future<void> refreshOrder() async {
    print("mElkerm Tracking Controller ▶ Refreshing order");
    order = new Order();
    listenForOrder(
      orderId: order.id,
      message: S.of(state!.context).tracking_refreshed_successfuly,
    );
    getOrderDetailsTracking(
      orderId: order.id,
      message: S.of(state!.context).tracking_refreshed_successfuly,
    );
  }

  void doCancelOrder() {
    print("mElkerm Tracking Controller ▶ Starting cancel order");
    cancelOrder(this.order)
        .then((value) {
          setState(() {
            print("mElkerm Tracking Controller ✅ Order marked as inactive");
            this.order.active = false;
          });
        })
        .catchError((e) {
          print("mElkerm Tracking Controller ❌ Error cancelling order: $e");
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(e)));
        })
        .whenComplete(() {
          print("mElkerm Tracking Controller ✅ Cancel order flow complete");
          orderStatus = [];
          listenForOrderStatus();
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                S
                    .of(state!.context)
                    .orderThisorderidHasBeenCanceled(this.order.id),
              ),
            ),
          );
        });
  }

  bool canCancelOrder(Order order) {
    print("mElkerm Tracking Controller ▶ Checking if order can be cancelled");
    return order.active == true && order.orderStatus.id == 1;
  }
}
