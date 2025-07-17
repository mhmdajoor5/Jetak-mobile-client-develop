import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';

class RecentOrdersWidget extends StatefulWidget {
  @override
  _RecentOrdersWidgetState createState() => _RecentOrdersWidgetState();
}

class _RecentOrdersWidgetState extends State<RecentOrdersWidget> {
  late ProfileController _con;

  @override
  void initState() {
    super.initState();
    _con = ProfileController();
    _con.listenForRecentOrders();
  }

  @override
  void dispose() {
    _con.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).recent_orders),
      ),
      body: _con.recentOrders.isEmpty
          ? EmptyOrdersWidget()
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _con.recentOrders.length,
        separatorBuilder: (context, index) => SizedBox(height: 20),
        itemBuilder: (context, index) {
          var order = _con.recentOrders[index];
          return OrderItemWidget(
            expanded: index == 0,
            order: order,
          );
        },
      ),
    );
  }
}
