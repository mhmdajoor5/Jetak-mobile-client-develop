import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../generated/l10n.dart';
import '../../controllers/delivery_pickup_controller.dart';
import '../../models/address.dart';
import '../../repository/user_repository.dart' as userRepo;
import '../../repository/user_repository.dart' as controller;
import '../checkout.dart';
import '../delivery_addresses.dart';
import '../delivery_pickup.dart';

class AddressDetailsPage extends StatefulWidget {
  final String address;
  final double? latitude;
  final double? longitude;

  const AddressDetailsPage({
    Key? key, 
    required this.address,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<AddressDetailsPage> createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  String selectedType = '';
  final buildingNameController = TextEditingController();
  final entranceController = TextEditingController();
  final floorController = TextEditingController();
  final unitController = TextEditingController();
  final instructionsController = TextEditingController();

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

  // تم إزالة الدالة المخصصة addAddress لأننا نستخدم userRepo.addAddress


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
                S.of(context).location_type_hint,
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
                  children: ['Apartment','House','Office','Other'].map((type) {
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

                    final isOpen = dropdownVisibility[type] ?? false;

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
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(iconData, color: Colors.blueGrey),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            isOpen ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
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
                            padding: EdgeInsets.all(16),
                            color: Colors.grey.shade50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _toggleAddressDetails,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(S.of(context).addressDetails, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 6),
                                            Text(
                                              S.of(context).addingExactAddressDetailsHelpsUsFindYouFaster,
                                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        isAddressDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                if (isAddressDetailsExpanded) ...[

                                  // Building name
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: TextField(
                                      controller: buildingNameController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Building name',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  Text(S.of(context).optional, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: TextField(
                                      controller: entranceController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Entrance / Staircase',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  Text(S.of(context).optional, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(right: 8),
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade400),
                                          ),
                                          child: TextField(
                                            controller: floorController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Floor',
                                              hintStyle: TextStyle(color: Colors.grey[500]),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade400),
                                          ),
                                          child: TextField(
                                            controller: unitController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: type == 'Apartment' ? 'Apartment' : type == 'Office' ? 'Office' : 'Unit',
                                              hintStyle: TextStyle(color: Colors.grey[500]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 30),
                                  Text(
                                    S.of(context).howDoWeGetIn,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 12),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.grey,
                                      radioTheme: RadioThemeData(
                                        fillColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        RadioListTile<String>(
                                          title: Transform.translate(
                                            offset: Offset(-10, 0),
                                            child: Text(
                                              S.of(context).doorbellIntercom,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          value: 'doorbell',
                                          groupValue: selectedEntryMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedEntryMethod = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: Transform.translate(
                                            offset: Offset(-10, 0),
                                            child: Text(
                                              S.of(context).doorCode,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          value: 'code',
                                          groupValue: selectedEntryMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedEntryMethod = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: Transform.translate(
                                            offset: Offset(-10, 0),
                                            child: Text(
                                              S.of(context).doorIsOpen,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          value: 'open',
                                          groupValue: selectedEntryMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedEntryMethod = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: Transform.translate(
                                            offset: Offset(-10, 0),
                                            child: Text(
                                              S.of(context).otherTellUsHow,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          value: 'other',
                                          groupValue: selectedEntryMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedEntryMethod = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: TextField(
                                      controller: instructionsController,
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: selectedEntryMethod == 'code'
                                            ? S.of(context).enterTheDoorCode
                                            : S.of(context).otherInstructionsForCourier,
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(S.of(context).optional, style: TextStyle(fontSize: 14, color: Colors.grey[700])),

                                  SizedBox(height: 30),
                                  // Text(
                                  //   "Where's the entrance?",
                                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  // SizedBox(height: 12),
                                  // Container(
                                  //   height: 160,
                                  //   width: double.infinity,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.grey.shade300,
                                  //     borderRadius: BorderRadius.circular(12),
                                  //   ),
                                  //   child: Center(
                                  //     child: Icon(Icons.map, size: 40, color: Colors.grey[600]),
                                  //   ),
                                  // ),

                                  SizedBox(height: 30),
                                  Text(S.of(context).addressTypeAndLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  Text(
                                    S.of(context).addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildLabelBox(icon: Icons.home, label:S.of(context).home),
                                      _buildLabelBox(icon: Icons.work, label: S.of(context).work),
                                      _buildLabelBox(icon: Icons.location_on, label: S.of(context).other),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                      onPressed: () async {
                        // إرسال العنوان الأساسي فقط بدون المعلومات الإضافية
                        String fullAddress = widget.address;

                        // الحصول على الإحداثيات من العنوان المحدد
                        double? latitude = widget.latitude;
                        double? longitude = widget.longitude;

                        print('📍 الإحداثيات المستلمة من الصفحة السابقة: lat=$latitude, lng=$longitude');

                        // إذا لم تكن الإحداثيات متوفرة، احصل على الموقع الحالي
                        if (latitude == null || longitude == null) {
                          print('⚠️ الإحداثيات غير متوفرة، جاري الحصول على الموقع الحالي...');
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
                                print('📍 تم الحصول على الإحداثيات الحالية: lat=$latitude, lng=$longitude');
                                print('📍 دقة الموقع: ${position.accuracy} متر');
                              } else {
                                print('❌ لم يتم منح صلاحيات الموقع');
                              }
                            } else {
                              print('❌ خدمة الموقع معطلة');
                            }
                          } catch (e) {
                            print('❌ خطأ في الحصول على الإحداثيات: $e');
                          }
                        }

                        // تجميع المعلومات الإضافية في حقل instructions
                        List<String> additionalInfo = [];
                        if (buildingNameController.text.isNotEmpty) {
                          additionalInfo.add("Building: ${buildingNameController.text}");
                        }
                        if (entranceController.text.isNotEmpty) {
                          additionalInfo.add("Entrance: ${entranceController.text}");
                        }
                        if (floorController.text.isNotEmpty) {
                          additionalInfo.add("Floor: ${floorController.text}");
                        }
                        if (unitController.text.isNotEmpty) {
                          additionalInfo.add("Unit: ${unitController.text}");
                        }
                        if (instructionsController.text.isNotEmpty) {
                          additionalInfo.add("Additional: ${instructionsController.text}");
                        }
                        
                        final address = Address(
                          address: fullAddress,
                          description: buildingNameController.text.isNotEmpty 
                              ? buildingNameController.text 
                              : 'No building name provided',
                          latitude: latitude,
                          longitude: longitude,
                          isDefault: false,
                          type: selectedType,
                          entryMethod: selectedEntryMethod,
                          instructions: additionalInfo.isNotEmpty ? additionalInfo.join(", ") : '',
                          label: selectedLabel,
                          userId: '0',
                        );

                        // طباعة بيانات العنوان قبل الإرسال
                        print('📍 بيانات العنوان في AddressDetailsPage:');
                        print('- address (الأساسي): ${address.address}');
                        print('- latitude: ${address.latitude}');
                        print('- longitude: ${address.longitude}');
                        print('- description (Building): ${address.description}');
                        print('- type (Entrance): ${address.type}');
                        print('- entryMethod (Floor): ${address.entryMethod}');
                        print('- instructions (مجمعة): ${address.instructions}');
                        print('- label: ${address.label}');
                        print('📍 المعلومات الإضافية المجمعة:');
                        if (additionalInfo.isNotEmpty) {
                          additionalInfo.forEach((info) => print('   - $info'));
                        }

                        try {
                          print("🚀 بدء إرسال العنوان إلى API...");
                          final addedAddress = await userRepo.addAddress(address);
                          print("✅ العنوان أُضيف بنجاح");
                          print("✅ العنوان المُضاف يحتوي على الإحداثيات: lat=${addedAddress.latitude}, lng=${addedAddress.longitude}");
                          print("✅ العنوان المُضاف يحتوي على الوصف: ${addedAddress.description}");
                          print("✅ العنوان المُضاف يحتوي على النوع: ${addedAddress.type}");

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => DeliveryAddressesWidget(
                                shouldChooseDeliveryHere: true,
                                conDeliverPickupController: DeliveryPickupController(),
                                newAddress: addedAddress,
                              ),
                            ),
                          );
                        } catch (e) {
                          print('❌❌❌ ليش ما بيرضى يضيف عنوان - التفاصيل الكاملة:');
                          print('❌ نوع الخطأ: ${e.runtimeType}');
                          print('❌ رسالة الخطأ: $e');
                          print('❌ بيانات العنوان المرسل:');
                          print('   - العنوان: ${address.address}');
                          print('   - latitude: ${address.latitude}');
                          print('   - longitude: ${address.longitude}');
                          print('   - الوصف: ${address.description}');
                          print('   - النوع: ${address.type}');
                          print('   - طريقة الدخول: ${address.entryMethod}');
                          print('   - التعليمات: ${address.instructions}');
                          print('   - التسمية: ${address.label}');
                          print('❌ Stack trace:');
                          print(StackTrace.current);
                          print('❌❌❌ انتهت تفاصيل الخطأ');
                          
                          // لا نظهر رسالة للمستخدم، فقط نطبع التفاصيل للتشخيص
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                label,
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