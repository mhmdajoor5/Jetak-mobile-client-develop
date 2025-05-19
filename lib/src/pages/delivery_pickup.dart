import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  DeliveryPickupWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  late DeliveryPickupController _con;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  @override
  Widget build(BuildContext context) {
    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
      //      widget.pickup = widget.list.pickupList.elementAt(0);
      //      widget.delivery = widget.list.pickupList.elementAt(1);
    }
    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: CartBottomDetailsWidget(con: _con, deliveryPickupController: _con),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        title: Text(S.of(context).delivery_or_pickup, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3))),
        actions: <Widget>[new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).colorScheme.secondary)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(Icons.domain, color: Theme.of(context).hintColor),
                title: Text(S.of(context).pickup, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineLarge),
                subtitle: Text(S.of(context).pickup_your_food_from_the_restaurant, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            PickUpMethodItem(
              paymentMethod: _con.getPickUpMethod(),
              onPressed: (paymentMethod) {
                _con.togglePickUp();
              },
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    trailing: TextButton(
                      child: Text("edit"),
                      onPressed: () async {
                        var address = await Navigator.of(context).pushNamed('/DeliveryAddresses', arguments: true);

                        if (address != null) {
                          setState(() {
                            _con.deliveryAddress = address as Address;
                          });
                        }
                      },
                    ),
                    leading: Icon(Icons.map, color: Theme.of(context).hintColor),
                    title: Text(S.of(context).delivery, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineLarge),
                  ),
                ),
                _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].food!.restaurant, carts: _con.carts)
                    ? DeliveryAddressesItemWidget(
                      paymentMethod: _con.getDeliveryMethod(),
                      address: _con.deliveryAddress,
                      onPressed: (Address _address) {
                        if (_con.deliveryAddress?.id == null || _con.deliveryAddress?.id == 'null') {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (Address _address) {
                              _con.addAddress(_address);
                            },
                          );
                        } else {
                          _con.toggleDelivery();
                        }
                      },
                      onLongPress: (Address _address) {
                        DeliveryAddressDialog(
                          context: context,
                          address: _address,
                          onChanged: (Address _address) {
                            _con.updateAddress(_address);
                          },
                        );
                      },
                    )
                    : NotDeliverableAddressesItemWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
