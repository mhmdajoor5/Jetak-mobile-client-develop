import 'package:flutter/material.dart';

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
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
          Text('Address details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(
            'Adding exact address details helps us find you faster',
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
                hintText: 'Building name',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('Optional', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
                hintText: 'Entrance / Staircase',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          SizedBox(height: 20),

          Text('Optional', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          SizedBox(height: 8),
          Row(
            children: [
              buildInputBox('Floor'),
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
                      hintText: 'Apartment',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          Text('How do we get in?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: Text('Doorbell / Intercom'),
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
                    child: Text('Door code'),
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
                    child: Text('Door is open'),
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
                    child: Text('Other (tell us how)'),
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
                hintText: 'Other instructions for the courier',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text('Optional', style: TextStyle(fontSize: 14, color: Colors.grey[700])),

          SizedBox(height: 30),
          Text("Where's the entrance?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.map, size: 40, color: Colors.grey[600]),
            ),
          ),

          SizedBox(height: 30),
          Text('Address type and label', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(
            'Add or create address labels to easily choose between delivery addresses.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabelBox(icon: Icons.home, label: 'Home'),
              _buildLabelBox(icon: Icons.work, label: 'Work'),
              _buildLabelBox(icon: Icons.location_on, label: 'Other'),
            ],
          ),
        ],
      ),
    );
  }
}
