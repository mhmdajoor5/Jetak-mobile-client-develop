import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../helpers/address_helper.dart';
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
      
      // التحقق من وجود الإحداثيات باستخدام AddressHelper
      if (!AddressHelper.isAddressValid(address)) {
        print('⚠️ العنوان المحفوظ لا يحتوي على إحداثيات صحيحة، محاولة إصلاح...');
        
        // محاولة إصلاح العنوان
        Address? fixedAddress = await AddressHelper.fixAddressCoordinates(address);
        if (fixedAddress != null) {
          address = fixedAddress;
          // حفظ العنوان المحدث
          await saveAddress(address);
          print('✅ تم إصلاح العنوان المحفوظ بالإحداثيات الجديدة');
        } else {
          print('❌ فشل في إصلاح العنوان المحفوظ');
          // حذف العنوان المعطوب
          await prefs.remove('saved_address');
          return;
        }
      }

      final existing = addresses.firstWhere(
            (a) => a.id == address.id,
        orElse: () => address,
      );

      setState(() {
        selectedAddress = existing;
        settingRepo.deliveryAddress.value = existing;
      });

      AddressHelper.printAddressInfo(existing, 'العنوان المحفوظ المحمل');
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
    // التحقق من وجود الإحداثيات باستخدام AddressHelper
    if (!AddressHelper.isAddressValid(address)) {
      print('⚠️ تحذير: محاولة تغيير عنوان بدون إحداثيات');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('العنوان المحدد لا يحتوي على إحداثيات صحيحة'),
      ));
      return;
    }

    await settingRepo.changeCurrentLocation(address);
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
    
    AddressHelper.printAddressInfo(address, 'العنوان المحدث');
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    try {
      model.Address _address = await settingRepo.setCurrentLocation();
      
      // التحقق من وجود الإحداثيات
      if (_address.latitude == null || _address.longitude == null) {
        print('⚠️ فشل في الحصول على إحداثيات الموقع الحالي');
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('فشل في تحديد الموقع الحالي'),
        ));
        return;
      }
      
      setState(() {
        settingRepo.deliveryAddress.value = _address;
      });
      settingRepo.deliveryAddress.notifyListeners();
      
      print('✅ تم تغيير العنوان إلى الموقع الحالي: ${_address.address} (lat: ${_address.latitude}, lng: ${_address.longitude})');
    } catch (e) {
      print('❌ خطأ في تغيير العنوان إلى الموقع الحالي: $e');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('فشل في تحديد الموقع الحالي'),
      ));
    }
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
    
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      address.longitude = currentPosition.longitude;
      address.latitude = currentPosition.latitude;

      print('📍 تم الحصول على الإحداثيات: lat=${address.latitude}, lng=${address.longitude}');

      userRepo.addAddress(address).then((value) {
        setState(() {
          this.addresses.insert(0, value);
        });
        
        // حفظ العنوان مع الإحداثيات
        saveAddress(value);
        
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(S.of(state!.context).new_address_added_successfully),
        ));
      });
    } catch (e) {
      print('❌ خطأ في الحصول على الموقع: $e');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('فشل في تحديد الموقع. يرجى المحاولة مرة أخرى.'),
      ));
    }
  }

  Future<void> saveAddress(Address address) async {
    // التحقق من وجود الإحداثيات باستخدام AddressHelper
    if (!AddressHelper.isAddressValid(address)) {
      print('⚠️ تحذير: محاولة حفظ عنوان بدون إحداثيات');
      return;
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_address', jsonEncode(address.toJson()));
    AddressHelper.printAddressInfo(address, 'العنوان المحفوظ');
  }

  Future<void> saveSelectedAddress(Address address) async {
    // التحقق من وجود الإحداثيات باستخدام AddressHelper
    if (!AddressHelper.isAddressValid(address)) {
      print('⚠️ تحذير: محاولة حفظ عنوان محدد بدون إحداثيات');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_address', jsonEncode(address.toJson()));
    AddressHelper.printAddressInfo(address, 'العنوان المحدد المحفوظ');
  }

  void chooseDeliveryAddress(model.Address address) {
    // التحقق من وجود الإحداثيات باستخدام AddressHelper
    if (!AddressHelper.isAddressValid(address)) {
      print('⚠️ تحذير: محاولة اختيار عنوان بدون إحداثيات');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('العنوان المحدد لا يحتوي على إحداثيات صحيحة'),
      ));
      return;
    }

    setState(() {
      settingRepo.deliveryAddress.value = address;
      selectedAddress = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
    
    AddressHelper.printAddressInfo(address, 'العنوان المختار');
    
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
      
      // التحقق من وجود الإحداثيات باستخدام AddressHelper
      if (!AddressHelper.isAddressValid(address)) {
        print('⚠️ العنوان المحفوظ لا يحتوي على إحداثيات صحيحة');
        // حذف العنوان المعطوب
        await prefs.remove('selected_address');
        return;
      }

      final existing = addresses.firstWhere(
            (a) => a.id == address.id,
        orElse: () => address,
      );

      setState(() {
        selectedAddress = existing;
        settingRepo.deliveryAddress.value = existing;
      });
      
      AddressHelper.printAddressInfo(existing, 'العنوان المحدد المحمل');
    }
  }
}

