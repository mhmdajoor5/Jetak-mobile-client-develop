import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 اختبار الاتصال بـ WebSocket');
  print('=' * 50);
  
  final urls = [
    'ws://carrytechnologies.co:6001',
    'wss://carrytechnologies.co:6001',
    'ws://carrytechnologies.co:8080',
    'wss://carrytechnologies.co:8080',
  ];
  
  for (String url in urls) {
    print('\n🌐 اختبار: $url');
    
    try {
      // اختبار HTTP أولاً
      final httpUrl = url.replaceFirst('ws://', 'http://').replaceFirst('wss://', 'https://');
      print('   - فحص HTTP: $httpUrl');
      
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(httpUrl));
      final response = await request.close();
      
      print('   - ✅ HTTP متاح: ${response.statusCode}');
      
      // اختبار WebSocket
      print('   - فحص WebSocket...');
      final socket = await WebSocket.connect(url).timeout(Duration(seconds: 5));
      
      print('   - ✅ WebSocket متاح');
      
      // إرسال رسالة اختبار
      final testMessage = {
        'event': 'test',
        'channel': 'order-tracking.test123',
        'data': {
          'order_id': 'test123',
          'test': true,
        }
      };
      
      socket.add(json.encode(testMessage));
      print('   - ✅ تم إرسال رسالة اختبار');
      
      // الاستماع للرد
      socket.listen(
        (data) {
          print('   - 📨 رد من الخادم: $data');
        },
        onError: (error) {
          print('   - ❌ خطأ في WebSocket: $error');
        },
        onDone: () {
          print('   - ✅ اتصال WebSocket مغلق');
        },
      );
      
      // إغلاق الاتصال بعد 3 ثوان
      await Future.delayed(Duration(seconds: 3));
      await socket.close();
      
    } catch (e) {
      print('   - ❌ فشل في الاتصال: $e');
    }
  }
  
  print('\n🏁 انتهى الاختبار');
} 