import 'package:flutter/material.dart';

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

  void _toggleDropdown(String type) {
    setState(() {
      dropdownVisibility.updateAll((key, value) => false);
      dropdownVisibility[type] = true;
      selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxColor = Colors.grey.shade200;
    final borderColor = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(widget.address, style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 30),

              Text('Location Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'The location type helps us to find your better',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                              border: isLast
                                  ? null
                                  : Border(
                                bottom: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(iconData, color: Colors.blueGrey),
                                    SizedBox(width: 12),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        isOpen ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isOpen)
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            color: Colors.grey.shade50,
                            child: Text(
                              'Details about "$type" go here...', 
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
