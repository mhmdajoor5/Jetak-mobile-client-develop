import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';

class RecentOrdersWidget extends StatefulWidget {
  final bool fromProfile;

  RecentOrdersWidget({this.fromProfile = false});
  @override
  _RecentOrdersWidgetState createState() => _RecentOrdersWidgetState();
}

class _RecentOrdersWidgetState extends StateMVC<RecentOrdersWidget> {
  late ProfileController _con;

  _RecentOrdersWidgetState() : super(ProfileController()) {
    _con = controller as ProfileController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForRecentOrders();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.fromProfile) {
          Navigator.pop(context); // رجوع للبروفايل
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/Pages',
                (route) => false,
            arguments: 0, // تبويب Home
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(S
            .of(context)
            .recent_orders)),
        body: _con.recentOrders.isEmpty
            ? EmptyOrdersWidget()
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: _con.recentOrders.length,
          separatorBuilder: (_, __) => SizedBox(height: 20),
                                itemBuilder: (_, index) {
            var order = _con.recentOrders[index];
            return OrderItemWidget(
              expanded: index == 0,
              order: order,
            );
          },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}