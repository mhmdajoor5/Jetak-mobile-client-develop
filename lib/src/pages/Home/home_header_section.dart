import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import '../../../generated/l10n.dart';
import '../../elements/NotificationsButtonWidget.dart';
import '../../elements/ShoppingCartButtonWidget.dart';
import '../../helpers/helper.dart';

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
                  S.of(context).your_location,
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
                          (currentLocationName != null && currentLocationName!.trim().isNotEmpty)
                              ? currentLocationName!
                              : S.of(context).choose_your_location,

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
                NotificationsButtonWidget(), // Remove static count
                SizedBox(width: 7),
                ShoppingCartButtonWidget(
                  iconColor: Color(0xFF292D32),
                  labelColor: Colors.red,
                ),
                // زر المساعدة - Intercom (مخفي)
                // SizedBox(width: 7),
                // Container(
                //   width: 40,
                //   height: 40,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.1),
                //         blurRadius: 4,
                //         offset: Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.help_outline,
                //       color: Color(0xFF292D32),
                //       size: 20,
                //     ),
                //     onPressed: () async {
                //       await Helper.openIntercomMessenger(context);
                //     },
                //     padding: EdgeInsets.zero,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}