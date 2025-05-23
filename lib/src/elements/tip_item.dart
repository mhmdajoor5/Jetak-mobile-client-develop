import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class CourierTip extends StatefulWidget {
  const CourierTip({
    super.key,
    required this.values,
    required this.onValueChanged,
    this.onCustomTipPressed,
  });
  final List<double> values;
  final void Function(double) onValueChanged;
  final void Function()? onCustomTipPressed;

  @override
  State<CourierTip> createState() => _CourierTipState();
}

class _CourierTipState extends State<CourierTip> {
  double? _tipValue = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        ...List.generate(
          widget.values.length,
          (index) => TipItem(
            value: widget.values[index],
            isSelected: _tipValue == widget.values[index],
            onTap: () {
              setState(() {
                _tipValue = widget.values[index];
                widget.onValueChanged(widget.values[index]);
              });
            },
          ),
        ),

        TipItem(
          value: 0,
          isSelected: false,
          onTap: () {
            setState(() {
              _tipValue = null;
            });
            widget.onCustomTipPressed;
          },
          child: SvgPicture.asset('assets/img/edit.svg', width: 20, height: 20),
        ),
      ],
    );
  }
}

class TipItem extends StatelessWidget {
  const TipItem({
    super.key,
    required this.value,
    this.isSelected = false,
    this.onTap,
    this.child,
  });
  final double value;
  final bool isSelected;
  final void Function()? onTap;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 62,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.colorE4E7F0 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.color26386A : AppColors.colorF1F1F1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child:
              child ??
              Text(
                "\$ $value",
                style: AppTextStyles.font14W500White.copyWith(
                  color: isSelected ? AppColors.color26386A : Colors.black,
                  fontSize: 16,
                ),
              ),
        ),
      ),
    );
  }
}
