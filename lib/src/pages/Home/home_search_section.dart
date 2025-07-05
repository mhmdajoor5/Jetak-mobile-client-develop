import 'package:flutter/material.dart';
import '../../elements/SearchBarWidget.dart';

class HomeSearchSection extends StatelessWidget {
  final ValueChanged<dynamic> onClickFilter;

  const HomeSearchSection({
    Key? key,
    required this.onClickFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchBarWidget(
        onClickFilter: onClickFilter,
      ),
    );
  }
}