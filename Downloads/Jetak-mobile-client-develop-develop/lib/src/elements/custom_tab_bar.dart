import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key, required this.tabs});
  final List<TabItem> tabs;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.colorFAFAFA,
        borderRadius: BorderRadius.circular(52),
        border: Border.all(color: AppColors.colorF1F1F1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs,
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.onPressed,
    required this.text,
    this.isSelected = false,
  });

  final void Function()? onPressed;
  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        width: 166.5,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.color26386A : Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.font14W500White.copyWith(
              color: isSelected ? Colors.white : AppColors.color9D9FA4,
            ),
          ),
        ),
      ),
    );
  }
}
