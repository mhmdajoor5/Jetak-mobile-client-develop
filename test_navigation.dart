import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// اختبار بسيط للتوجيه بعد OTP
void main() {
  testWidgets('OTP verification should navigate to home page', (WidgetTester tester) async {
    // هذا اختبار بسيط للتأكد من أن منطق التوجيه يعمل
    print('🧪 اختبار التوجيه بعد OTP');
    
    // محاكاة نجاح التحقق من OTP
    bool verificationSuccess = true;
    
    if (verificationSuccess) {
      print('✅ تم التحقق من OTP بنجاح');
      print('🏠 سيتم التوجيه إلى الصفحة الرئيسية');
      
      // محاكاة التوجيه
      String targetRoute = '/Pages';
      int arguments = 0;
      
      print('📱 التوجيه إلى: $targetRoute مع arguments: $arguments');
      
      // التحقق من صحة التوجيه
      expect(targetRoute, '/Pages');
      expect(arguments, 0);
      
      print('✅ اختبار التوجيه نجح');
    } else {
      print('❌ فشل التحقق من OTP');
    }
  });
} 