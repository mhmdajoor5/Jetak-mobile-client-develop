import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/address.dart';
import '../models/address.dart' as model;
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class DeliveryAddressesController extends ControllerMVC with ChangeNotifier {
  List<model.Address> addresses = <model.Address>[];
  late GlobalKey<ScaffoldState> scaffoldKey;
  Cart? cart;
  //List<model.Address> addresses = [];
  Address? selectedAddress;

  DeliveryAddressesController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForAddresses();
    listenForCart();
  }

  void listenForAddresses({String? message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        addresses.add(_address);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () async {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      await loadSavedAddress();
    });
  }

  Future<void> loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('saved_address');

    if (savedAddress != null) {
      Address address = Address.fromJson(jsonDecode(savedAddress));

      final existing = addresses.firstWhere(
            (a) => a.id == address.id,
        orElse: () => address,
      );

      setState(() {
        selectedAddress = existing;
        settingRepo.deliveryAddress.value = existing;
      });

      print('✅ عنوان محفوظ تم تحميله: ${existing.description}');
    } else {
      print('❌ لا يوجد عنوان محفوظ');
    }
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cart = _cart;
    });
  }

  Future<void> refreshAddresses() async {
    addresses.clear();
    listenForAddresses(
        message: S.of(state!.context).addresses_refreshed_successfuly);
  }

  Future<void> changeDeliveryAddress(model.Address address) async {
    await settingRepo.changeCurrentLocation(address);
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    model.Address _address = await settingRepo.setCurrentLocation();
    setState(() {
      settingRepo.deliveryAddress.value = _address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  Future<bool> _handleLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.denied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
            "Location permission is required to find the closest address."),
      ));
    } else if (status == PermissionStatus.permanentlyDenied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
            "Location permission is permanently denied. Please enable it in your device settings."),
      ));
      openAppSettings(); // Redirect user to app settings
    }
    return false;
  }

  Future<void> addAddress(model.Address address) async {
    if (!await _handleLocationPermission()) {
      return;
    }
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    address.longitude = currentPosition.longitude;
    address.latitude = currentPosition.latitude;

    userRepo.addAddress(address).then((value) {
      setState(() {
        this.addresses.insert(0, value);
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).new_address_added_successfully),
      ));
    });
  }

  Future<void> saveAddress(Address address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_address', jsonEncode(address.toJson()));
  }

  Future<void> saveSelectedAddress(Address address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_address', jsonEncode(address.toJson()));
  }

  void chooseDeliveryAddress(model.Address address) {
    setState(() {
      settingRepo.deliveryAddress.value = address;
      selectedAddress = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
    saveSelectedAddress(address);
    saveAddress(address);
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {});
      addresses.clear();
      listenForAddresses(
          message: S.of(state!.context).the_address_updated_successfully);
    });
  }

  void removeDeliveryAddress(model.Address address) async {
    userRepo.removeDeliveryAddress(address).then((value) {
      setState(() {
        this.addresses.remove(address);
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content:
            Text(S.of(state!.context).delivery_address_removed_successfully),
      ));
    });
  }
  Future<void> loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String? addressJson = prefs.getString('selected_address');

    if (addressJson != null) {
      Address address = Address.fromJson(jsonDecode(addressJson));

      final existing = addresses.firstWhere(
            (a) => a.id == address.id,
        orElse: () => address,
      );

      setState(() {
        selectedAddress = existing;
        settingRepo.deliveryAddress.value = existing;
      });
    }
  }
}

