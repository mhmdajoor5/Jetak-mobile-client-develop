import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/back_button.dart';
import '../elements/tip_item.dart';
import '../elements/custom_tab_bar.dart';
import '../elements/custom_text_field.dart';
import '../elements/payment_method_card.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';
import '../helpers/swipe_button_widget.dart';
import '../models/address.dart';
import '../models/resturant/resturant_details_model.dart';
import '../models/route_argument.dart';
import 'order_success.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const DeliveryPickupWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

int selectedTap = 1;
String selectedPaymentMethod = '';
double? _tipValue = 0;

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  late DeliveryPickupController _con;
  late RestaurantDetailsModel _details;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  @override
  void initState() {
    super.initState();
    final param = widget.routeArgument?.param;
    if (param is RestaurantDetailsModel) {
      _details = param;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      _details = RestaurantDetailsModel(
        restaurant: RestaurantModelInCaseDetails.fromJson({}),
        categories: [],
        canDeliver: false,
      );
    }
  }

  double returnTheTotal() {
    if (selectedTap == 2) {
      return _con.total - _con.deliveryFee;
    }
    return _con.total;
  }

  @override
  Widget build(BuildContext context) {
    final bool canDeliver = _details.canDeliver;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwipeButtonWidget(
          context: context,
          numOfItems: _con.carts.length,
          onSwipe: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderSuccessWidget(
                  routeArgument: RouteArgument(
                    param: selectedTap == 1
                        ? 'Cash on Delivery'
                        : 'Pay on Pickup',
                  ),
                ),
              ),
            );
          },
          totalPrice: returnTheTotal(),
        ),
      ),
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: CustomBackButton(onTap: () => Navigator.pop(context)),
        ),
        title: Text(
          S.of(context).delivery_or_pickup,
          style: AppTextStyles.font16W600Black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              CustomTabBar(
                tabs: [
                  if (canDeliver)
                    TabItem(
                      text: S.of(context).delivery,
                      isSelected: selectedTap == 1,
                      onPressed: () => setState(() => selectedTap = 1),
                    ),
                  TabItem(
                    text: S.of(context).pickup,
                    isSelected: selectedTap == 2 || !canDeliver,
                    onPressed: () => setState(() => selectedTap = 2),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (selectedTap == 1 && canDeliver) ...[
                _buildAddressField(
                  TextEditingController(),
                      () async {
                    final address = await Navigator.of(context).pushNamed(
                      '/DeliveryAddresses',
                      arguments: [true, _con],
                    );
                    if (address is Address) {
                      setState(() {
                        _con.deliveryAddress = address;
                      });
                    }
                  },
                ),
              ] else ...[
                PaymentMethodCard(
                  title: S.of(context).pickup,
                  image: 'assets/img/shop.svg',
                  isSelected: true,
                  onTap: () => setState(() => selectedTap = 2),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                S.of(context).payment_method,
                style: AppTextStyles.font16W600Black,
              ),
              const SizedBox(height: 12),
              PaymentMethodCard(
                title: S.of(context).credit_card,
                image: 'assets/img/card.svg',
                isSelected: selectedPaymentMethod == 'credit',
                onTap: () => setState(() => selectedPaymentMethod = 'credit'),
              ),
              const SizedBox(height: 8),
              PaymentMethodCard(
                title: S.of(context).cash,
                image: 'assets/img/empty-wallet.svg',
                isSelected: selectedPaymentMethod == 'cash',
                onTap: () => setState(() => selectedPaymentMethod = 'cash'),
              ),
              const SizedBox(height: 16),
              _buildPromoCodeField(TextEditingController()),
              const SizedBox(height: 24),
              Text(
                S.of(context).add_courier_tip,
                style: AppTextStyles.font16W600Black,
              ),
              const SizedBox(height: 12),
              CourierTip(
                values: [0, 1, 2, 10],
                onValueChanged: (value) => _tipValue = value,
              ),
              const SizedBox(height: 24),
              CartBottomDetailsWidget(
                con: _con,
                selectedTap: selectedTap,
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCodeField(TextEditingController controller) {
    return CustomTextField(
      lableText: S.of(context).add_a_promo_code,
      hint: S.of(context).enter_here,
      prefix: SvgPicture.asset(
        'assets/img/ticket-discount.svg',
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(AppColors.color9D9FA4, BlendMode.srcATop),
      ),
      suffix: const Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: AppColors.color9D9FA4,
      ),
      controller: controller,
      onSuffixTapped: () {},
    );
  }

  Widget _buildAddressField(TextEditingController controller, VoidCallback? onChangePressed) {
    return CustomTextField(
      controller: controller,
      lableText: _con.userDeliverAddress.isEmpty
          ? S.of(context).address
          : _con.userDeliverAddress,
      prefix: SvgPicture.asset(
        'assets/img/location.svg',
        width: 18,
        height: 18,
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(top: 17.5),
        child: Text(
          S.of(context).change,
          style: AppTextStyles.font12W400Grey.copyWith(color: AppColors.color26386A),
        ),
      ),
      onSuffixTapped: onChangePressed,
    );
  }
}
