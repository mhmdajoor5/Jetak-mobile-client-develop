import 'package:flutter/material.dart';
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

  void listenForOrder({required String orderId, String? message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForOrderStatus();
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  TrackingOrderModel? trackingOrderDetails  = null;
  Future<void> getOrderDetailsTracking({required String orderId, String? message}) async {
    print("mElkerm ##### Start fetching tracking order data for order ID: $orderId");

    setState(() {
      // You can set a loading flag here if needed
    });

    try {
      final result = await getTrackingOrderModel(orderId: '225');
      // final result = await getTrackingOrderModel(orderId: orderId);

      setState(() {
        // Assume your screen uses this `trackingOrderList`
        trackingOrderDetails = result;
      });

      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      // Optionally call another method after loading
      listenForOrderStatus();

      print("mElkerm ##### Successfully fetched tracking data");

    } catch (error) {
      print("mElkerm ##### Error fetching tracking order data: $error");
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection)),
      );
    }
  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus _orderStatus) {
      setState(() {
        orderStatus.add(_orderStatus);
      });
    }, onError: (a) {}, onDone: () {});
  }

  List<Step> getTrackingSteps(BuildContext context, int currentOrderStatus) {
    List<Step> _orderStatusSteps = [];

    List<OrderStatus> statuses = [...this.orderStatus];

    for (OrderStatus status in statuses) {
      print("name: ${status.status} + id: ${status.id}");
    }

    statuses.removeWhere((element) =>
        element.id == "6" || element.id == "7");
    if (order.payment.method == "Pay on Pickup") {
      statuses.removeWhere((element) =>
      element.id == "5" || element.id == "4");
    }
    statuses.forEach((OrderStatus _orderStatus) {
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          _orderStatus.status,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: order.orderStatus.id == _orderStatus.id
            ? Text(
                '${DateFormat('HH:mm | yyyy-MM-dd').format(order.dateTime)}',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              )
            : SizedBox(height: 0),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '${Helper.skipHtml(order.hint)}',
            )),
        isActive: (currentOrderStatus + 1) >=
            (int.tryParse(_orderStatus.id)!),
      ));
    });
    return _orderStatusSteps;
  }

  Future<void> refreshOrder() async {
    order = new Order();
    listenForOrder(orderId: order.id, message: S.of(state!.context).tracking_refreshed_successfuly);
    getOrderDetailsTracking(orderId: order.id, message: S.of(state!.context).tracking_refreshed_successfuly);
  }

  void doCancelOrder() {
    cancelOrder(this.order).then((value) {
      setState(() {
        this.order.active = false;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      orderStatus = [];
      listenForOrderStatus();
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
            S.of(state!.context).orderThisorderidHasBeenCanceled(this.order.id)),
      ));
    });
  }

  bool canCancelOrder(Order order) {
    return order.active == true && order.orderStatus.id == 1;
  }
}
