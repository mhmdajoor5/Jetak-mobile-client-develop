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
      
      // Load all data
      await _con.loadAllData();
      
      // Navigate to home screen only after all data is loaded
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      }
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