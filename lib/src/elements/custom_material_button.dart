import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({super.key, required this.onPressed});
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.color26386A,
      ),
      width: double.infinity,
      child: MaterialButton(
        onPressed: onPressed,
        child: Text("Pay now", style: AppTextStyles.font14W600White),
      ),
    );
  }
}
