import 'package:global_configuration/global_configuration.dart';
import '../helpers/custom_trace.dart';

class Media {
  String id;
  String name;
  String url;
  String thumb;
  String icon;
  String size;

  Media({this.id = '', this.name = '', String? url, String? thumb, String? icon, this.size = ''})
      : url = url ?? "assets/img/restaurant.png",
        thumb = thumb ?? "assets/img/restaurant.png",
        icon = icon ?? "assets/img/restaurant.png";

  factory Media.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Media(
        id: jsonMap?['id']?.toString() ?? '',
        name: jsonMap?['name']?.toString() ?? '',
        url: jsonMap?['url']?.toString() ?? "assets/img/restaurant.png",
        thumb: jsonMap?['thumb']?.toString() ?? "assets/img/restaurant.png",
        icon: jsonMap?['icon']?.toString() ?? "assets/img/restaurant.png",
        size: jsonMap?['formated_size']?.toString() ?? '',
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Media();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "url": url, "thumb": thumb, "icon": icon, "formated_size": size};
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
