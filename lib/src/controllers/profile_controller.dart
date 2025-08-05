import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class ProfileController extends ControllerMVC {
  List<Order> recentOrders = [];
  late GlobalKey<ScaffoldState> scaffoldKey;

  ProfileController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    //listenForRecentOrders();
  }

  void listenForRecentOrders({String? message}) async {
    print("🚀 بدء جلب الطلبات من API...");
    // مسح القائمة السابقة
    setState(() {
      recentOrders.clear();
    });
    
    try {
      // Try the main method first
      final Stream<Order> stream = await getRecentOrders();
      stream.listen((Order _order) {
        print("Order User Name :"+_order.user.firstName.toString());
        setState(() {
          recentOrders.add(_order);
        });
      },
      onError: (error) {
        print("❌ Error with main method: $error");
        print("🔄 Trying fallback method...");
        // Try the fallback method
        _tryFallbackMethod(message);
      },
      onDone: () {
        print("✅ تم جلب ${recentOrders.length} طلب بنجاح");
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text(message),
          ));
        }
      });
    } catch (e) {
      print("❌ Main method failed: $e");
      print("🔄 Trying fallback method...");
      _tryFallbackMethod(message);
    }
  }
  
  void _tryFallbackMethod(String? message) async {
    try {
      final Stream<Order> stream = await getRecentOrdersSimple();
      stream.listen((Order _order) {
        print("Order User Name (fallback): "+_order.user.firstName.toString());
        setState(() {
          recentOrders.add(_order);
        });
      },
      onError: (error) {
        print("❌ Fallback method also failed: $error");
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(S.of(state!.context).verify_your_internet_connection),
        ));
      },
      onDone: () {
        print("✅ تم جلب ${recentOrders.length} طلب بنجاح (fallback)");
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text(message),
          ));
        }
      });
    } catch (e) {
      print("❌ Fallback method failed: $e");
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    listenForRecentOrders(message: S.of(state!.context).orders_refreshed_successfuly);
  }
}
