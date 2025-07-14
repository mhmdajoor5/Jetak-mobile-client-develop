import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/address.dart';
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

  @override
  void initState() {
    super.initState();
    _address = widget.address;
    descriptionController.text = _address.description ?? '';
    fullAddressController.text = _address.address ?? '';
    isDefault = _address.isDefault ?? false;

    _fetchCurrentLocation();
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

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;

      setState(() {
        currentAddress = '${place.street}, ${place.locality}, ${place.country}';
        locationLoaded = true;
        showOverlay = true;
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        currentAddress = 'تعذر تحديد الموقع';
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
                    "Add new address",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      label: Text('Description'),
                      hintText: 'Home Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: fullAddressController,
                    decoration: InputDecoration(
                      label: Text('Full Address'),
                      hintText: 'Street, City, Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (fullAddressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter or select an address')),
                        );
                        return;
                      }
                      Navigator.of(context).pushNamed('/AddressDetails', arguments: fullAddressController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                      Text("Make it default"),
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
                            ? "Based on your phone's location,\nit looks like you're here:"
                            : "يرجى الانتظار...",
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
                          child: Text("Use this address", style: TextStyle(color: Colors.white)),
                        ),
                      if (locationLoaded)
                        TextButton(
                          onPressed: _dismissOverlay,
                          child: Text("Enter another address", style: TextStyle(color: Theme.of(context).hintColor)),
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
