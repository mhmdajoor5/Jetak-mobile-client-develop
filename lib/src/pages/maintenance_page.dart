import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import '../helpers/app_colors.dart';
import '../repository/settings_repository.dart' as settingRepo;

class MaintenancePage extends StatefulWidget {
  final String message;
  
  const MaintenancePage({Key? key, required this.message}) : super(key: key);

  @override
  _MaintenancePageState createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // منع الخروج من التطبيق
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  Future<void> _checkAppStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // إعادة تحميل الإعدادات من السيرفر
      await settingRepo.initSettings();
      
      // التحقق من حالة التطبيق
      if (settingRepo.setting.value.appStatus) {
        // التطبيق متاح مرة أخرى، الانتقال للصفحة الرئيسية
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/Splash');
        }
      } else {
        // التطبيق لا يزال معطلاً
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).app_still_unavailable),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).server_connection_error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // منع العودة للخلف
      child: Scaffold(
        backgroundColor: AppColors.color9D9FA4,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الصيانة
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_circle_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // عنوان الصفحة
                Text(
                  S.of(context).app_maintenance_title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // رسالة الصيانة
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // زر إعادة المحاولة
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkAppStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.color9D9FA4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: _isChecking
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.color9D9FA4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(S.of(context).checking_status),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh),
                              const SizedBox(width: 8),
                              Text(
                                S.of(context).retry_button,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // معلومات إضافية
                Text(
                  S.of(context).app_will_be_back_soon,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 