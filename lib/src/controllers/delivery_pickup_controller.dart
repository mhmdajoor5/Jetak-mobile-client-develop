import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../models/address.dart';
import '../models/icredit_create_sale_body.dart';
import '../models/icredit_create_sale_response.dart';
import '../pages/delivery_pickup.dart';
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
        ScaffoldMessenger.of(
          scaffoldKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text("Error fetching addresses")));
      },
    );
  }

  Future<bool> checkDeliveryArea() async {
    try {
      // التحقق من وجود العنوان والإحداثيات
      if (deliveryAddress == null) {
        print('❌ لا يوجد عنوان توصيل محدد');
        return false;
      }

      if (deliveryAddress?.latitude == null || deliveryAddress?.longitude == null) {
        print('❌ العنوان لا يحتوي على إحداثيات صحيحة: lat=${deliveryAddress?.latitude}, lng=${deliveryAddress?.longitude}');
        return false;
      }

      if (carts.isEmpty || carts.first.food?.restaurant.id == null) {
        print('❌ لا يوجد طعام أو مطعم محدد');
        return false;
      }

      print(
        '📍 التحقق من نطاق التوصيل: المطعم ${carts.first.food?.restaurant.id}, الإحداثيات (${deliveryAddress?.latitude}, ${deliveryAddress?.longitude})',
      );
      
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/check-delivery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'restaurant_id': carts.first.food?.restaurant.id,
          'latitude': deliveryAddress?.latitude,
          'longitude': deliveryAddress?.longitude,
        }),
      );
      
      print(
        '📡 استجابة التحقق من نطاق التوصيل: status=${response.statusCode}, body=${response.body}',
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ بيانات التحقق من نطاق التوصيل: $data');
        
        bool isDelivery = data['is_delivery'] == true || data['can_deliver'] == true;
        print('✅ هل يسمح بالتوصيل؟ $isDelivery');
        
        return isDelivery;
      }
      
      print('❌ خطأ في استجابة التحقق من نطاق التوصيل: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ خطأ في التحقق من نطاق التوصيل: $e');
      return false;
    }
  }

  void listenForDeliveryAddress() {
    deliveryAddress = settingRepo.deliveryAddress.value;
    print('📍 العنوان المحمل: ${deliveryAddress?.description}');
    print('📍 إحداثيات العنوان: lat=${deliveryAddress?.latitude}, lng=${deliveryAddress?.longitude}');
    
    // التحقق من وجود الإحداثيات
    if (deliveryAddress != null && (deliveryAddress?.latitude == null || deliveryAddress?.longitude == null)) {
      print('⚠️ تحذير: العنوان المحمل لا يحتوي على إحداثيات صحيحة');
    }
  }

  Future<void> _setClosestAddressAsDefault() async {
    try {
      if (!await _handleLocationPermission()) return;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 الموقع الحالي: lat=${position.latitude}, lng=${position.longitude}');

      // تصفية العناوين التي تحتوي على إحداثيات صحيحة
      final validAddresses = addresses.where((address) => 
        address.latitude != null && address.longitude != null
      ).toList();

      if (validAddresses.isEmpty) {
        print('⚠️ لا توجد عناوين صحيحة مع إحداثيات');
        return;
      }

      validAddresses.sort((a, b) {
        final double distA = Helper.calculateDistance(
          position.latitude,
          position.longitude,
          a.latitude!,
          a.longitude!,
        );
        final double distB = Helper.calculateDistance(
          position.latitude,
          position.longitude,
          b.latitude!,
          b.longitude!,
        );
        return distA.compareTo(distB);
      });

      if (validAddresses.isNotEmpty) {
        final closestAddress = validAddresses.first;
        print('📍 أقرب عنوان: ${closestAddress.description} (مسافة: ${Helper.calculateDistance(position.latitude, position.longitude, closestAddress.latitude!, closestAddress.longitude!).toStringAsFixed(2)} كم)');
        
        setState(() {
          deliveryAddress = closestAddress;
          settingRepo.deliveryAddress.value = closestAddress;
        });
        
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text("تم تعيين أقرب عنوان كافتراضي")),
        );
      }
    } catch (e) {
      if (addresses.isNotEmpty) {
        // البحث عن عنوان يحتوي على إحداثيات صحيحة
        final validAddress = addresses.firstWhere(
          (address) => address.latitude != null && address.longitude != null,
          orElse: () => addresses.first,
        );
        
        settingRepo.deliveryAddress.value = validAddress;
        deliveryAddress = validAddress;
        notifyListeners();
      }
      print("❌ خطأ في تحديد أقرب عنوان: $e");
      if (scaffoldKey.currentContext != null)
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text("خطأ في تحديد أقرب عنوان")),
        );
    }
  }

  Future<bool> _handleLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();

    if (status.isGranted) return true;

    if (status.isDenied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            "Location permission is required to find the closest address.",
          ),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            "Location permission is permanently denied. Please enable it in your device settings.",
          ),
        ),
      );
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
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                S.of(state!.context).new_address_added_successfully,
              ),
            ),
          );
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
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                S.of(state!.context).the_address_updated_successfully,
              ),
            ),
          );
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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: MobileVerificationBottomSheetWidget(
                scaffoldKey: scaffoldKey,
                user: currentUser.value,
                valueChangedCallback: (verified) async {
                  if (verified) {
                    Navigator.pop(context);
                    await _createSale(
                      context,
                    ); // ✅ انتقل للصفحة التالية بعد التحقق
                  }
                },
              ),
            ),
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
      );

      if (!currentUser.value.verifiedPhone) return;
    }
    // if (selectedTap == 1) {
    //
    //   if (deliveryAddress == null ||
    //       deliveryAddress?.address == null ||
    //       deliveryAddress!.address!.isEmpty ||
    //       deliveryAddress?.latitude == null ||
    //       deliveryAddress?.longitude == null) {
    //     ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
    //       SnackBar(content: Text("يرجى اختيار عنوان توصيل")),
    //     );
    //     return;
    //   }
    //
    //   final canDeliver = await checkDeliveryArea();
    //   if (!canDeliver) {
    //     ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
    //       SnackBar(content: Text("هذا العنوان خارج نطاق التوصيل.")),
    //     );
    //     return;
    //   }
    // }

    await _createSale(context);
  }

  Future<void> _createSale(BuildContext context) async {
    setState(() => isLoading = true);

    final List<Item> items = fromList(carts)..add(
      Item(
        quantity: 1,
        unitPrice: carts.first.food?.restaurant.deliveryFee ?? 0,
        description: 'Delivery Fee',
      ),
    );

    String orderType = selectedTap == 1 ? 'delivery' : 'pickup';

    final ICreditCreateSaleResponse response = await iCreditCreateSale(items, orderType);

    setState(() => isLoading = false);

    Navigator.of(context).pushNamed(getSelectedMethod().route, arguments: response);
  }


}
