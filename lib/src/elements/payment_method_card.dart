import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    this.onTap,
    required this.title,
    required this.image,
    this.isSelected = false,
  });
  final void Function()? onTap;
  final String title;
  final String image;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.colorF1F1F1),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(color: AppColors.colorF5F5F7),
              child: SvgPicture.asset(
                image,
                fit: BoxFit.scaleDown,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.font14W400Black),
            Spacer(),

            Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: SvgPicture.asset(
                isSelected ? 'assets/img/radio.svg' : 'assets/img/ring.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
