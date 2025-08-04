import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../generated/l10n.dart';
import '../../models/address.dart';
import '../../repository/user_repository.dart' as deliveryAddressesController;
import 'AddressDetailsPage.dart';

class DeliveryAddressFormPage extends StatefulWidget {
  final Address address;
  final void Function(Address) onChanged;

  const DeliveryAddressFormPage({
    Key? key,
    required this.address,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DeliveryAddressFormPageState createState() => _DeliveryAddressFormPageState();
}

class _DeliveryAddressFormPageState extends State<DeliveryAddressFormPage> {
  late Address _address;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fullAddressController = TextEditingController();

  bool isDefault = false;
  bool showOverlay = true;

  String currentAddress = 'جاري تحديد موقعك...';
  bool locationLoaded = false;

  // دالة التحقق من صحة الوصف
  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).description_required;
    }
    if (value.trim().length < 3) {
      return S.of(context).description_min_length;
    }
    if (value.trim().length > 50) {
      return S.of(context).description_max_length;
    }
    return null;
  }

  // دالة التحقق من صحة العنوان
  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).address_required;
    }
    // تم إزالة الفالديشن عن عدد الحروف
    return null;
  }

  @override
  void initState() {
    super.initState();
    _address = widget.address;
    descriptionController.text = _address.description ?? '';
    fullAddressController.text = _address.address ?? '';
    isDefault = _address.isDefault ?? false;

    _fetchCurrentLocation();
    
    // Timer احتياطي لإخفاء رسالة التحميل بعد 15 ثانية
    Timer(Duration(seconds: 15), () {
      if (!locationLoaded) {
        setState(() {
          currentAddress = 'لم يتم تحديد الموقع. يمكنك كتابة العنوان يدوياً.';
          locationLoaded = true;
          showOverlay = true;
        });
      }
    });
  }

  // دالة للحصول على اسم المكان من الإحداثيات
  Future<String?> getLocationNameFromCoordinates(double lat, double lng) async {
    try {
      String languageCode = window.locale.languageCode;
      
      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'latlng': '$lat,$lng',
          'language': languageCode,
          'key': 'AIzaSyDa5865xd383IlBX694cl6zPeCtzXQ6XPs', // نفس المفتاح من home_controller
        },
      );

      print('📡 جاري الحصول على اسم المكان من: $url');

      final response = await http.get(url).timeout(Duration(seconds: 8));

      print('📥 استجابة الخادم: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].length > 0) {
          String fullAddress = data['results'][0]['formatted_address'];
          print('✅ تم الحصول على اسم المكان: $fullAddress');
          return fullAddress;
        }
      }
    } catch (e) {
      print('❌ خطأ في الحصول على اسم المكان: $e');
    }
    return null;
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          currentAddress = 'خدمة الموقع معطلة';
          locationLoaded = true;
          showOverlay = true;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          setState(() {
            currentAddress = 'تم رفض صلاحيات الموقع نهائياً';
            locationLoaded = true;
            showOverlay = true;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      print('📍 تم الحصول على الإحداثيات: lat=${position.latitude}, lng=${position.longitude}');
      
      // تحديث بيانات الموقع في العنوان
      _address.latitude = position.latitude;
      _address.longitude = position.longitude;
      
      // عرض مؤشر أثناء جلب اسم المكان
      setState(() {
        currentAddress = 'جاري تحديد اسم المكان...';
        locationLoaded = true;
        showOverlay = true;
      });
      
      // محاولة الحصول على اسم المكان من Google Maps
      String? locationName = await getLocationNameFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        if (locationName != null && locationName.isNotEmpty) {
          currentAddress = locationName;
          print('✅ تم عرض اسم المكان: $currentAddress');
        } else {
          currentAddress = 'الموقع الحالي (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
          print('⚠️ فشل في الحصول على اسم المكان، عرض الإحداثيات');
        }
      });
    } catch (e) {
      print('Error fetching location: $e');
      String errorMessage = 'تعذر تحديد الموقع';
      
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة تحديد الموقع. تأكد من تشغيل GPS.';
      } else if (e.toString().contains('Location services are disabled')) {
        errorMessage = 'خدمة الموقع معطلة. يرجى تفعيلها من الإعدادات.';
      } else if (e.toString().contains('denied')) {
        errorMessage = 'تم رفض صلاحيات الموقع. يرجى تفعيلها من الإعدادات.';
      }
      
      setState(() {
        currentAddress = errorMessage;
        locationLoaded = true;
        showOverlay = true;
      });
    }
  }

  void _useCurrentAddress() {
    setState(() {
      fullAddressController.text = currentAddress;
      showOverlay = false;
    });
  }

  void _dismissOverlay() {
    setState(() {
      showOverlay = false;
    });
  }

  void _saveAddress() {
    _address.description = descriptionController.text;
    _address.address = fullAddressController.text;
    _address.isDefault = isDefault;

    deliveryAddressesController.addAddress(_address);

    widget.onChanged(_address);
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  void dispose() {
    descriptionController.dispose();
    fullAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Main Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).addNewAddress,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      label: Text(S.of(context).description),
                      hintText: 'Home Address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorMaxLines: 2,
                    ),
                    validator: _validateDescription,
                    onChanged: (value) {
                      // إعادة التحقق عند التغيير
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: fullAddressController,
                    decoration: InputDecoration(
                      label: Text(S.of(context).fullAddress),
                      hintText: 'Street, City, Country',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorMaxLines: 2,
                    ),
                    validator: _validateAddress,
                    onChanged: (value) {
                      // إعادة التحقق عند التغيير
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // التحقق من صحة النموذج
                      if (!_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                          content: Text(S.of(context).please_correct_form_errors),
                          backgroundColor: Colors.red,
                        ),
                        );
                        return;
                      }

                      _address.description = descriptionController.text.trim();
                      _address.address = fullAddressController.text.trim();
                      _address.isDefault = isDefault;

                      // الحصول على الإحداثيات قبل إرسال العنوان
                      double? latitude;
                      double? longitude;
                      
                      try {
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (serviceEnabled) {
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }
                          
                          if (permission == LocationPermission.whileInUse || 
                              permission == LocationPermission.always) {
                            Position position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );
                            latitude = position.latitude;
                            longitude = position.longitude;
                            print('📍 تم الحصول على الإحداثيات: lat=$latitude, lng=$longitude');
                            print('📍 دقة الموقع: ${position.accuracy} متر');
                          }
                        }
                      } catch (e) {
                        print('❌ خطأ في الحصول على الإحداثيات: $e');
                      }

                      // طباعة الإحداثيات قبل التمرير
                      print('📍 الإحداثيات المرسلة إلى AddressDetailsPage:');
                      print('- address: ${fullAddressController.text.trim()}');
                      print('- latitude: $latitude');
                      print('- longitude: $longitude');

                      // تمرير الإحداثيات مع العنوان
                      Navigator.of(context).pushNamed('/AddressDetails', arguments: {
                        'address': fullAddressController.text.trim(),
                        'latitude': latitude,
                        'longitude': longitude,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text(S.of(context).continueBtn, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        onChanged: (val) {
                          setState(() => isDefault = val ?? false);
                        },
                      ),
                      Text(S.of(context).makeItDefault),
                    ],
                  ),
                  Spacer(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     TextButton(
                  //       onPressed: _cancel,
                  //       child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16)),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: _saveAddress,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Theme.of(context).colorScheme.secondary,
                  //         minimumSize: Size(100, 45),
                  //       ),
                  //       child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ),

          if (showOverlay)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locationLoaded
                            ?S.of(context). locationBasedMessage
                            :S.of(context). pleaseWait,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(height: 12),
                      Text(
                        currentAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      if (locationLoaded)
                        ElevatedButton(
                          onPressed: _useCurrentAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            minimumSize: Size(double.infinity, 45),
                          ),
                          child: Text(S.of(context).useThisAddress, style: TextStyle(color: Colors.white)),
                        ),
                      if (locationLoaded)
                        TextButton(
                          onPressed: _dismissOverlay,
                          child: Text(S.of(context).enterAnotherAddress, style: TextStyle(color: Theme.of(context).hintColor)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}