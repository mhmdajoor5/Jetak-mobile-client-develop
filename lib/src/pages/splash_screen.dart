import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/home_controller.dart';

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
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      }
    } catch (e) {
      print('Error loading data: $e');
      // Always navigate even if there's an error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Color(0xFF26386A), // نفس لون native splash للانتقال السلس
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background GIF متحرك ملء الشاشة
            Positioned.fill(
              child: Image.asset(
                'assets/img/new.gif',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            // شعار صغير في الأسفل (اختياري)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'جيتك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}