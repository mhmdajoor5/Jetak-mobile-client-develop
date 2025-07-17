import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../controllers/delivery_pickup_controller.dart';
import '../../models/address.dart';
import '../checkout.dart';
import '../delivery_addresses.dart';
import '../delivery_pickup.dart';

class AddressDetailsPage extends StatefulWidget {
  final String address;

  const AddressDetailsPage({Key? key, required this.address}) : super(key: key);

  @override
  State<AddressDetailsPage> createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  String selectedType = '';
  Map<String, bool> dropdownVisibility = {
    'Apartment': false,
    'House': false,
    'Office': false,
    'Other': false,
  };

  String? selectedEntryMethod;
  String? selectedLabel;
  bool isAddressDetailsExpanded = false;

  void _toggleDropdown(String type) {
    setState(() {
      dropdownVisibility.updateAll((key, value) => false);
      dropdownVisibility[type] = true;
      selectedType = type;
    });
  }

  void _toggleAddressDetails() {
    setState(() {
      isAddressDetailsExpanded = !isAddressDetailsExpanded;
    });
  }

  String getLocationTypeLabel(BuildContext context, String type) {
    switch(type) {
      case 'home':
        return S.of(context).home;
      case 'work':
        return S.of(context).work;
      case 'other':
        return S.of(context).other;
      default:
        return S.of(context).other;
    }
  }

  String getAddressLabel(BuildContext context, String label) {
    switch(label) {
      case 'home':
        return S.of(context).home;
      case 'work':
        return S.of(context).work;
      case 'other':
        return S.of(context).other;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxColor = Colors.grey.shade200;
    final borderColor = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).address, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                widget.address,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              SizedBox(height: 30),

              Text(S.of(context).locationType, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                S.of(context).locationTypeHint,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: ['Apartment', 'House', 'Office', 'Other'].map((type) {
                    final isLast = type == 'Other';
                    IconData iconData;
                    switch (type) {
                      case 'Apartment':
                        iconData = Icons.apartment;
                        break;
                      case 'House':
                        iconData = Icons.house;
                        break;
                      case 'Office':
                        iconData = Icons.business;
                        break;
                      case 'Other':
                        iconData = Icons.more_horiz;
                        break;
                      default:
                        iconData = Icons.location_on;
                    }

                    final isOpen = dropdownVisibility[type]!;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleDropdown(type),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(iconData, color: Colors.blueGrey),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          getLocationTypeLabel(context, type),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isOpen ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOpen)
                                  Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen)
                          _buildDropdownContent(context, type),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DeliveryAddressesWidget(
                              shouldChooseDeliveryHere: true,
                              conDeliverPickupController: DeliveryPickupController(),
                              newAddress: Address(address: widget.address),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        minimumSize: Size(100, 45),
                      ),
                      child: Text(
                        S.of(context).save,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent(BuildContext context, String type) {
    // Return your TextFields and UI widgets here (for brevity, not duplicated)
    return Container();
  }

  Widget _buildLabelBox({required IconData icon, required String label}) {
    final isSelected = selectedLabel == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLabel = label;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blueGrey, size: 28),
              SizedBox(height: 8),
              Text(
                getAddressLabel(context, label),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
