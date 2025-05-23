import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.onSuffixTapped,
    required this.lableText,
    this.hint,
    required this.prefix,
    required this.suffix,
  });
  final TextEditingController controller;
  final void Function()? onSuffixTapped;
  final String lableText;
  final String? hint;
  final Widget prefix;
  final Widget suffix;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColors.cardBgColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.font14W400Black.copyWith(
          color: AppColors.color9D9FA4,
        ),
        labelText: lableText,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        floatingLabelStyle: AppTextStyles.font12W400Grey,
        alignLabelWithHint: true,
        enabled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.colorF1F1F1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.colorF1F1F1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.colorF1F1F1),
        ),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 12, end: 8),
          child: prefix,
        ),
        suffixIcon: Padding(
          padding: EdgeInsetsDirectional.only(end: 12),
          child: GestureDetector(onTap: onSuffixTapped, child: suffix),
        ),
      ),
    );
  }
}
