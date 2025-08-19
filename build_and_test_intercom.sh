#!/bin/bash

# سكريبت لبناء واختبار حل مشكلة Intercom على Android
# Build and Test Intercom Fix Script

echo "🚀 بدء عملية بناء واختبار حل Intercom..."

# تنظيف البناء السابق
echo "🧹 تنظيف البناء السابق..."
flutter clean

# تحديث التبعيات
echo "📦 تحديث التبعيات..."
flutter pub get

# بناء الإصدار المطلق
echo "🔨 بناء الإصدار المطلق..."
flutter build apk --release

# التحقق من نجاح البناء
if [ $? -eq 0 ]; then
    echo "✅ تم بناء التطبيق بنجاح!"
    
    # تثبيت التطبيق على الجهاز المتصل
    echo "📱 تثبيت التطبيق على الجهاز..."
    flutter install --release
    
    if [ $? -eq 0 ]; then
        echo "✅ تم تثبيت التطبيق بنجاح!"
        
        # عرض معلومات الجهاز
        echo "📋 معلومات الجهاز:"
        adb devices
        
        # مراقبة سجلات Intercom
        echo "📊 مراقبة سجلات Intercom (اضغط Ctrl+C لإيقاف):"
        echo "🔍 ابحث عن رسائل 'IntercomDebug' في السجلات"
        adb logcat | grep -E "(IntercomDebug|Intercom|intercom)"
        
    else
        echo "❌ فشل في تثبيت التطبيق"
        echo "💡 تأكد من توصيل جهاز Android أو تشغيل محاكي"
    fi
else
    echo "❌ فشل في بناء التطبيق"
    echo "🔍 تحقق من الأخطاء في البناء أعلاه"
fi

echo "🏁 انتهت عملية البناء والاختبار"
