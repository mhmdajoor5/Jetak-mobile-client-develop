import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onTap});
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.colorF1F1F1),
        ),
        child: Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }
}
