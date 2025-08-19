import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:global_configuration/global_configuration.dart';
import 'lib/src/services/intercom_service.dart';

/// سكريبت لاختبار حل مشكلة Intercom على Android
class IntercomTestApp extends StatefulWidget {
  @override
  _IntercomTestAppState createState() => _IntercomTestAppState();
}

class _IntercomTestAppState extends State<IntercomTestApp> {
  final IntercomService _intercomService = IntercomService();
  String _status = 'جاري التهيئة...';
  bool _isInitialized = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _testIntercom();
  }

  Future<void> _testIntercom() async {
    try {
      setState(() {
        _status = 'جاري تحميل الإعدادات...';
      });

      // تحميل الإعدادات
      await GlobalConfiguration().loadFromAsset("configurations");
      
      final appId = GlobalConfiguration().getValue("intercom")?["app_id"]?.toString() ?? '';
      final iosKey = GlobalConfiguration().getValue("intercom")?["ios_api_key"]?.toString() ?? '';
      final androidKey = GlobalConfiguration().getValue("intercom")?["android_api_key"]?.toString() ?? '';

      setState(() {
        _status = 'الإعدادات محملة\nApp ID: $appId';
      });

      // اختبار التهيئة
      if (appId.isNotEmpty && (iosKey.isNotEmpty || androidKey.isNotEmpty)) {
        setState(() {
          _status = 'جاري تهيئة Intercom...';
        });

        final success = await _intercomService.initialize(
          appId: appId,
          iosApiKey: iosKey.isNotEmpty ? iosKey : null,
          androidApiKey: androidKey.isNotEmpty ? androidKey : null,
        );

        if (success) {
          setState(() {
            _isInitialized = true;
            _status = '✅ Intercom مُهيأ بنجاح\nجاري تسجيل المستخدم...';
          });

          // اختبار تسجيل المستخدم
          final loginSuccess = await _intercomService.loginUser(
            userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
            email: 'test@example.com',
            name: 'مستخدم الاختبار',
          );

          if (loginSuccess) {
            setState(() {
              _isUserLoggedIn = true;
              _status = '✅ Intercom مُهيأ ومستخدم مسجل\nجاهز للاختبار!';
            });
          } else {
            setState(() {
              _status = '⚠️ Intercom مُهيأ لكن فشل تسجيل المستخدم';
            });
          }
        } else {
          setState(() {
            _status = '❌ فشل في تهيئة Intercom';
          });
        }
      } else {
        setState(() {
          _status = '❌ إعدادات Intercom غير مكتملة\nApp ID: $appId\niOS Key: ${iosKey.isNotEmpty ? "موجود" : "مفقود"}\nAndroid Key: ${androidKey.isNotEmpty ? "موجود" : "مفقود"}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في الاختبار: $e';
      });
    }
  }

  Future<void> _testMessenger() async {
    if (!_isInitialized) {
      setState(() {
        _status = '❌ Intercom غير مُهيأ';
      });
      return;
    }

    try {
      setState(() {
        _status = 'جاري فتح المحادثة...';
      });

      await _intercomService.openMessenger();
      
      setState(() {
        _status = '✅ المحادثة مفتوحة بنجاح!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في فتح المحادثة: $e';
      });
    }
  }

  Future<void> _testSendMessage() async {
    if (!_isInitialized || !_isUserLoggedIn) {
      setState(() {
        _status = '❌ Intercom غير جاهز لإرسال الرسائل';
      });
      return;
    }

    try {
      setState(() {
        _status = 'جاري إرسال رسالة اختبار...';
      });

      await _intercomService.sendMessage('رسالة اختبار من التطبيق - ${DateTime.now()}');
      
      setState(() {
        _status = '✅ تم إرسال رسالة الاختبار بنجاح!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إرسال الرسالة: $e';
      });
    }
  }

  Future<void> _resetIntercom() async {
    try {
      setState(() {
        _status = 'جاري إعادة تعيين Intercom...';
      });

      await _intercomService.logout();
      _intercomService.reset();
      
      setState(() {
        _isInitialized = false;
        _isUserLoggedIn = false;
        _status = '✅ تم إعادة تعيين Intercom\nاضغط "اختبار التهيئة" للبدء من جديد';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إعادة التعيين: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار Intercom',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('اختبار حل مشكلة Intercom'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حالة النظام
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة النظام:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isInitialized ? Icons.check_circle : Icons.error,
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Intercom مُهيأ: ${_isInitialized ? "نعم" : "لا"}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isUserLoggedIn ? Icons.check_circle : Icons.error,
                            color: _isUserLoggedIn ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('مستخدم مسجل: ${_isUserLoggedIn ? "نعم" : "لا"}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Platform.isAndroid ? Icons.android : Icons.phone_iphone,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('النظام: ${Platform.isAndroid ? "Android" : "iOS"}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // حالة الاختبار
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة الاختبار:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _status,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // أزرار الاختبار
              ElevatedButton(
                onPressed: _testIntercom,
                child: Text('اختبار التهيئة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: _isInitialized ? _testMessenger : null,
                child: Text('اختبار فتح المحادثة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: (_isInitialized && _isUserLoggedIn) ? _testSendMessage : null,
                child: Text('اختبار إرسال رسالة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: _resetIntercom,
                child: Text('إعادة تعيين Intercom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IntercomTestApp());
}
