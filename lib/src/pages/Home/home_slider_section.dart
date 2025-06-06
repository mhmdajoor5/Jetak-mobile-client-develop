import 'package:flutter/material.dart';
import '../../elements/HomeSliderWidget.dart';
import '../../models/slide.dart';

class HomeSliderSection extends StatelessWidget {
  final List<Slide> slides;

  const HomeSliderSection({
    Key? key,
    required this.slides,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeSliderWidget(slides: slides);
  }
}