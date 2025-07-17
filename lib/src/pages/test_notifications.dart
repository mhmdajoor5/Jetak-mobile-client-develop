import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../services/notification_service.dart';
import '../repository/notification_repository.dart' as notificationRepo;

class TestNotificationsPage extends StatefulWidget {
  @override
  _TestNotificationsPageState createState() => _TestNotificationsPageState();
}

class _TestNotificationsPageState extends State<TestNotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  int _currentCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateCount();
  }

  void _updateCount() {
    setState(() {
      _currentCount = _notificationService.currentNotificationCount;
    });
  }

  void _refreshNotificationCount() async {
    await _notificationService.refreshNotificationCount();
    _updateCount();
  }

  void _testLocalNotification() {
    _notificationService.showLocalNotification(
      id: 1,
      title: S.of(context).testNotification,
      body: S.of(context).testNotificationBody,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).testNotificationSent)),
    );
  }

  void _testAPIConnection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).testingApiConnection)),
      );

      var notifications = await notificationRepo.getNotificationsList();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).apiConnectionSuccess(notifications.length)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).apiConnectionFailed(e.toString())),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await notificationRepo.getNotificationsList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorFetchingNotifications(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).testNotifications),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification count display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/img/notification-bing.svg',
                          height: 40,
                          width: 40,
                        ),
                        if (_currentCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                _currentCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).unreadNotifications,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentCount} ${S.of(context).notifications}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (_isLoading) CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              S.of(context).notificationsTestTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _refreshNotificationCount,
              child: Text(S.of(context).refreshNotificationCount),
            ),
            SizedBox(height: 12),

            ElevatedButton(
              onPressed: _testLocalNotification,
              child: Text(S.of(context).testLocalNotification),
            ),
            SizedBox(height: 12),

            ElevatedButton(
              onPressed: _fetchNotifications,
              child: Text(S.of(context).fetchAllNotifications),
            ),
            SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/Notifications'),
              child: Text(S.of(context).goToNotificationsPage),
            ),
            SizedBox(height: 12),

            ElevatedButton(
              onPressed: _testAPIConnection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                S.of(context).testApiConnection,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).apiInfoTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      S.of(context).apiEndpoint,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      S.of(context).apiToken,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
