import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

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
      final result = await getTrackingOrderModel(orderId: '225');
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
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(S.of(state!.context).verify_your_internet_connection),
        ),
      );
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
