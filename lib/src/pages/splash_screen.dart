import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../repository/settings_repository.dart' as settingRepo;

class SplashScreen extends StatefulWidget {
  final HomeController con;
  const SplashScreen({Key? key, required this.con}) : super(key: key);

  @override
  StateMVC<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends StateMVC<SplashScreen> {
  late HomeController _con;

  @override
  void initState() {
    super.initState();
    _con = widget.con;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // التحقق من حالة التطبيق أولاً
      await _checkAppStatus();
      
      // Reset loading state to ensure fresh data load
      _con.resetDataLoading();
      
      // Load all data with timeout to prevent hanging
      await _con.loadAllData().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('Data loading timed out - navigating anyway');
          throw TimeoutException('Data loading timed out', const Duration(seconds: 8));
        },
      );
      
      // Navigate to home screen only after all data is loaded
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
      }
    } catch (e) {
      print('Error loading data: $e');
      // Always navigate even if there's an error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
      }
    }
  }

  Future<void> _checkAppStatus() async {
    try {
      // تحميل الإعدادات من السيرفر
      await settingRepo.initSettings();
      
      // التحقق من حالة التطبيق
      if (!settingRepo.setting.value.appStatus) {
        // التطبيق معطل، الانتقال لصفحة الصيانة
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/Maintenance',
            arguments: settingRepo.setting.value.maintenanceMessage.isNotEmpty 
                ? settingRepo.setting.value.maintenanceMessage 
                : S.of(context).app_maintenance_message,
          );
        }
        return;
      }
    } catch (e) {
      print('Error checking app status: $e');
      // في حالة الخطأ، نتابع التطبيق كالمعتاد
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Stack(
        children: [
          // Background animated GIF
          SizedBox.expand(
            child: Image.asset(
              'assets/img/new.gif',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}