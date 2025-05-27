import '../helpers/custom_trace.dart';

class Faq {
  String id;
  String question;
  String answer;

  Faq({this.id = '', this.question = '', this.answer = ''});

  factory Faq.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Faq(id: jsonMap?['id']?.toString() ?? '', question: jsonMap?['question']?.toString() ?? '', answer: jsonMap?['answer']?.toString() ?? '');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Faq();
    }
  }
}
