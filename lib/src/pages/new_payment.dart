import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../elements/back_button.dart';
import '../elements/order_summary.dart';
import '../elements/tip_item.dart';
import '../elements/custom_material_button.dart';
import '../elements/custom_tab_bar.dart';
import '../elements/custom_text_field.dart';
import '../elements/payment_method_card.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

int selectedTap = 1;
String selectedPaymentMethod = '';

double? _tipValue = 0;

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: CustomBackButton(onTap: () {}),
        ),
        title: Text(
          S.of(context).payment,
          style: AppTextStyles.font16W600Black,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: CustomMaterialButton(onPressed: () {}),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  CustomTabBar(
                    tabs: [
                      TabItem(
                        text: S.of(context).delivery,
                        isSelected: selectedTap == 1,
                        onPressed: () {
                          setState(() {
                            selectedTap = 1;
                          });
                        },
                      ),
                      TabItem(
                        text: S.of(context).pickup,
                        isSelected: selectedTap == 2,
                        onPressed: () {
                          setState(() {
                            selectedTap = 2;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Address filed
                  _buildAddressField(TextEditingController(), () {}),
                  SizedBox(height: 24),

                  // Payent Method
                  Text(
                    S.of(context).payment_method,
                    style: AppTextStyles.font16W600Black,
                  ),
                  SizedBox(height: 12),
                  PaymentMethodCard(
                    title: S.of(context).credit_card,
                    image: 'assets/img/card.svg',
                    isSelected: selectedPaymentMethod.contains('credit'),
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = "credit";
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  PaymentMethodCard(
                    title: S.of(context).cash,
                    image: 'assets/img/empty-wallet.svg',
                    isSelected: selectedPaymentMethod.contains('cash'),
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = "cash";
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Promo code field
                  _buildPromoCodeField(TextEditingController()),
                  SizedBox(height: 24),
                  // Add Courier tip
                  Text(
                    S.of(context).add_courier_tip,
                    style: AppTextStyles.font16W600Black,
                  ),
                  SizedBox(height: 12),
                  CourierTip(
                    values: [0, 1, 2, 10],
                    onValueChanged: (value) {
                      _tipValue = value;
                    },
                  ),
                  SizedBox(height: 24),

                  OrderSummary(
                    itemSubtotlalPrice: 30.5,
                    serviceFeePrice: 0.99,
                    deliveryPrice: 0.99,
                    promoPrice: 1.0,
                  ),

                  SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildPromoCodeField(TextEditingController controller) {
    return CustomTextField(
      lableText: S.of(context).add_a_promo_code,
      hint: S.of(context).enter_here,
      prefix: SvgPicture.asset(
        'assets/img/ticket-discount.svg',
        width: 18,
        height: 18,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(AppColors.color9D9FA4, BlendMode.srcATop),
      ),
      suffix: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: AppColors.color9D9FA4,
      ),
      controller: controller,
      onSuffixTapped: () {},
    );
  }

  _buildAddressField(
    TextEditingController controller,
    void Function()? onChangePressed,
  ) {
    return CustomTextField(
      controller: controller,
      lableText: S.of(context).address,
      prefix: SvgPicture.asset(
        'assets/img/location.svg',
        width: 18,
        height: 18,
        fit: BoxFit.scaleDown,
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(top: 17.5),
        child: Text(
          S.of(context).change,
          style: AppTextStyles.font12W400Grey.copyWith(
            color: AppColors.color26386A,
          ),
        ),
      ),
      onSuffixTapped: onChangePressed,
    );
  }
}
