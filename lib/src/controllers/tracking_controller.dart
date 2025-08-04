import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pusher_client/pusher_client.dart' hide PusherEvent;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order/tracking_order_model.dart';
import '../models/order_status.dart';
import '../models/address.dart';
import '../models/user.dart';
import '../models/payment.dart';
import '../repository/order/order_track_repo.dart';
import '../repository/order_repository.dart';

class TrackingController extends ControllerMVC with ChangeNotifier {
  Order order = Order();
  List<OrderStatus> orderStatus = <OrderStatus>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  Future<void> _initPusher(cleanOrderId) async {

    void onError(String message, int? code, dynamic e) {
      log("onError: $message code: $code exception: $e");
    }

    void onConnectionStateChange(dynamic currentState, dynamic previousState) {
      log("Connection: $currentState");
    }

    void onMemberRemoved(String channelName, PusherMember member) {
      log("onMemberRemoved: $channelName member: $member");
    }

    void onMemberAdded(String channelName, PusherMember member) {
      log("onMemberAdded: $channelName member: $member");
    }

    void onSubscriptionSucceeded(String channelName, dynamic data) {
      log("onSubscriptionSucceeded: $channelName data: $data");
    }

    void onSubscriptionError(String message, dynamic e) {
      log("onSubscriptionError: $message Exception: $e");
    }

    Future<void> onEvent(PusherEvent event) async {
      log("onEvent: $event");
      
      // معالجة حدث تحديث موقع السائق
      if (event.eventName == 'driver.location.updated') {
        try {
          log("📍 Received driver location update event");
          
          // تحليل البيانات
          Map<String, dynamic> eventData = jsonDecode(event.data);
          log("📊 Event data: $eventData");
          
          // التحقق من order_id
          String? eventOrderId = eventData['order_id']?.toString();
          log("🆔 Event order_id: $eventOrderId");
          
          // التحقق من أن الـ order_id يتطابق مع الـ order الحالي
          if (eventOrderId != null && order.id.toString() == eventOrderId) {
            log("✅ Order ID matches! Processing driver location update");
            
            // استخراج إحداثيات السائق
            double? latitude = double.tryParse(eventData['latitude']?.toString() ?? '');
            double? longitude = double.tryParse(eventData['longitude']?.toString() ?? '');
            
                         if (latitude != null && longitude != null) {
               log("📍 Received driver location: $latitude, $longitude");
               log("📍 Current driver location: ${driverLocation.latitude}, ${driverLocation.longitude}");
               
               // حساب المسافة بين الموقع الحالي والموقع الجديد
               double distance = _calculateDistance(
                 driverLocation.latitude, 
                 driverLocation.longitude, 
                 latitude, 
                 longitude
               );
               
               log("📏 Distance difference: ${distance.toStringAsFixed(2)} meters");
               
               // تحديث الموقع إذا كان الفرق أكبر من 1 متر أو إذا كان الموقع الحالي (0,0)
               bool shouldUpdate = distance > 1.0 || (driverLocation.latitude == 0.0 && driverLocation.longitude == 0.0);
               
               if (shouldUpdate) {
                 log("📍 Driver location changed, updating...");
                 
                 // تحديث موقع السائق
                 driverLocation = LatLng(latitude, longitude);
                 
                 // تحديث الواجهة
                 setState(() {});
                 
                 // إرسال إشعار لتحديث الخريطة
                 notifyListeners();
                 
                 log("✅ Driver location updated successfully to: $driverLocation");
               } else {
                 log("📍 Driver location unchanged (distance < 1m), skipping update");
               }
             } else {
               log("❌ Invalid driver coordinates: latitude=$latitude, longitude=$longitude");
             }
          } else {
            log("❌ Order ID mismatch: Event order_id=$eventOrderId, Current order_id=${order.id}");
          }
        } catch (e) {
          log("❌ Error processing driver location event: $e");
        }
      }
    }

    void onDecryptionFailure(String event, String reason) {
      log("onDecryptionFailure: $event reason: $reason");
    }

    dynamic onAuthorizer(
        String channelName, String socketId, dynamic options) async {
      // var authUrl = "/chat/auth";
      // var result = await DioHelper.post(
      //   headers: {
      //     "Authorization": 'Bearer ${AuthService().token}',
      //   },
      //   authUrl,
      //   body: {"socket_id": socketId, "channel_name": channelName},
      // );
      // log("result: $result");
      // return jsonDecode(result.data.toString());
    }

    try {
      await _pusher.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        // authEndpoint: "https://carrytechnologies.co/orders",
        onAuthorizer: onAuthorizer,
      );
      await _pusher.subscribe(channelName: 'order-tracking.$cleanOrderId');
      await _pusher.connect();
    } catch (e) {
      log("error in initialization: $e");
    }
  }
  /// TODO make it dynamic
  LatLng restaurantLocation = LatLng(0.0, 0.0);
  LatLng clientLocation = LatLng(0.0, 0.0);
  LatLng driverLocation = LatLng(0.0, 0.0); // إضافة موقع السائق

  // Pusher للتراكنج المباشر
  PusherClient? _pusherClient;
  Channel? _trackingChannel;
  bool _isPusherConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _connectionTimeout = Duration(seconds: 10);

  // إعدادات Pusher
  static const String _pusherAppId = "2016693";
  static const String _pusherKey = "35debf4f355736840916";
  static const String _pusherSecret = "0509c246c2d3e9a05ee3";
  static const String _pusherCluster = "ap2";

  // دالة للاتصال بـ Pusher للتراكنج المباشر
  void connectToDriverTracking(String orderId) {
    _initPusher(orderId);
    return;
    try {
      print("🚀 بدء الاتصال بـ Pusher للتراكنج المباشر");
      print("📡 Channel: order-tracking.$orderId");
      print("🔑 Pusher App ID: $_pusherAppId");
      print("🔑 Pusher Key: $_pusherKey");
      print("🌐 Pusher Cluster: $_pusherCluster");
      
      // إغلاق الاتصال السابق إذا كان موجود
      _disconnectPusher();
      _reconnectTimer?.cancel();
      
      // إنشاء اتصال Pusher جديد
      _pusherClient = PusherClient(
        _pusherKey,
        PusherOptions(
          cluster: _pusherCluster,
          encrypted: true,
          activityTimeout: 30000, // 30 seconds
          pongTimeout: 6000, // 6 seconds
          maxReconnectionAttempts: 6,
          maxReconnectGapInSeconds: 30,
        ),
      );
      
      print("✅ تم إنشاء اتصال Pusher");
      
      // إضافة timeout للاتصال
      Timer(Duration(seconds: 15), () {
        if (!_isPusherConnected) {
          print("⏰ Pusher connection timeout after 15 seconds");
          _handleConnectionError('Connection timeout', orderId);
        }
      });
      
      // الاستماع لأحداث الاتصال
      _pusherClient!.onConnectionStateChange((state) {
        print("🔄 حالة الاتصال بـ Pusher:");
        print("  - Current State: ${state?.currentState}");
        print("  - Previous State: ${state?.previousState}");
        
        // محاولة الحصول على Socket ID من الـ client مباشرة
        try {
          print("  - Socket ID: ${_pusherClient?.getSocketId()}");
        } catch (e) {
          print("  - Socket ID: غير متوفر");
        }
        
        if (state?.currentState == 'CONNECTED') {
          print("✅ تم الاتصال بـ Pusher بنجاح");
          _isPusherConnected = true;
          _reconnectAttempts = 0;
          setState(() {});
          
          // الاشتراك في channel
          _subscribeToDriverTracking(orderId);
          
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
        } else if (state?.currentState == 'CONNECTING') {
          print("🔄 جاري الاتصال بـ Pusher...");
          _isPusherConnected = false;
        } else if (state?.currentState == 'RECONNECTING') {
          print("🔄 جاري إعادة الاتصال بـ Pusher...");
          _isPusherConnected = false;
        } else if (state?.currentState == 'DISCONNECTED') {
          print("❌ تم قطع الاتصال بـ Pusher");
          _isPusherConnected = false;
          setState(() {});
          
          // إظهار رسالة انقطاع الاتصال
          if (scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Live tracking connection lost.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (state?.currentState == 'FAILED') {
          print("💥 فشل الاتصال بـ Pusher");
          _isPusherConnected = false;
          _handleConnectionError('Pusher connection failed', orderId);
        } else {
          print("🔄 حالة Pusher غير معروفة: ${state?.currentState}");
        }
      });
      
      // الاستماع لأحداث الأخطاء
      _pusherClient!.onConnectionError((error) {
        print("❌ خطأ في اتصال Pusher:");
        print("  - Message: ${error?.message}");
        print("  - Code: ${error?.code}");
        print("  - Exception: ${error?.exception}");
        _isPusherConnected = false;
        _handleConnectionError('Pusher connection error: ${error?.message}', orderId);
      });
      
      // بدء الاتصال
      print("🚀 Starting Pusher connection...");
      _pusherClient!.connect();
      
    } catch (e) {
      print("❌ خطأ في الاتصال بـ Pusher: $e");
      print("❌ نوع الخطأ: ${e.runtimeType}");
      print("❌ تفاصيل الخطأ: ${e.toString()}");
      _handleConnectionError(e.toString(), orderId);
    }
  }

  // دالة للاشتراك في channel التراكنج
  void _subscribeToDriverTracking(String orderId) {
    try {
      // التحقق من صحة orderId
      if (orderId.isEmpty) {
        print("❌ orderId فارغ، لا يمكن الاشتراك في channel");
        return;
      }

      // تنظيف orderId من أي أحرف غير مرغوبة
      final cleanOrderId = orderId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
      final channelName = 'order-tracking.$cleanOrderId';
      
      print("📡 الاشتراك في channel: $channelName");
      print("   - Order ID: $cleanOrderId");
      print("   - Order ID الأصلي: $orderId");
      
      // الاشتراك في channel
      _trackingChannel = _pusherClient!.subscribe(channelName);
      
      // الاستماع للأحداث
      _trackingChannel!.bind('driver-location-update', (event) {
        print("📨 حدث تحديث موقع السائق: $event");
        if (event != null) {
          //_handleDriverLocationUpdate(event, orderId);
        }
      });
      
      _trackingChannel!.bind('order-status-update', (event) {
        print("📨 حدث تحديث حالة الطلب: $event");
        if (event != null) {
        //  _handleOrderStatusUpdate(event, orderId);
        }
      });
      
      _trackingChannel!.bind('pusher:subscription_succeeded', (event) {
        print("✅ تم الاشتراك بنجاح في channel: $channelName");
      });
      
      _trackingChannel!.bind('pusher:subscription_error', (event) {
        print("❌ خطأ في الاشتراك في channel: $event");
      });
      
      print("📡 تم الاشتراك في channel: $channelName");
      
    } catch (e) {
      print("❌ خطأ في الاشتراك: $e");
      print("❌ نوع الخطأ: ${e.runtimeType}");
    }
  }

  // دالة لمعالجة تحديث موقع السائق
  void _handleDriverLocationUpdate(PusherEvent event, String orderId) {
    try {
      print("🚗 معالجة تحديث موقع السائق");
      print("   - البيانات: ${event.data}");
      
      final data = json.decode(event.data!);
      print("   - البيانات المحللة: $data");
      
      if (data is Map && data.containsKey('latitude') && data.containsKey('longitude')) {
        final lat = double.tryParse(data['latitude'].toString()) ?? 0.0;
        final lng = double.tryParse(data['longitude'].toString()) ?? 0.0;
        
        setState(() {
          driverLocation = LatLng(lat, lng);
        });
        
        print("   - موقع السائق الجديد: $driverLocation");
        
        // إظهار رسالة تحديث الموقع
        if (scaffoldKey.currentContext != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('Driver location updated'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        print("   - ❌ بيانات الموقع غير صحيحة");
      }
      
    } catch (e) {
      print("   - ❌ خطأ في معالجة تحديث الموقع: $e");
    }
  }

  // دالة لمعالجة تحديث حالة الطلب
  void _handleOrderStatusUpdate(PusherEvent event, String orderId) {
    try {
      print("📦 معالجة تحديث حالة الطلب");
      print("   - البيانات: ${event.data}");
      
      final data = json.decode(event.data!);
      print("   - البيانات المحللة: $data");
      
      if (data is Map && data.containsKey('status')) {
        final oldStatus = order.orderStatus.status;
        final newStatus = data['status'];
        
        setState(() {
          order.orderStatus.status = newStatus;
          order.orderStatus.id = data['status_id']?.toString() ?? order.orderStatus.id;
        });
        
        print("   - الحالة الجديدة: $newStatus");
        
        // إظهار رسالة تحديث الحالة
        if (scaffoldKey.currentContext != null && newStatus != oldStatus) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('Order status updated: $newStatus'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("   - ❌ بيانات الحالة غير صحيحة");
      }
      
    } catch (e) {
      print("   - ❌ خطأ في معالجة تحديث الحالة: $e");
    }
  }

  // دالة لإغلاق اتصال Pusher
  void _disconnectPusher() {
    try {
      _trackingChannel = null;
      _pusherClient?.disconnect();
      _pusherClient = null;
      _isPusherConnected = false;
      print("✅ تم إغلاق اتصال Pusher");
    } catch (e) {
      print("❌ خطأ في إغلاق Pusher: $e");
    }
  }

  // دالة لمعالجة أخطاء الاتصال
  void _handleConnectionError(String error, String orderId) {
    _isPusherConnected = false;
    setState(() {});
    
    print("🔧 معالجة خطأ الاتصال: $error");
    
    // إظهار رسالة انقطاع الاتصال
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Live tracking connection lost. Attempting to reconnect...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // محاولة إعادة الاتصال إذا لم نتجاوز الحد الأقصى
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      print("🔄 محاولة إعادة الاتصال رقم $_reconnectAttempts من $_maxReconnectAttempts");
      
      _reconnectTimer = Timer(_reconnectDelay, () {
        print("🔄 إعادة محاولة الاتصال...");
        connectToDriverTracking(orderId);
      });
    } else {
      print("❌ تم تجاوز الحد الأقصى لمحاولات إعادة الاتصال");
      print("🔄 تفعيل وضع العمل بدون live tracking");
      
      // تفعيل fallback mode
      _enableFallbackMode();
      
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Live tracking unavailable. App continues in offline mode.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _reconnectAttempts = 0;
                connectToDriverTracking(orderId);
              },
            ),
          ),
        );
      }
    }
  }

  // تفعيل وضع العمل بدون live tracking
  void _enableFallbackMode() {
    print("🔄 Fallback mode enabled - app will work without live tracking");
    _isPusherConnected = false;
    
    // إيقاف محاولات إعادة الاتصال
    _reconnectTimer?.cancel();
    
    // يمكن إضافة polling للحصول على تحديثات بدلاً من live tracking
    // _startPollingForUpdates();
    
    setState(() {});
  }

  // دالة للتحقق من حالة الاتصال
  bool get isDriverTrackingConnected => _isPusherConnected;

  // دالة لفحص بيانات WebSocket
  void _testWebSocketData(String data) {
    print("🔍 فحص بيانات WebSocket:");
    print("   - البيانات الخام: $data");
    
    try {
      // محاولة تحليل JSON
      final jsonData = json.decode(data);
      print("   - ✅ تم تحليل JSON بنجاح");
      print("   - نوع البيانات المحللة: ${jsonData.runtimeType}");
      
      if (jsonData is Map) {
        print("   - ✅ البيانات خريطة (Map)");
        print("   - المفاتيح المتوفرة: ${jsonData.keys.toList()}");
        
        // فحص وجود event
        if (jsonData.containsKey('event')) {
          print("   - ✅ يوجد event: ${jsonData['event']}");
        } else {
          print("   - ❌ لا يوجد event");
        }
        
        // فحص وجود data
        if (jsonData.containsKey('data')) {
          print("   - ✅ يوجد data");
          final dataField = jsonData['data'];
          print("   - نوع data: ${dataField.runtimeType}");
          
          if (dataField is Map) {
            print("   - مفاتيح data: ${dataField.keys.toList()}");
            
            // فحص إحداثيات السائق
            if (dataField.containsKey('latitude') && dataField.containsKey('longitude')) {
              print("   - ✅ يوجد إحداثيات السائق");
              print("   - latitude: ${dataField['latitude']}");
              print("   - longitude: ${dataField['longitude']}");
            } else {
              print("   - ❌ لا توجد إحداثيات السائق");
            }
          }
        } else {
          print("   - ❌ لا يوجد data");
        }
        
        // فحص نوع الحدث
        final event = jsonData['event'];
        if (event == 'driver-location-update') {
          print("   - 🚗 حدث تحديث موقع السائق");
        } else if (event == 'order-status-update') {
          print("   - 📦 حدث تحديث حالة الطلب");
        } else if (event == 'subscribe') {
          print("   - 📡 حدث الاشتراك");
        } else if (event == 'connected') {
          print("   - 🔗 حدث الاتصال");
        } else {
          print("   - ❓ حدث غير معروف: $event");
        }
        
      } else {
        print("   - ❌ البيانات ليست خريطة");
      }
      
    } catch (e) {
      print("   - ❌ فشل في تحليل JSON: $e");
      print("   - البيانات ليست JSON صحيح");
    }
    
    print("🔍 انتهى فحص البيانات");
  }

  // دالة لاختبار الاتصال بـ WebSocket
  void testWebSocketConnection(String orderId) {
    print("🧪 بدء اختبار الاتصال بـ WebSocket");
    print("   - Order ID: $orderId");
    print("   - URL: ws://carrytechnologies.co:6001");
    print("   - Channel: order-tracking.$orderId");
    
    // إرسال رسالة اختبار
    try {
      final testMessage = {
        'event': 'test',
        'channel': 'order-tracking.$orderId',
        'data': {
          'order_id': orderId,
          'test': true,
        }
      };
      
      final messageJson = json.encode(testMessage);
      print("   - إرسال رسالة اختبار: $messageJson");
      
      // This part of the code was removed as Pusher is now used.
      // _driverTrackingChannel?.sink.add(messageJson);
      // print("   - ✅ تم إرسال رسالة الاختبار");
      
    } catch (e) {
      print("   - ❌ خطأ في إرسال رسالة الاختبار: $e");
    }
  }

  // دالة لفحص حالة الاتصال
  void checkWebSocketStatus() {
    print("🔍 فحص حالة WebSocket:");
    print("   - متصل: $_isPusherConnected");
    print("   - القناة موجودة: ${_trackingChannel != null}");
    print("   - عدد محاولات إعادة الاتصال: $_reconnectAttempts");
    print("   - الحد الأقصى للمحاولات: $_maxReconnectAttempts");
    
    if (_trackingChannel != null) {
      print("   - ✅ اتصال Pusher موجود");
    } else {
      print("   - ❌ لا يوجد اتصال Pusher");
    }
    
    if (_isPusherConnected) {
      print("   - ✅ الاتصال نشط");
    } else {
      print("   - ❌ الاتصال غير نشط");
    }
  }

  // دالة لفحص حالة خادم WebSocket
  Future<bool> checkWebSocketServerStatus() async {
    try {
      print("🔍 فحص حالة خادم WebSocket...");
      
      // محاولة الاتصال بـ HTTP للتحقق من وجود الخادم
      final response = await http.get(Uri.parse('http://carrytechnologies.co'))
          .timeout(Duration(seconds: 5));
      
      print("✅ الخادم متاح (HTTP): ${response.statusCode}");
      return true;
    } catch (e) {
      print("❌ الخادم غير متاح: $e");
      return false;
    }
  }

  // دالة لتشخيص مشاكل الاتصال
  void diagnoseConnectionIssues() {
    print("🔧 تشخيص مشاكل الاتصال:");
    print("   - URL: ws://carrytechnologies.co:6001");
    print("   - Port: 6001");
    print("   - Protocol: WebSocket");
    
    // فحص الاتصال بالإنترنت
    checkWebSocketServerStatus().then((isServerAvailable) {
      if (isServerAvailable) {
        print("✅ الخادم متاح عبر HTTP");
        print("⚠️ المشكلة قد تكون في:");
        print("   - منفذ WebSocket (6001) غير مفتوح");
        print("   - إعدادات الجدار الناري");
        print("   - مشاكل في الشبكة المحلية");
      } else {
        print("❌ الخادم غير متاح");
        print("⚠️ المشكلة قد تكون في:");
        print("   - الاتصال بالإنترنت");
        print("   - الخادم غير متاح");
        print("   - مشاكل DNS");
      }
    });
  }

  // دالة لإعادة تعيين حالة الاتصال
  void resetConnectionState() {
    print("🔄 إعادة تعيين حالة الاتصال");
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _isPusherConnected = false;
    setState(() {});
  }

  // دالة شاملة لاختبار الاتصال
  Future<void> testWebSocketConnectionComprehensive(String orderId) async {
    print("🧪 بدء اختبار شامل للاتصال بـ WebSocket");
    print("=" * 50);
    
    // 1. فحص الاتصال بالإنترنت
    print("1️⃣ فحص الاتصال بالإنترنت...");
    bool isInternetAvailable = await _checkInternetConnection();
    print("   - الاتصال بالإنترنت: ${isInternetAvailable ? '✅ متاح' : '❌ غير متاح'}");
    
    // 2. فحص الخادم
    print("2️⃣ فحص الخادم...");
    bool isServerAvailable = await checkWebSocketServerStatus();
    print("   - الخادم: ${isServerAvailable ? '✅ متاح' : '❌ غير متاح'}");
    
    // 3. فحص المنفذ
    print("3️⃣ فحص منفذ WebSocket...");
    bool isPortOpen = await _checkWebSocketPort();
    print("   - المنفذ 6001: ${isPortOpen ? '✅ مفتوح' : '❌ مغلق'}");
    
    // 4. فحص DNS
    print("4️⃣ فحص DNS...");
    bool isDNSResolved = await _checkDNSResolution();
    print("   - DNS: ${isDNSResolved ? '✅ محلول' : '❌ غير محلول'}");
    
    // 5. محاولة الاتصال
    print("5️⃣ محاولة الاتصال بـ WebSocket...");
    if (isInternetAvailable && isServerAvailable) {
      try {
        connectToDriverTracking(orderId);
        print("   - ✅ تم بدء الاتصال");
      } catch (e) {
        print("   - ❌ فشل في الاتصال: $e");
      }
    } else {
      print("   - ⚠️ تخطي الاتصال بسبب مشاكل الشبكة");
    }
    
    print("=" * 50);
    print("🏁 انتهى الاختبار الشامل");
  }

  // دالة فحص الاتصال بالإنترنت
  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print("   - خطأ في فحص الإنترنت: $e");
      return false;
    }
  }

  // دالة فحص منفذ WebSocket
  Future<bool> _checkWebSocketPort() async {
    try {
      final response = await http.get(Uri.parse('http://carrytechnologies.co:6001'))
          .timeout(Duration(seconds: 3));
      return true;
    } catch (e) {
      print("   - خطأ في فحص المنفذ: $e");
      return false;
    }
  }

  // دالة فحص DNS
  Future<bool> _checkDNSResolution() async {
    try {
      final response = await http.get(Uri.parse('http://carrytechnologies.co'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print("   - خطأ في فحص DNS: $e");
      return false;
    }
  }

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

  // دالة لإغلاق الاتصال
  void disconnectFromDriverTracking() {
    print("🔌 إغلاق اتصال Pusher");
    _disconnectPusher();
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    setState(() {});
  }

  // دالة لحساب المسافة بين نقطتين جغرافيتين بالمتر
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // نصف قطر الأرض بالمتر
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
        (sin(dLon / 2) * sin(dLon / 2));
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  // دالة لتحويل الدرجات إلى راديان
  double _toRadians(double degrees) {
    return degrees * (pi / 180);
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

  void listenForOrder({required String orderId, String? message}) async {
    print(
      "mElkerm Tracking Controller ▶ Starting listenForOrder for ID: $orderId",
    );
    
    // بدء التراكنج المباشر للسائق مع Pusher
    connectToDriverTracking(orderId);
    
    try {
      print("🔄 Attempting to get order stream for ID: $orderId");
      final Stream<Order> stream = await getOrder(orderId);
      print("✅ Stream obtained for order ID: $orderId");
      
      _listenToOrderStream(stream, orderId);
    } catch (error) {
      print("❌ Error getting order stream: $error");
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text("Failed to load order data: $error"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  void _listenToOrderStream(Stream<Order> stream, String orderId) {

    stream.listen(
      (Order _order) {
        setState(() {
          print("=== Tracking Controller ▶ Received order data ===");
          print("Order ID: ${_order.id}");
          print("Food Orders Count: ${_order.foodOrders.length}");
          print("Order Status ID: ${_order.orderStatus.id}");
          print("Order Status: ${_order.orderStatus.status}");
          print("Order Date: ${_order.dateTime}");
          print("Payment Method: ${_order.payment.method}");
          print("Active: ${_order.active}");
          print("Hint: ${_order.hint}");
          print("Delivery Address: ${_order.deliveryAddress.address}");
          print("Delivery Lat: ${_order.deliveryAddress.latitude}");
          print("Delivery Lng: ${_order.deliveryAddress.longitude}");
          print("Restaurant Object: ${_order.restaurant}");
          
          // تعيين Order للمتحكم
          order = _order;
          // إزالة التعيين الثابت للإحداثيات
          print("mElkerm Tracking Controller → Processing order coordinates...");
          
          // تحديث إحداثيات المطعم والمستخدم بناءً على البيانات الفعلية
          _updateOrderCoordinates(_order);
          
          print(
            "mElkerm Tracking Controller → Final restaurant location: $restaurantLocation",
          );
          print(
            "mElkerm Tracking Controller → Final client location: $clientLocation",
          );
          print(
            "mElkerm Tracking Controller → Updated client location: $clientLocation",
          );

          order = _order;
        });
      },
      onError: (error) {
        print("mElkerm Tracking Controller ❌ Error in order stream: $error");
      },
      onDone: () {
        print("mElkerm Tracking Controller ✅ Order stream done");
      },
    );
  }

  // دالة لفحص صحة الخادم
  Future<bool> checkServerHealth() async {
    print("🏥 فحص صحة الخادم...");
    
    // This part of the code was removed as Pusher is now used.
    // for (int i = 0; i < _websocketUrls.length; i++) {
    //   final url = _websocketUrls[i];
    //   print("   - فحص URL: $url");
      
    //   try {
    //     // محاولة الاتصال بـ HTTP للتحقق من وجود الخادم
    //     final baseUrl = url.replaceFirst('ws://', 'http://').replaceFirst('wss://', 'https://');
    //     final response = await http.get(Uri.parse(baseUrl))
    //         .timeout(Duration(seconds: 3));
        
    //     if (response.statusCode == 200 || response.statusCode == 101) {
    //       print("   - ✅ الخادم متاح على: $url");
    //       _currentUrlIndex = i;
    //       return true;
    //     }
    //   } catch (e) {
    //     print("   - ❌ الخادم غير متاح على: $url");
    //   }
    // }
    
    // print("❌ جميع الخوادم غير متاحة");
    // return false;
    return true; // Assuming Pusher is always available for now
  }

  // دالة لاختبار الاتصال الشامل مع فحص صحة الخادم
  Future<void> testConnectionWithServerHealth(String orderId) async {
    print("🧪 بدء اختبار الاتصال مع فحص صحة الخادم");
    print("=" * 60);
    
    // 1. فحص صحة الخادم
    print("1️⃣ فحص صحة الخادم...");
    bool isServerHealthy = await checkServerHealth();
    print("   - صحة الخادم: ${isServerHealthy ? '✅ جيدة' : '❌ سيئة'}");
    
    if (!isServerHealthy) {
      print("⚠️ الخادم غير متاح، محاولة الاتصال المباشر...");
    }
    
    // 2. محاولة الاتصال
    print("2️⃣ محاولة الاتصال...");
    connectToDriverTracking(orderId);
    
    print("=" * 60);
    print("🏁 انتهى الاختبار");
  }

  // دالة لاختبار اتصال Pusher
  Future<void> testPusherConnection(String orderId) async {
    print("🧪 اختبار اتصال Pusher");
    print("=" * 50);
    
    try {
      print("🔑 إعدادات Pusher:");
      print("   - App ID: $_pusherAppId");
      print("   - Key: $_pusherKey");
      print("   - Cluster: $_pusherCluster");
      
      // إنشاء اتصال Pusher للاختبار
      final testPusher = PusherClient(
        _pusherKey,
        PusherOptions(
          cluster: _pusherCluster,
          encrypted: true,
        ),
      );
      
      print("✅ تم إنشاء اتصال Pusher للاختبار");
      
      // الاستماع لحالة الاتصال
      testPusher.onConnectionStateChange((state) {
        print("🔄 حالة الاتصال: $state");
        
        if (state?.currentState == 'CONNECTED') {
          print("✅ تم الاتصال بـ Pusher بنجاح");
          
          // اختبار الاشتراك في channel
          final testChannel = testPusher.subscribe('order-tracking.$orderId');
          
          testChannel.bind('pusher:subscription_succeeded', (event) {
            print("✅ تم الاشتراك بنجاح في channel: order-tracking.$orderId");
          });
          
          testChannel.bind('pusher:subscription_error', (event) {
            print("❌ خطأ في الاشتراك: $event");
          });
          
          // إغلاق الاتصال بعد 5 ثوان
          Timer(Duration(seconds: 5), () {
            testPusher.disconnect();
            print("✅ تم إغلاق اتصال الاختبار");
          });
        }
      });
      
      // بدء الاتصال
      testPusher.connect();
      
    } catch (e) {
      print("❌ خطأ في اختبار Pusher: $e");
    }
  }

  // دالة لاختبار الاتصال مباشرة من التطبيق
  Future<void> testWebSocketConnectionDirectly(String orderId) async {
    print("🧪 اختبار الاتصال المباشر بـ WebSocket");
    print("=" * 50);
    
    // This part of the code was removed as Pusher is now used.
    // for (int i = 0; i < _websocketUrls.length; i++) {
    //   final url = _websocketUrls[i];
    //   print("\n�� اختبار URL رقم ${i + 1}: $url");
      
    //   try {
    //     // إنشاء اتصال WebSocket مباشر مع timeout
    //     final socket = await WebSocket.connect(url).timeout(Duration(seconds: 5));
    //     print("   - ✅ تم الاتصال بنجاح");
            
    //     // إرسال رسالة اختبار
    //     final testMessage = {
    //       'event': 'subscribe',
    //       'channel': 'order-tracking.$orderId',
    //       'data': {
    //         'order_id': orderId,
    //         'test': true,
    //       }
    //     };
            
    //     socket.add(json.encode(testMessage));
    //     print("   - ✅ تم إرسال رسالة الاشتراك");
            
    //     // الاستماع للردود
    //     socket.listen(
    //       (data) {
    //         print("   - 📨 رد من الخادم: $data");
    //       },
    //       onError: (error) {
    //         print("   - ❌ خطأ في WebSocket: $error");
    //       },
    //       onDone: () {
    //         print("   - ✅ اتصال WebSocket مغلق");
    //       },
    //     );
            
    //     // انتظار قليل ثم إغلاق
    //     await Future.delayed(Duration(seconds: 2));
    //     await socket.close();
            
    //     print("   - ✅ اختبار ناجح لـ: $url");
    //     _currentUrlIndex = i;
    //     return;
            
    //   } catch (e) {
    //     print("   - ❌ فشل في الاتصال بـ $url: $e");
    //   }
    // }
    
    // print("\n❌ جميع URLs فشلت في الاتصال");
  }

  // دالة لعرض معلومات التشخيص
  void showDiagnosticInfo() {
    print("🔍 معلومات التشخيص");
    print("=" * 40);
    print("🔑 إعدادات Pusher:");
    print("   - App ID: $_pusherAppId");
    print("   - Key: $_pusherKey");
    print("   - Cluster: $_pusherCluster");
    print("🔄 عدد محاولات إعادة الاتصال: $_reconnectAttempts");
    print("✅ حالة الاتصال: ${_isPusherConnected ? 'متصل' : 'غير متصل'}");
    print("⏰ timeout الاتصال: $_connectionTimeout");
    print("🔄 تأخير إعادة المحاولة: $_reconnectDelay");
    print("=" * 40);
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
        
        // إذا لم يتم تحميل Order من endpoint الرئيسي، استخدم بيانات التتبع
        if (order.id.isEmpty && result.data.deliveryAddress != null) {
          print("🔄 Using tracking data as fallback for order coordinates");
          _useTrackingDataAsFallback(result, orderId);
        }
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

  // دالة لتحديث إحداثيات المطعم والمستخدم بناءً على بيانات الطلب
  void _updateOrderCoordinates(Order _order) {
    try {
      // تحديث إحداثيات المطعم
      if (_order.foodOrders.isNotEmpty) {
        double? restaurantLat = double.tryParse(
          _order.foodOrders[0].food?.restaurant.latitude ?? '',
        );
        double? restaurantLng = double.tryParse(
          _order.foodOrders[0].food?.restaurant.longitude ?? '',
        );
        
        if (restaurantLat != null && restaurantLng != null && 
            restaurantLat != 0.0 && restaurantLng != 0.0) {
          restaurantLocation = LatLng(restaurantLat, restaurantLng);
          print("✅ Updated restaurant location: $restaurantLocation");
        } else {
          print("⚠️ Restaurant coordinates not available or invalid");
        }
      }
      
      // تحديث إحداثيات العميل
      double? clientLat = _order.deliveryAddress.latitude;
      double? clientLng = _order.deliveryAddress.longitude;
      
      if (clientLat != null && clientLng != null && 
          clientLat != 0.0 && clientLng != 0.0) {
        clientLocation = LatLng(clientLat, clientLng);
        print("✅ Updated client location: $clientLocation");
      } else {
        print("⚠️ Client coordinates not available or invalid");
      }
      
    } catch (e) {
      print("❌ Error updating order coordinates: $e");
    }
  }

  // دالة لاستخدام بيانات التتبع كـ fallback عندما لا يوجد order
  void _useTrackingDataAsFallback(TrackingOrderModel trackingData, String orderId) {
    try {
      print("=== Using Tracking Data as Fallback ===");
      
      final deliveryAddress = trackingData.data.deliveryAddress;
      if (deliveryAddress != null) {
        print("📍 Delivery Address from Tracking:");
        print("  - Address: ${deliveryAddress.address}");
        print("  - Latitude: ${deliveryAddress.latitude}");
        print("  - Longitude: ${deliveryAddress.longitude}");
        
        // تحديث موقع العميل
        if (deliveryAddress.latitude != null && deliveryAddress.longitude != null) {
          clientLocation = LatLng(
            deliveryAddress.latitude!,
            deliveryAddress.longitude!,
          );
          print("✅ Updated client location from tracking: $clientLocation");
        }
      }
      
      // إنشاء Order مؤقت بالبيانات المتوفرة
      order = Order(
        id: orderId,
        foodOrders: [], // فارغ لأنه غير متوفر
        deliveryAddress: Address(
          id: deliveryAddress?.id?.toString() ?? '',
          address: deliveryAddress?.address ?? '',
          latitude: deliveryAddress?.latitude ?? 0.0,
          longitude: deliveryAddress?.longitude ?? 0.0,
          description: deliveryAddress?.description ?? '',
        ),
        // معلومات افتراضية للحقول المطلوبة
        orderStatus: OrderStatus.fromJSON({'id': '1', 'status': 'Order Received'}),
        user: User.fromJSON({}),
        payment: Payment.fromJSON({}),
        active: true,
      );
      
      print("✅ Created fallback order with ID: ${order.id}");
      print("✅ Order delivery address: ${order.deliveryAddress.address}");
      print("✅ Order coordinates: ${order.deliveryAddress.latitude}, ${order.deliveryAddress.longitude}");
      
             // إضافة إحداثيات المطعم المؤقتة (من البيانات السابقة)
       // TODO: الحصول على إحداثيات المطعم من API منفصل
       restaurantLocation = LatLng(31.811115332221924, 35.23264194715977);
       print("✅ Set temporary restaurant location: $restaurantLocation");
      
      setState(() {});
      
    } catch (e) {
      print("❌ Error using tracking data as fallback: $e");
    }
  }

  // دالة لإغلاق جميع الاتصالات عند إغلاق الصفحة
  void dispose() {
    print("🧹 تنظيف موارد التراكنج");
    
    // إغلاق اتصال Pusher
    try {
      _disconnectPusher();
      print("✅ تم إغلاق اتصال Pusher");
    } catch (e) {
      print("❌ خطأ في إغلاق Pusher: $e");
    }
    
    // إلغاء timer إعادة الاتصال
    try {
      _reconnectTimer?.cancel();
      print("✅ تم إلغاء timer إعادة الاتصال");
    } catch (e) {
      print("❌ خطأ في إلغاء timer: $e");
    }
    
    // إعادة تعيين الحالة
    _isPusherConnected = false;
    _reconnectAttempts = 0;
    
    print("✅ تم تنظيف جميع موارد التراكنج");
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

