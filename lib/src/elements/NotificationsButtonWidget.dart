import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repository/notification_repository.dart';

class NotificationsButtonWidget extends StatefulWidget {
  final int? staticNotificationCount;
  final VoidCallback? onTap;

  const NotificationsButtonWidget({
    Key? key,
    this.staticNotificationCount,
    this.onTap,
  }) : super(key: key);

  @override
  _NotificationsButtonWidgetState createState() => _NotificationsButtonWidgetState();
}

class _NotificationsButtonWidgetState extends State<NotificationsButtonWidget> {
  int _notificationCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.staticNotificationCount != null) {
      _notificationCount = widget.staticNotificationCount!;
    } else {
      _fetchNotificationCount();
    }
  }

  Future<void> _fetchNotificationCount() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final count = await getUnreadNotificationsCount();
      if (mounted) {
        setState(() {
          _notificationCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notificationCount = 0;
          _isLoading = false;
        });
      }
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.of(context).pushNamed('/Notifications').then((_) {
        // Refresh notification count when returning from notifications page
        if (widget.staticNotificationCount == null) {
          _fetchNotificationCount();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/img/notification-bing.svg',
              height: 27,
              width: 27,
            ),
            if (_notificationCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _notificationCount > 99 ? '99+' : _notificationCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
