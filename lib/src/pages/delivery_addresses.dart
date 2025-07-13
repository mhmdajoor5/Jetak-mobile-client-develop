import 'package:flutter/material.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_addresses_controller.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CircularLoadingWidget.dart';

import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final bool shouldChooseDeliveryHere ;
  late DeliveryPickupController conDeliverPickupController ;


  DeliveryAddressesWidget({Key? key, this.routeArgument, required this.shouldChooseDeliveryHere , required this.conDeliverPickupController}) : super(key: key);

  @override
  _DeliveryAddressesWidgetState createState() => _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends StateMVC<DeliveryAddressesWidget> {
  late DeliveryAddressesController _con;
  PaymentMethodList? list;
  Address? selectedAddress; // Track the selected address

  _DeliveryAddressesWidgetState() : super(DeliveryAddressesController()) {
    _con = controller as DeliveryAddressesController;
  }

  @override
  Widget build(BuildContext context) {
    list = PaymentMethodList(context);
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_addresses,
          style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshAddresses,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: ListTile(
                  leading: Icon(Icons.map, color: Theme.of(context).hintColor),
                  title: Text(
                      S.of(context).delivery_addresses,
                      style: Theme.of(context).textTheme.headlineLarge
                  ),
                  subtitle: Text(
                    S.of(context).long_press_to_edit_item_swipe_item_to_delete_it,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/DeliveryAddressForm', arguments: {
                    'address': Address(),
                    'onChanged': (Address _address) {
                      _con.addAddress(_address);
                    },
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                      SizedBox(width: 10),
                      Text(
                        S.of(context).add_new_delivery_address,
                        style: Theme.of(context).textTheme.titleMedium?.merge(
                          TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _con.addresses.isEmpty
                  ? CircularLoadingWidget(height: 250)
                  : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 15),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: _con.addresses.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return DeliveryAddressesItemWidget(
                    address: _con.addresses.elementAt(index),
                    isSelected: widget.shouldChooseDeliveryHere &&
                        selectedAddress == _con.addresses.elementAt(index),
                    onPressed: (Address _address) {
                      if (widget.shouldChooseDeliveryHere) {
                        setState(() {
                          selectedAddress = _address;
                          // Update selected address
                        });
                      } else {
                        Navigator.of(context).pushNamed('/DeliveryAddressForm', arguments: {
                          'address': _address,
                          'onChanged': (Address _address) {
                            _con.updateAddress(_address);
                          },
                        });
                      }
                    },
                    onLongPress: (Address _address) {
                      Navigator.of(context).pushNamed('/DeliveryAddressForm', arguments: {
                        'address': _address,
                        'onChanged': (Address _address) {
                          _con.updateAddress(_address);
                        },
                      });
                    },
                    onDismissed: (Address _address) {
                      _con.removeDeliveryAddress(_address);
                    },

                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.shouldChooseDeliveryHere && selectedAddress != null
          ? BottomAppBar(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0,vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              setState((){
                print("mElkerm : address before update -> ${widget.conDeliverPickupController.userDeliverAddress}");
                widget.conDeliverPickupController.userDeliverAddress = selectedAddress!.address.toString();
                print("mElkerm : address after update -> ${widget.conDeliverPickupController.userDeliverAddress}");
                // _conDeliverPickupController.deliveryAddress = selectedAddress;
                // _conDeliverPickupController.userDeliverAddress = selectedAddress!.address.toString();
              });
              Navigator.of(context).pop(selectedAddress); // Pass back the selected address
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Theme.of(context).colorScheme.secondary, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0), // Border radius
              ),
            ),
            child: Text(
              "Select",
              style: TextStyle(
                fontSize: 16, // Adjust font size
                fontWeight: FontWeight.normal, // Make text bold
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}