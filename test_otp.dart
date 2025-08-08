import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// اختبار بسيط لـ OTP
Future<void> testOTP() async {
  print('🧪 بدء اختبار OTP...');
  
  // بيانات الاختبار
  final String apiToken = "wy6wvxW1UriJi9CRpuZvdHSBMWYt1GLmltq480zsZ85rTE062Q9oimFDMwJv";
  final String phone = "+1234567890"; // استبدل برقم الهاتف الحقيقي
  final String testCode = "1234"; // استبدل بالكود الحقيقي
  
  final String baseUrl = "https://carrytechnologies.co/api/";
  
  try {
    // 1. اختبار إرسال OTP
    print('\n📱 اختبار إرسال OTP...');
    final sendOTPResponse = await http.post(
      Uri.parse('${baseUrl}send-sms'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "api_token": apiToken,
        "phone": phone,
      }),
    );
    
    print('📥 استجابة إرسال OTP: ${sendOTPResponse.statusCode}');
    print('📥 محتوى الاستجابة: ${sendOTPResponse.body}');
    
    if (sendOTPResponse.statusCode == 200) {
      print('✅ تم إرسال OTP بنجاح');
      
      // 2. اختبار التحقق من OTP
      print('\n🔐 اختبار التحقق من OTP...');
      final verifyOTPResponse = await http.post(
        Uri.parse('${baseUrl}submit-otp'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode({
          "api_token": apiToken,
          "code": testCode
        }),
      );
      
      print('📥 استجابة التحقق: ${verifyOTPResponse.statusCode}');
      print('📥 محتوى الاستجابة: ${verifyOTPResponse.body}');
      
      if (verifyOTPResponse.statusCode == 200) {
        print('✅ تم التحقق من OTP بنجاح');
      } else {
        print('❌ فشل التحقق من OTP');
      }
    } else {
      print('❌ فشل إرسال OTP');
    }
    
  } catch (e) {
    print('❌ خطأ في الاختبار: $e');
  }
}

void main() async {
  await testOTP();
} 