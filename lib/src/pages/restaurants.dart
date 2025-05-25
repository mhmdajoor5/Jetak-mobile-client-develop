import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

class RestaurantsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _RestaurantsWidgetState createState() => _RestaurantsWidgetState();
}

class _RestaurantsWidgetState extends StateMVC<RestaurantsWidget> {

  _RestaurantsWidgetState() : super(OrderController()) {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(icon: new Icon(Icons.sort, color: Theme.of(context).hintColor), onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer()),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(S.of(context).my_orders, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3))),
          actions: <Widget>[new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).colorScheme.secondary)],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Restaurants'),
          ],
        )
    );
  }
}
