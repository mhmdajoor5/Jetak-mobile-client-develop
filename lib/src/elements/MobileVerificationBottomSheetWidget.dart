import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart';
import 'BlockButtonWidget.dart';

class MobileVerificationBottomSheetWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final userModel.User? user;
  final ValueChanged<bool>? valueChangedCallback;

  MobileVerificationBottomSheetWidget({Key? key, this.scaffoldKey, this.user, this.valueChangedCallback}) : super(key: key);

  @override
  _MobileVerificationBottomSheetWidgetState createState() => _MobileVerificationBottomSheetWidgetState();
}

class _MobileVerificationBottomSheetWidgetState extends State<MobileVerificationBottomSheetWidget> {
  final bool skipOTP = false; // ❌ تعطيل تجاوز التحقق للاختبار

  bool isLoading = false;
  String smsSent = '';
  String? errorMessage;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textEditingController = TextEditingController();
  late StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    verifyPhone();
  }

  @override
  void dispose() {
    errorController.close();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    print('📱 === بدء عملية التحقق من الهاتف ===');
    print('📱 رقم الهاتف: ${currentUser.value.phone}');
    print('📱 API Token: ${currentUser.value.apiToken}');
    print('📱 skipOTP: $skipOTP');
    
    currentUser.value.verificationId = '';
    smsSent = '';
    if (!skipOTP) {
      try {
        print('📤 إرسال OTP...');
        await sendOTP(currentUser.value.phone ?? '');
        print('✅ تم إرسال OTP بنجاح');
      } catch (e) {
        print('❌ خطأ في إرسال OTP: $e');
        setState(() {
          errorMessage = 'خطأ في إرسال رمز التحقق: $e';
        });
      }
    } else {
      print('⏭️ تم تجاوز إرسال OTP');
    }
    print('📱 === انتهت عملية التحقق من الهاتف ===');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, -30))],
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: ListView(
              padding: const EdgeInsets.only(top: 40, bottom: 15, left: 20, right: 20),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(S.of(context).verifyPhoneNumber, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    errorMessage == null
                        ? Text(S.of(context).weAreSendingOtpToValidateYourMobileNumberHang, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)
                        : Text(errorMessage!, style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(color: Colors.redAccent)), textAlign: TextAlign.center),
                  ],
                ),
                const SizedBox(height: 30),
                if (!skipOTP)
                  PinCodeTextField(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    appContext: context,
                    pastedTextStyle: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
                    length: 4,
                    animationType: AnimationType.scale,
                    validator: (v) => null,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).indicatorColor,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [BoxShadow(offset: Offset(0, 1), color: Colors.black12, blurRadius: 10)],
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      print('📝 تغيير الكود: "$value"');
                      debugPrint(value);
                      setState(() {
                        smsSent = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      return true;
                    },
                  ),
                const SizedBox(height: 15),
                Text(S.of(context).smsHasBeenSentTo + (widget.user?.phone ?? ''), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 80),
                isLoading
                    ? const CupertinoActivityIndicator()
                    : BlockButtonWidget(
                  onPressed: () async {
                    print('🔘 === بدء عملية التحقق من الكود ===');
                    print('🔘 الكود المدخل: "$smsSent"');
                    print('🔘 طول الكود: ${smsSent.length}');
                    print('🔘 skipOTP: $skipOTP');
                    print('🔘 isLoading: $isLoading');
                    
                    setState(() => isLoading = true);

                    if (skipOTP) {
                      print('⏭️ === تجاوز OTP مفعل ===');
                      currentUser.value.updatePhoneVerification(true); // ✅ التفعيل اليدوي
                      
                      // ✅ إضافة منطق ذكي للتوجيه
                      print('🏠 بدء التوجيه بعد تجاوز OTP');
                      
                      // استدعاء callback إذا كان موجوداً
                      widget.valueChangedCallback?.call(true);
                      print('✅ تم استدعاء callback');
                      
                      // إغلاق الـ bottom sheet إذا كان مفتوحاً
                      if (Navigator.canPop(context)) {
                        print('📱 إغلاق الـ bottom sheet');
                        Navigator.pop(context);
                      } else {
                        print('⚠️ لا يمكن إغلاق الـ bottom sheet');
                      }
                      
                      // التوجيه إلى الصفحة الرئيسية بعد تأخير قصير
                      print('⏳ انتظار 500ms قبل التوجيه...');
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          print('🏠 التوجيه إلى الصفحة الرئيسية');
                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
                        } else {
                          print('❌ Widget غير mounted');
                        }
                      });
                      
                      setState(() => isLoading = false);
                      print('⏭️ === انتهت عملية تجاوز OTP ===');
                      return;
                    }

                    try {
                      print('🔐 === بدء التحقق من الكود ===');
                      print('🔐 الكود: "$smsSent"');
                      bool isVerified = await verifyOTP(smsSent);
                      print('🔐 نتيجة التحقق: $isVerified');
                      
                      if (!isVerified) {
                        print('❌ الكود غير صحيح');
                        ScaffoldMessenger.of(widget.scaffoldKey?.currentContext ?? context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating, 
                            content: Text("الكود غير صحيح، يرجى المحاولة مرة أخرى"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        print('✅ الكود صحيح - بدء التوجيه');
                        ScaffoldMessenger.of(widget.scaffoldKey?.currentContext ?? context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating, 
                            content: Text("تم التحقق من الهاتف بنجاح"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        
                        // ✅ إضافة منطق ذكي للتوجيه
                        print('🏠 بدء التوجيه بعد التحقق من OTP');
                        
                        // استدعاء callback إذا كان موجوداً
                        widget.valueChangedCallback?.call(true);
                        print('✅ تم استدعاء callback');
                        
                        // إغلاق الـ bottom sheet إذا كان مفتوحاً
                        if (Navigator.canPop(context)) {
                          print('📱 إغلاق الـ bottom sheet');
                          Navigator.pop(context);
                        } else {
                          print('⚠️ لا يمكن إغلاق الـ bottom sheet');
                        }
                        
                        // التوجيه إلى الصفحة الرئيسية بعد تأخير قصير
                        print('⏳ انتظار 500ms قبل التوجيه...');
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            print('🏠 التوجيه إلى الصفحة الرئيسية');
                            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
                          } else {
                            print('❌ Widget غير mounted');
                          }
                        });
                      }
                    } catch (e) {
                      print('❌ === خطأ في التحقق ===');
                      print('❌ نوع الخطأ: ${e.runtimeType}');
                      print('❌ رسالة الخطأ: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.fixed, 
                          content: Text("خطأ في التحقق: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    setState(() => isLoading = false);
                    print('🔘 === انتهت عملية التحقق من الكود ===');
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  text: Text(
                    S.of(context).verify.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.merge(
                      TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: config.App(context).appWidth(42)),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            ),
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
