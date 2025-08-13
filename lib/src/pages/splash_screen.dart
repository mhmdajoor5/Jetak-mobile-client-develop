import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:video_player/video_player.dart';
import '../controllers/home_controller.dart';

class SplashScreen extends StatefulWidget {
  final HomeController con;
  const SplashScreen({Key? key, required this.con}) : super(key: key);

  @override
  StateMVC<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends StateMVC<SplashScreen> {
  late HomeController _con;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _showFallbackImage = false;

  @override
  void initState() {
    super.initState();
    _con = widget.con;
    _initializeVideo();
    _loadData();
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎬 بدء تهيئة الفيديو...');
      _videoController = VideoPlayerController.asset('assets/img/nnnnnnnew.mp4');

      // إضافة timeout للفيديو
      await _videoController!.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ timeout في تحميل الفيديو');
          throw TimeoutException('Video loading timeout', const Duration(seconds: 5));
        },
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        print('✅ تم تهيئة الفيديو بنجاح');

        // تشغيل الفيديو في حلقة
        _videoController!.setLooping(true);
        _videoController!.play();

        print('▶️ تم تشغيل الفيديو');
      }
    } catch (e) {
      print('❌ خطأ في تهيئة الفيديو: $e');
      if (mounted) {
        setState(() {
          _showFallbackImage = true;
        });
      }
    }
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: SizedBox(
          // width: double.infinity,
          height: double.infinity,
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
      ),
    );
  }
}