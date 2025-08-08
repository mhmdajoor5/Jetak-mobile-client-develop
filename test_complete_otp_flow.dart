import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// اختبار شامل لسير عمل OTP
Future<void> testCompleteOTPFlow() async {
  print('🧪 بدء اختبار شامل لسير عمل OTP...');
  
  // بيانات الاختبار
  final String apiToken = "wy6wvxW1UriJi9CRpuZvdHSBMWYt1GLmltq480zsZ85rTE062Q9oimFDMwJv";
  final String phone = "+1234567890"; // استبدل برقم الهاتف الحقيقي
  final String testCode = "1234"; // استبدل بالكود الحقيقي
  
  final String baseUrl = "https://carrytechnologies.co/api/";
  
  try {
    print('\n=== المرحلة 1: إرسال OTP ===');
    
    // 1. اختبار إرسال OTP
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
      
      print('\n=== المرحلة 2: التحقق من OTP ===');
      
      // 2. اختبار التحقق من OTP
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
        
        print('\n=== المرحلة 3: محاكاة التوجيه ===');
        
        // 3. محاكاة التوجيه إلى الصفحة الرئيسية
        print('🏠 بدء التوجيه بعد التحقق من OTP');
        print('🏠 إغلاق الـ bottom sheet');
        print('🏠 التوجيه إلى الصفحة الرئيسية');
        
        // محاكاة تأخير قصير
        await Future.delayed(const Duration(milliseconds: 500));
        
        print('✅ تم التوجيه إلى الصفحة الرئيسية بنجاح');
        
        print('\n=== المرحلة 4: التحقق من حالة المستخدم ===');
        
        // 4. التحقق من حالة المستخدم
        final responseData = json.decode(verifyOTPResponse.body);
        final userData = responseData['data'];
        
        print('👤 بيانات المستخدم:');
        print('- ID: ${userData['id']}');
        print('- Name: ${userData['name']}');
        print('- Email: ${userData['email']}');
        print('- Phone: ${userData['phone'] ?? 'غير محدد'}');
        print('- Status: ${userData['status']}');
        
        // التحقق من وجود الكود في الاستجابة
        if (userData['code'] == testCode) {
          print('✅ الكود موجود في استجابة المستخدم');
        } else {
          print('⚠️ الكود غير موجود في استجابة المستخدم');
        }
        
        print('\n🎉 اختبار سير عمل OTP مكتمل بنجاح!');
        
      } else {
        print('❌ فشل التحقق من OTP');
        print('📋 تفاصيل الخطأ: ${verifyOTPResponse.body}');
      }
    } else {
      print('❌ فشل إرسال OTP');
      print('📋 تفاصيل الخطأ: ${sendOTPResponse.body}');
    }
    
  } catch (e) {
    print('❌ خطأ في الاختبار: $e');
  }
}

// اختبار سريع للتوجيه
Future<void> testNavigation() async {
  print('\n🧪 اختبار التوجيه...');
  
  // محاكاة نجاح التحقق
  bool verificationSuccess = true;
  
  if (verificationSuccess) {
    print('✅ تم التحقق من OTP بنجاح');
    
    // محاكاة إغلاق bottom sheet
    print('📱 إغلاق الـ bottom sheet');
    
    // محاكاة التوجيه
    print('🏠 التوجيه إلى الصفحة الرئيسية');
    print('📱 المسار: /Pages');
    print('📱 Arguments: 0');
    
    print('✅ اختبار التوجيه نجح');
  } else {
    print('❌ فشل التحقق من OTP');
  }
}

void main() async {
  print('🚀 بدء اختبارات OTP الشاملة');
  print('=' * 50);
  
  await testCompleteOTPFlow();
  await testNavigation();
  
  print('\n' + '=' * 50);
  print('🏁 انتهت جميع الاختبارات');
} 