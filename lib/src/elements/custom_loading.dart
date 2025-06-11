
import 'package:flutter/material.dart';

import '../helpers/app_colors.dart';


class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key,   this.color});

  final Color? color;
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: color ?? AppColors.color26386A,);
  }
}
