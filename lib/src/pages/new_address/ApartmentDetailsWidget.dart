import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class ApartmentDetailsWidget extends StatefulWidget {
  const ApartmentDetailsWidget({Key? key}) : super(key: key);

  @override
  State<ApartmentDetailsWidget> createState() => _ApartmentDetailsWidgetState();
}

class _ApartmentDetailsWidgetState extends State<ApartmentDetailsWidget> {
  final borderColor = Colors.grey.shade400;
  String? selectedEntryMethod;
  String? selectedLabel;

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
              color: isSelected ? Colors.blue : Colors.grey.shade400,
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

  Widget buildInputBox(String hint) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).addressDetails,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            S.of(context).addingExactAddressDetailsHelpsUsFindYouFaster,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),

          // building name
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).buildingName,
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
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).entranceStaircase,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          SizedBox(height: 20),

          Text(S.of(context).optional, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          SizedBox(height: 8),
          Row(
            children: [
              buildInputBox(S.of(context).floor),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: S.of(context).apartment,
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          Text(S.of(context).howDoWeGetIn, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.grey,
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.all(Colors.blue),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              ),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Transform.translate(
                    offset: Offset(-10, 0),
                    child: Text(S.of(context).doorbellIntercom),
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
                    child: Text(S.of(context).doorCode),
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
                    child: Text(S.of(context).doorIsOpen),
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
                    child: Text(S.of(context).otherTellUsHow),
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
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).otherInstructionsForTheCourier,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(S.of(context).optional, style: TextStyle(fontSize: 14, color: Colors.grey[700])),

          SizedBox(height: 30),
          Text(S.of(context).addressTypeAndLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(
            S.of(context).addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabelBox(icon: Icons.home, label: S.of(context).home),
              _buildLabelBox(icon: Icons.work, label: S.of(context).work),
              _buildLabelBox(icon: Icons.location_on, label: S.of(context).other),
            ],
          ),
        ],
      ),
    );
  }
}
