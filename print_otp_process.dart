// ملف لطباعة كامل عملية OTP
void printOTPProcess() {
  print('🚀 === بدء طباعة كامل عملية OTP ===');
  print('');
  
  print('📱 === المرحلة 1: تهيئة الصفحة ===');
  print('📱 رقم الهاتف: [سيتم طباعته من التطبيق]');
  print('📱 API Token: [سيتم طباعته من التطبيق]');
  print('📱 skipOTP: false');
  print('');
  
  print('📤 === المرحلة 2: إرسال OTP ===');
  print('📤 إرسال طلب إلى: https://carrytechnologies.co/api/send-sms');
  print('📤 البيانات المرسلة: {"api_token":"[TOKEN]","phone":"[PHONE]"}');
  print('📥 استجابة الخادم: 200');
  print('✅ تم إرسال OTP بنجاح');
  print('');
  
  print('🔐 === المرحلة 3: إدخال الكود ===');
  print('📝 تغيير الكود: "9759"');
  print('🔘 الكود المدخل: "9759"');
  print('🔘 طول الكود: 4');
  print('🔘 skipOTP: false');
  print('🔘 isLoading: false');
  print('');
  
  print('🔐 === المرحلة 4: التحقق من الكود ===');
  print('🔐 === بدء دالة verifyOTP ===');
  print('🔐 الكود المرسل: "9759"');
  print('🔐 طول الكود: 4');
  print('🔑 API Token موجود: [TOKEN]');
  print('🌐 URL: https://carrytechnologies.co/api/submit-otp');
  print('📤 البيانات المرسلة: {"api_token":"[TOKEN]","code":"9759"}');
  print('📥 استجابة الخادم: 200');
  print('📥 محتوى الاستجابة: {"data":{"id":211,"name":"tttest tttest",...}}');
  print('✅ استجابة ناجحة من الخادم');
  print('👤 بيانات المستخدم المحدثة:');
  print('- ID: 211');
  print('- Name: tttest tttest');
  print('- Phone: [PHONE]');
  print('- verifiedPhone: true');
  print('📱 تم تحديث حالة الهاتف إلى: 1');
  print('✅ تم التحقق من OTP بنجاح');
  print('🔐 === انتهت دالة verifyOTP بنجاح ===');
  print('🔐 نتيجة التحقق: true');
  print('');
  
  print('🏠 === المرحلة 5: التوجيه ===');
  print('✅ الكود صحيح - بدء التوجيه');
  print('🏠 بدء التوجيه بعد التحقق من OTP');
  print('✅ تم استدعاء callback');
  print('📱 إغلاق الـ bottom sheet');
  print('⏳ انتظار 500ms قبل التوجيه...');
  print('🏠 التوجيه إلى الصفحة الرئيسية');
  print('🔘 === انتهت عملية التحقق من الكود ===');
  print('');
  
  print('🎉 === النتيجة النهائية ===');
  print('✅ تم التحقق من الهاتف بنجاح');
  print('🏠 تم التوجيه إلى الصفحة الرئيسية');
  print('📱 حالة التحقق من الهاتف: true');
  print('');
  
  print('🏁 === انتهت كامل عملية OTP ===');
}

void main() {
  printOTPProcess();
} 