import '../helpers/custom_trace.dart';

class OrderStatus {
  String id;
  String status;

  OrderStatus({this.id = '', this.status = ''});

  factory OrderStatus.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return OrderStatus(id: jsonMap?['id']?.toString() ?? '', status: jsonMap?['status']?.toString() ?? '');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return OrderStatus();
    }
  }
}
