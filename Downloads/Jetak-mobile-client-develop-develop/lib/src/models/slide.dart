import '../helpers/custom_trace.dart';
import '../models/media.dart';
import '../models/restaurant.dart';
import 'food.dart';

class Slide {
  String id;
  int order;
  String text;
  String button;
  String textPosition;
  String textColor;
  String buttonColor;
  String backgroundColor;
  String indicatorColor;
  Media image;
  String imageFit;
  Food food;
  Restaurant restaurant;
  bool enabled;

  Slide({
    this.id = '',
    this.order = 0,
    this.text = '',
    this.button = '',
    this.textPosition = '',
    this.textColor = '',
    this.buttonColor = '',
    this.backgroundColor = '',
    this.indicatorColor = '',
    Media? image,
    this.imageFit = 'cover',
    Food? food,
    Restaurant? restaurant,
    this.enabled = false,
  }) : image = image ?? Media(),
       food = food ?? Food.fromJSON({}),
       restaurant = restaurant ?? Restaurant.fromJSON({});

  factory Slide.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Slide(
        id: jsonMap?['id']?.toString() ?? '',
        order: jsonMap?['order'] ?? 0,
        text: jsonMap?['text']?.toString() ?? '',
        button: jsonMap?['button']?.toString() ?? '',
        textPosition: jsonMap?['text_position']?.toString() ?? '',
        textColor: jsonMap?['text_color']?.toString() ?? '',
        buttonColor: jsonMap?['button_color']?.toString() ?? '',
        backgroundColor: jsonMap?['background_color']?.toString() ?? '',
        indicatorColor: jsonMap?['indicator_color']?.toString() ?? '',
        imageFit: jsonMap?['image_fit']?.toString() ?? 'cover',
        enabled: jsonMap?['enabled'] ?? false,
        restaurant: jsonMap?['restaurant'] != null ? Restaurant.fromJSON(jsonMap!['restaurant']) : Restaurant.fromJSON({}),
        food: jsonMap?['food'] != null ? Food.fromJSON(jsonMap!['food']) : Food.fromJSON({}),
        image: (jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap['media'][0]) : Media(),
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Slide();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "text": text, "order": order, "button": button, "text_position": textPosition, "text_color": textColor, "button_color": buttonColor};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Slide && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
