import '../helpers/custom_trace.dart';
import '../models/cuisine.dart';

class Filter {
  bool delivery;
  bool open;
  List<Cuisine> cuisines;

  Filter({this.delivery = false, this.open = false, this.cuisines = const []});

  factory Filter.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Filter(
        open: jsonMap?['open'] ?? false,
        delivery: jsonMap?['delivery'] ?? false,
        cuisines: jsonMap?['cuisines'] != null ? List<Cuisine>.from(jsonMap!['cuisines'].map((e) => Cuisine.fromJSON(e))) : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Filter();
    }
  }

  Map<String, dynamic> toMap() {
    return {'open': open, 'delivery': delivery, 'cuisines': cuisines.map((e) => e.toMap()).toList()};
  }

  @override
  String toString() {
    if (delivery && open) {
      return "search=available_for_delivery:1;closed:0&searchFields=available_for_delivery:=;closed:=&searchJoin=and";
    } else if (delivery) {
      return "search=available_for_delivery:1&searchFields=available_for_delivery:=";
    } else if (open) {
      return "search=closed:0&searchFields=closed:=";
    }
    return '';
  }

  Map<String, dynamic> toQuery({Map<String, dynamic>? oldQuery}) {
    final query = <String, dynamic>{};
    String relation = '';

    if (oldQuery != null) {
      relation = oldQuery['with'] != null ? '${oldQuery['with']}.' : '';
      query['with'] = oldQuery['with'];
    }

    if (delivery && open) {
      query['search'] = '${relation}available_for_delivery:1;closed:0';
      query['searchFields'] = '${relation}available_for_delivery:=;closed:=';
    } else if (delivery) {
      query['search'] = '${relation}available_for_delivery:1';
      query['searchFields'] = '${relation}available_for_delivery:=';
    } else if (open) {
      query['search'] = '${relation}closed:0';
      query['searchFields'] = '${relation}closed:=';
    }

    if (cuisines.isNotEmpty) {
      query['cuisines[]'] = cuisines.map((e) => e.id).toList();
    }

    if (oldQuery != null) {
      if (oldQuery['search'] != null) {
        query['search'] = query['search'] != null ? '${query['search']};${oldQuery['search']}' : oldQuery['search'];
      }
      if (oldQuery['searchFields'] != null) {
        query['searchFields'] = query['searchFields'] != null ? '${query['searchFields']};${oldQuery['searchFields']}' : oldQuery['searchFields'];
      }
    }

    query['searchJoin'] = 'and';
    return query;
  }
}
