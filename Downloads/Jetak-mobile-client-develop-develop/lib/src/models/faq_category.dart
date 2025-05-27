import '../helpers/custom_trace.dart';
import '../models/faq.dart';

class FaqCategory {
  String id;
  String name;
  List<Faq> faqs;

  FaqCategory({this.id = '', this.name = '', this.faqs = const []});

  factory FaqCategory.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return FaqCategory(
        id: jsonMap?['id']?.toString() ?? '',
        name: jsonMap?['name']?.toString() ?? '',
        faqs: jsonMap?['faqs'] != null ? List<Faq>.from(jsonMap!['faqs'].map((e) => Faq.fromJSON(e))) : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return FaqCategory();
    }
  }
}
