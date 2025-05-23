import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.itemSubtotlalPrice,
    required this.serviceFeePrice,
    required this.deliveryPrice,
    required this.promoPrice,
  });
  final double itemSubtotlalPrice;
  final double serviceFeePrice;
  final double deliveryPrice;
  final double promoPrice;
  @override
  Widget build(BuildContext context) {
    final total = (itemSubtotlalPrice +
            serviceFeePrice +
            deliveryPrice -
            promoPrice)
        .toStringAsFixed(2);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.colorFAFAFA,
        border: Border.all(color: AppColors.colorF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).order_summary,
            style: AppTextStyles.font16W600Black,
          ),
          SizedBox(height: 4),
          Text(S.of(context).include_tax, style: AppTextStyles.font12W400Grey),
          SizedBox(height: 16),
          Divider(color: AppColors.colorF1F1F1),
          SizedBox(height: 12),
          Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PriceWidget(
                title: S.of(context).item_subtotal,
                price: itemSubtotlalPrice,
              ),
              PriceWidget(
                title: S.of(context).service_fee,
                price: serviceFeePrice,
              ),
              PriceWidget(title: S.of(context).delivery, price: deliveryPrice),
              PriceWidget(title: S.of(context).promo, price: promoPrice),

              Divider(color: AppColors.colorF1F1F1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).total,
                    style: AppTextStyles.font16W600Black,
                  ),
                  Text("\$$total", style: AppTextStyles.font16W600Black),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PriceWidget extends StatelessWidget {
  const PriceWidget({super.key, required this.title, required this.price});
  final String title;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.font12W400Grey),
        Text(
          "\$$price",
          style: AppTextStyles.font12W400Grey.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
