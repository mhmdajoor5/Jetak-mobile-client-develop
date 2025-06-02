import 'package:flutter/material.dart';
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../models/icredit_create_sale_body.dart';
import '../models/icredit_create_sale_response.dart';
import '../repository/icredit_repository.dart';
import '../repository/user_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class DeliveryPickupController extends CartController {
  late GlobalKey<ScaffoldState> scaffoldKey;
  model.Address? deliveryAddress;
  PaymentMethodList? list;
  List<model.Address> addresses = [];

  String userDeliverAddress = '';

  DeliveryPickupController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.listenForCarts();
    listenForDeliveryAddress();
    listenForAddresses();
    print(settingRepo.deliveryAddress.value.toMap());
  }

  Future<void> listenForAddresses() async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen(
      (model.Address address) {
        setState(() => addresses.add(address));
      },
      onDone: () => _setClosestAddressAsDefault(),
      onError: (e) {
        print(e);
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text("Error fetching addresses")));
      },
    );
  }

  void listenForDeliveryAddress() {
    deliveryAddress = settingRepo.deliveryAddress.value;
    print(deliveryAddress?.id);
  }

  Future<void> _setClosestAddressAsDefault() async {
    try {
      if (!await _handleLocationPermission()) return;

      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      addresses.sort((a, b) {
        final double distA = Helper.calculateDistance(position.latitude, position.longitude, a.latitude ?? 0.0, a.longitude ?? 0.0);
        final double distB = Helper.calculateDistance(position.latitude, position.longitude, b.latitude ?? 0.0, b.longitude ?? 0.0);
        return distA.compareTo(distB);
      });

      if (addresses.isNotEmpty) {
        setState(() {
          deliveryAddress = addresses.first;
          settingRepo.deliveryAddress.value = addresses.first;
        });
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text("Closest address set as default")));
      }
    } catch (e) {
      if (addresses.isNotEmpty) {
        settingRepo.deliveryAddress.value = addresses.first;
        deliveryAddress = addresses.first;
        notifyListeners();
      }
      print("Error determining closest address: $e");
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text("Error determining closest address")));
    }
  }

  Future<bool> _handleLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();

    if (status.isGranted) return true;

    if (status.isDenied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text("Location permission is required to find the closest address.")));
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text("Location permission is permanently denied. Please enable it in your device settings.")));
      await openAppSettings();
    }
    return false;
  }

  void addAddress(model.Address address) {
    userRepo
        .addAddress(address)
        .then((value) {
          setState(() {
            settingRepo.deliveryAddress.value = value;
            deliveryAddress = value;
          });
        })
        .whenComplete(() {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).new_address_added_successfully)));
        });
  }

  void updateAddress(model.Address address) {
    userRepo
        .updateAddress(address)
        .then((value) {
          setState(() {
            settingRepo.deliveryAddress.value = value;
            deliveryAddress = value;
          });
        })
        .whenComplete(() {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).the_address_updated_successfully)));
        });
  }

  PaymentMethod getPickUpMethod() => list!.pickupList.first;

  PaymentMethod getDeliveryMethod() => list!.pickupList[1];

  void toggleDelivery() {
    for (var method in list!.pickupList) {
      if (method != getDeliveryMethod()) method.selected = false;
    }
    setState(() {
      getDeliveryMethod().selected = !getDeliveryMethod().selected;
    });
  }

  void togglePickUp() {
    for (var method in list!.pickupList) {
      if (method != getPickUpMethod()) method.selected = false;
    }
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected;
    });
  }

  PaymentMethod getSelectedMethod() {
    return list!.pickupList.firstWhere((element) => element.selected);
  }

  @override
  void goCheckout(BuildContext context) async {
    if (!currentUser.value.verifiedPhone) {
      await showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder:
            (_) => AnimatedPadding(
              duration: Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: MobileVerificationBottomSheetWidget(
                scaffoldKey: scaffoldKey,
                user: currentUser.value,
                valueChangedCallback: (verified) async {
                  if (verified) {
                    Navigator.pop(context);
                    await _createSale(context); // ✅ انتقل للصفحة التالية بعد التحقق
                  }
                },
              ),
            ),
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      );

      if (!currentUser.value.verifiedPhone) return;
    }

    await _createSale(context);
  }

  Future<void> _createSale(BuildContext context) async {
    setState(() => isLoading = true);

    final List<Item> items = fromList(carts)..add(Item(quantity: 1, unitPrice: carts.first.food?.restaurant.deliveryFee ?? 0, description: 'Delivery Fee'));

    final ICreditCreateSaleResponse response = await iCreditCreateSale(items);

    setState(() => isLoading = false);

    Navigator.of(context).pushNamed(getSelectedMethod().route, arguments: response);
  }
}
