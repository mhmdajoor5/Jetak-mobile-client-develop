import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';
import '../helpers/helper.dart';
import 'custom_material_button.dart' show CustomMaterialButton;

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key? key,
    required CartController con,
    this.deliveryPickupController,
  }) : _con = con,
       super(key: key);

  final CartController _con;
  final DeliveryPickupController? deliveryPickupController;

  @override
  Widget build(BuildContext context) {
    // print("mElkerm get price function !!!");
    // print(
    //   Helper.getPrice(
    //     0,
    //     context,
    //     style: Theme.of(context).textTheme.titleMedium,
    //     zeroPlaceholder: 'Free',
    //   ),
    // );
    // print("mElkerm : delvivery fees");
    // print(_con.carts[0].food!.restaurant!.deliveryFee);
    // print("mElkerm get price function ???");
    // print(
    //   Helper.getPrice(
    //     _con.carts[0].food!.restaurant!.deliveryFee,
    //     context,
    //     style: Theme.of(context).textTheme.titleMedium,
    //     zeroPlaceholder: 'Free',
    //   ),
    // );

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
                Text(S.of(context).include_tax,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9D9FA4),
                  ),
                ),
                SizedBox(height: 16),
                /// mElkerm : subTotal
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

                /// mElkerm : delivery Fee
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
                    if (deliveryPickupController != null &&
                        deliveryPickupController!.getPickUpMethod().selected)
                      Helper.getPrice(
                        0,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      )
                    else if (Helper.canDelivery(
                      _con.carts[0].food!.restaurant!,
                      carts: _con.carts,
                    ))
                      Helper.getPrice(
                        _con.carts[0].food!.restaurant!.deliveryFee,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      )
                    else
                      Helper.getPrice(
                        0,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      ),
                  ],
                ),

                /// mElkerm : Tax
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
                    Text("\$${_con.total}", style: AppTextStyles.font16W600Black),
                  ],
                ),
                SizedBox(height: 10),


                /// mElkerm : CheckOut Button
                Stack(
                  fit: StackFit.loose,
                  alignment: AlignmentDirectional.centerEnd,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: CustomMaterialButton(
                        onPressed: _con.isLoading ? null : () => _con.goCheckout(context),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPriceWidget(context),
                    ),
                  ],
                ),
                // CustomMaterialButton(onPressed: () {})
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

    if (deliveryPickupController != null &&
        deliveryPickupController!.getPickUpMethod().selected) {
      return Helper.getPrice(
        total - deliveryFee,
        context,
        style: textStyle,
        zeroPlaceholder: 'Free',
      );
    }

    if (Helper.canDelivery(restaurant, carts: _con.carts)) {
      return Helper.getPrice(
        total,
        context,
        style: textStyle,
        zeroPlaceholder: 'Free',
      );
    }

    return Helper.getPrice(
      total - deliveryFee,
      context,
      style: textStyle,
      zeroPlaceholder: 'Free',
    );
  }
}

/*
if (deliveryPickupController != null &&
                        deliveryPickupController!.getPickUpMethod().selected)
                      Helper.getPrice(
                        0,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      )
                    else if (Helper.canDelivery(
                      _con.carts[0].food!.restaurant!,
                      carts: _con.carts,
                    ))
                      Helper.getPrice(
                        _con.carts[0].food!.restaurant!.deliveryFee,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      )
                    else
                      Helper.getPrice(
                        0,
                        context,
                        style: Theme.of(context).textTheme.titleMedium,
                        zeroPlaceholder: 'Free',
                      ),
 */
