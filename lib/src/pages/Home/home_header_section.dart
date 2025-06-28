import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../elements/NotificationsButtonWidget.dart';
import '../../elements/ShoppingCartButtonWidget.dart';

class HomeHeaderSection extends StatelessWidget {
  final String? currentLocationName;
  final VoidCallback onChangeLocation;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  const HomeHeaderSection({
    Key? key,
    required this.currentLocationName,
    required this.onChangeLocation,
    required this.parentScaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your location",
                  style: TextStyle(
                    //fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9D9FA4),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: onChangeLocation,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF1F2F56),
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          currentLocationName ??
                              S.of(context).choose_your_location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            //fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2F56),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF1F2F56),
                      ),
                      SizedBox(width: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Row(
              children: [
                NotificationsButtonWidget(notificationCount: 5),
                SizedBox(width: 15),
                ShoppingCartButtonWidget(
                  iconColor: Color(0xFF292D32),
                  labelColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}