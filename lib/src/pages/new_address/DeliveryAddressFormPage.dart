import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../generated/l10n.dart';
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

  String currentAddress = '';
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
          currentAddress = S.of(context).locationServiceDisabled;
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
            currentAddress = S.of(context).locationPermissionDeniedForever;
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
        currentAddress = S.of(context).locationFetchError;
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
                      hintText: S.of(context).homeAddress,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: fullAddressController,
                    decoration: InputDecoration(
                      label: Text(S.of(context).fullAddress),
                      hintText: S.of(context).streetCityCountry,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (fullAddressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context).pleaseEnterOrSelectAddress)),
                        );
                        return;
                      }
                      Navigator.of(context).pushNamed('/AddressDetails', arguments: fullAddressController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                            ? S.of(context).locationBasedMessage
                            : S.of(context).pleaseWait,
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
