import '../helpers/custom_trace.dart';

class Payment {
  String id;
  String status;
  String method;

  Payment({this.id = '', this.status = '', this.method = ''});

  factory Payment.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Payment(id: jsonMap?['id']?.toString() ?? '', status: jsonMap?['status']?.toString() ?? '', method: jsonMap?['method']?.toString() ?? '');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Payment();
    }
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'status': status, 'method': method};
  }
}
