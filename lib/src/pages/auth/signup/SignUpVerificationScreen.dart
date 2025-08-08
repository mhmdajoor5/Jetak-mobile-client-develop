import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../generated/l10n.dart';
import '../../../repository/user_repository.dart' as userRepo;

class SignUpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SignUpVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _SignUpVerificationScreenState createState() => _SignUpVerificationScreenState();
}

class _SignUpVerificationScreenState extends State<SignUpVerificationScreen> {
  final int codeLength = 4;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  int resendCooldown = 30;
  bool canResend = false;
  Timer? _resendTimer;

  bool isVerifying = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
    sendOtp();
    startResendCooldown();
  }

  Future<void> sendOtp() async {
    print('📤 === بدء إرسال OTP في SignUpVerificationScreen ===');
    print('📱 رقم الهاتف: ${widget.phoneNumber}');
    print('🔑 API Token: ${userRepo.currentUser.value.apiToken}');
    
    try {
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_token": userRepo.currentUser.value.apiToken,
          "phone": widget.phoneNumber,
        }),
      );

      print('📥 استجابة إرسال OTP: ${response.statusCode}');
      print('📥 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ تم إرسال OTP بنجاح');
          print('📋 بيانات الاستجابة: $data');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إرسال رمز التحقق بنجاح')),
          );
        } catch (e) {
          print('❌ خطأ في تحليل JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في استجابة الخادم')),
          );
        }
      } else {
        print('❌ فشل إرسال OTP: ${response.statusCode}');
        print('📥 محتوى الخطأ: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إرسال رمز التحقق')),
        );
      }
    } catch (e) {
      print('❌ خطأ في إرسال OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال')),
      );
    }
  }

  void startResendCooldown() {
    setState(() {
      canResend = false;
      resendCooldown = 30;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        resendCooldown--;
        if (resendCooldown <= 0) {
          canResend = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  void resendCode() {
    print('🔄 إعادة إرسال الكود');
    sendOtp();
    startResendCooldown();
  }

  void verifyOTP() async {
    String smsCode = controllers.map((c) => c.text).join();
    if (smsCode.length < codeLength) return;

    print('🔐 === بدء التحقق من OTP في SignUpVerificationScreen ===');
    print('🔐 الكود المدخل: "$smsCode"');
    print('🔐 طول الكود: ${smsCode.length}');
    print('🔑 API Token: ${userRepo.currentUser.value.apiToken}');

    setState(() {
      isVerifying = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/submit-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_token": userRepo.currentUser.value.apiToken,
          "code": smsCode,
        }),
      );

      print('📥 استجابة التحقق: ${response.statusCode}');
      print('📥 محتوى الاستجابة: ${response.body}');

      setState(() => isVerifying = false);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ تم التحقق من OTP بنجاح');
          print('📋 بيانات الاستجابة: $data');
          
          // تحسين منطق التحقق من النجاح
          bool isSuccess = false;
          if (data['success'] == true || 
              data['status'] == 'success' || 
              data['status'] == 'available' ||
              data['data'] != null) {
            isSuccess = true;
          }
          
          if (isSuccess) {
            print('✅ OTP verified successfully');
            
            // تحديث بيانات المستخدم
            if (data['data'] != null) {
              // userRepo.currentUser.value = userRepo.User.fromJSON(data['data']);
            }
            
            // تحديث حالة التحقق من الهاتف
            userRepo.currentUser.value.updatePhoneVerification(true);
            print('📱 تم تحديث حالة التحقق من الهاتف');

            // حفظ بيانات المستخدم
            await userRepo.saveCurrentUser(json.encode(userRepo.currentUser.value.toMap()));
            print('💾 تم حفظ بيانات المستخدم');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم التحقق من الهاتف بنجاح'),
                backgroundColor: Colors.green,
              ),
            );

            print('🏠 === بدء التوجيه إلى الصفحة الرئيسية ===');
            print('🏠 المسار: /Pages');
            print('🏠 Arguments: 0');
            
            // تأخير قصير قبل التوجيه
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
              print('✅ تم التوجيه بنجاح');
            } else {
              print('❌ Widget غير mounted');
            }
          } else {
            print('❌ الكود غير صحيح');
            setState(() {
              errorMessage = 'الكود غير صحيح';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('الكود غير صحيح'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          print('❌ خطأ في تحليل JSON للتحقق: $e');
          setState(() {
            errorMessage = 'خطأ في استجابة الخادم';
          });
        }
      } else {
        print('❌ فشل التحقق من OTP: ${response.statusCode}');
        setState(() {
          errorMessage = "فشل التحقق: ${response.statusCode}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل التحقق: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في التحقق من OTP: $e');
      setState(() {
        isVerifying = false;
        errorMessage = 'خطأ في التحقق';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحقق'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('رمز التحقق'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لقد أرسلنا لك رمز التحقق',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(codeLength, (index) {
                return SizedBox(
                  width: 55,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 3),
                      ),
                    ),
                    onChanged: (value) {
                      print('📝 تغيير الكود في الحقل $index: "$value"');
                      
                      if (value.length > 1) {
                        controllers[index].text = value.substring(0, 1);
                      }
                      if (value.isNotEmpty) {
                        if (index < codeLength - 1) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        if (index > 0) {
                          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                          controllers[index - 1].selection = TextSelection.collapsed(offset: controllers[index - 1].text.length);
                        }
                      }

                      if (controllers.every((c) => c.text.isNotEmpty)) {
                        print('🔐 جميع الحقول مملوءة - بدء التحقق التلقائي');
                        verifyOTP();
                      }
                    },
                  ),
                );
              }),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isVerifying ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isVerifying
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                    'تحقق',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                isVerifying
                    ? CircularProgressIndicator()
                    : TextButton(
                  onPressed: canResend ? resendCode : null,
                  child: Text(
                    'إعادة إرسال',
                    style: TextStyle(
                      color: canResend ? Colors.blue.shade700 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!canResend)
                  Text(
                    'يمكن إعادة الإرسال خلال $resendCooldown ثانية',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'العودة لتعديل الرقم',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
