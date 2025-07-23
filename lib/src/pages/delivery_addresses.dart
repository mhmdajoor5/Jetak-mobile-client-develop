import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_addresses_controller.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CircularLoadingWidget.dart';

import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import 'delivery_pickup.dart';
import 'new_address/DeliveryAddressFormPage.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final bool shouldChooseDeliveryHere ;
  late DeliveryPickupController conDeliverPickupController ;
  final Address? newAddress;


  DeliveryAddressesWidget({
    Key? key, this.routeArgument,
    required this.shouldChooseDeliveryHere ,
    required this.conDeliverPickupController,
    this.newAddress, }) : super(key: key);

  @override
  _DeliveryAddressesWidgetState createState() => _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends StateMVC<DeliveryAddressesWidget> {
  late DeliveryAddressesController _con;
  PaymentMethodList? list;

  _DeliveryAddressesWidgetState() : super(DeliveryAddressesController()) {
    _con = controller as DeliveryAddressesController;
  }

  @override
  void initState() {
    super.initState();
    if (widget.newAddress != null) {
      _con.addresses.add(widget.newAddress!);
      _con.selectedAddress = widget.newAddress!;
      widget.conDeliverPickupController.userDeliverAddress =
          widget.newAddress!.address ?? '';
    }
    loadAddress();
  }

  void saveAddress(Address address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_address', jsonEncode(address.toJson()));
  }

  void loadAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('saved_address');

    if (savedAddress != null) {
      Address address = Address.fromJson(jsonDecode(savedAddress));
      setState(() {
        _con.addresses.insert(0, address);
      });
    }
  }

  void onNewAddressAdded(Address newAddress) {
    saveAddress(newAddress);

    setState(() {
      _con.addresses.insert(0, newAddress);
    });
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
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
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
                  leading:
                  Icon(Icons.map, color: Theme.of(context).hintColor),
                  title: Text(
                    S.of(context).delivery_addresses,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  subtitle: Text(
                    S
                        .of(context)
                        .long_press_to_edit_item_swipe_item_to_delete_it,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryAddressFormPage(
                        address: Address(),
                        onChanged: (address) {
                          _con.addAddress(address);
                          saveAddress(address);
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Theme.of(context).focusColor.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10),
                      Text(
                        S.of(context).add_new_delivery_address,
                        style: Theme.of(context).textTheme.titleMedium?.merge(
                          TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _con.addresses.isEmpty
                  ? CircularLoadingWidget(height: 250)
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 15),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: _con.addresses.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  Address address = _con.addresses.elementAt(index);
                  return DeliveryAddressesItemWidget(
                    address: address,
                    isSelected: widget.shouldChooseDeliveryHere &&
                        _con.selectedAddress == address,
                    onPressed: (Address _address) {
                      if (widget.shouldChooseDeliveryHere) {
                        setState(() {
                          _con.selectedAddress = _address;
                        });
                      } else {
                        Navigator.of(context).pushNamed(
                            '/DeliveryAddressForm',
                            arguments: {
                              'address': _address,
                              'onChanged': (Address updated) {
                                _con.updateAddress(updated);
                              },
                            });
                      }
                    },
                    onLongPress: (Address _address) {
                      Navigator.of(context).pushNamed(
                          '/DeliveryAddressForm',
                          arguments: {
                            'address': _address,
                            'onChanged': (Address updated) {
                              _con.updateAddress(updated);
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
      bottomNavigationBar:
      widget.shouldChooseDeliveryHere && _con.selectedAddress != null
          ? BottomAppBar(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 80.0, vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                widget.conDeliverPickupController.userDeliverAddress = _con.selectedAddress!.address.toString();
              });
              Navigator.of(context).pushReplacementNamed(
                '/DeliveryPickup',
                arguments: RouteArgument(param: _con.selectedAddress),
              );

            },

            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
              Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: Text(
              S.of(context).select,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}
