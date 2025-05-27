import 'package:google_maps_flutter/google_maps_flutter.dart';

class Step {
  final LatLng startLatLng;

  Step({required this.startLatLng});

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(startLatLng: LatLng(json["end_location"]["lat"]?.toDouble() ?? 0.0, json["end_location"]["lng"]?.toDouble() ?? 0.0));
  }
}
