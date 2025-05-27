import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Gallery {
  String id;
  Media image;
  String description;

  Gallery({this.id = '', Media? image, this.description = ''}) : image = image ?? Media();

  factory Gallery.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Gallery(
        id: jsonMap?['id']?.toString() ?? '',
        image: (jsonMap?['media'] != null && (jsonMap!['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap['media'][0]) : Media(),
        description: jsonMap?['description']?.toString() ?? '',
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Gallery();
    }
  }
}
