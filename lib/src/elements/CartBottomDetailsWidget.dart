import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../pages/order_success.dart';
import 'custom_material_button.dart' show CustomMaterialButton;

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key? key,
    required CartController con,
    required this.selectedTap,
  }) : _con = con,
       super(key: key);

  final CartController _con;
  final int selectedTap;

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.colorFAFAFA,
            border: Border.all(color: AppColors.colorF1F1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  S.of(context).order_summary,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF272727),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  S.of(context).include_tax,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9D9FA4),
                  ),
                ),
                SizedBox(height: 16),

                // Subtotal
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        S.of(context).subtotal,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                    ),
                    Helper.getPrice(
                      _con.subTotal,
                      context,
                      style: Theme.of(context).textTheme.titleMedium,
                      zeroPlaceholder: '0',
                    ),
                  ],
                ),
                SizedBox(height: 5),

                // Delivery Fee – يظهر فقط إذا كانت Delivery
                if (selectedTap == 1)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9D9FA4),
                          ),
                        ),
                      ),
                      Helper.getPrice(
                        _con.carts[0].food!.restaurant!.deliveryFee,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      ),
                    ],
                  ),

                // Tax
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${S.of(context).tax} (${_con.carts[0].food!.restaurant!.defaultTax}%)',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                    ),
                    Helper.getPrice(
                      _con.taxAmount,
                      context,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF272727),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: AppColors.colorF1F1F1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).total,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF272727),
                      ),
                    ),
                    _buildPriceWidget(context),
                  ],
                ),
                SizedBox(height: 10),

                // Checkout Button
                Stack(
                  fit: StackFit.loose,
                  alignment: AlignmentDirectional.centerEnd,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: CustomMaterialButton(
                        onPressed: _con.isLoading
                            ? null
                            : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderSuccessWidget(
                                routeArgument: RouteArgument(
                                  param: 'Cash on Delivery',
                                ),
                              ),
                            ),
                          );
                          print("mElkerm : Order Success");
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPriceWidget(context),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
  }

  Widget _buildPriceWidget(BuildContext context) {
    final restaurant = _con.carts[0].food!.restaurant!;
    final total = _con.total;
    final deliveryFee = restaurant.deliveryFee;

    final textStyle = Theme.of(context).textTheme.headlineLarge?.merge(
      TextStyle(color: Theme.of(context).primaryColor),
    );

    if (selectedTap == 2) {
      return Helper.getPrice(
        total - deliveryFee,
        context,
        style: textStyle,
        zeroPlaceholder: 'Free',
      );
    }

    return Helper.getPrice(
      total,
      context,
      style: textStyle,
      zeroPlaceholder: 'Free',
    );
  }
}
