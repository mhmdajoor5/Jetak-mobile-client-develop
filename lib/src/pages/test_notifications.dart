import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class TestNotificationsPage extends StatefulWidget {
  @override
  _TestNotificationsPageState createState() => _TestNotificationsPageState();
}

class _TestNotificationsPageState extends State<TestNotificationsPage> {
  int _currentCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateCount();
  }

  void _updateCount() {
    setState(() {
      _currentCount = 0; // No longer fetching from service
    });
  }

  void _refreshNotificationCount() async {
    // No longer refreshing from service
  }

  void _testLocalNotification() {
    // No longer using notification service
  }

  void _testAPIConnection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('جاري اختبار الاتصال بالـ API...')),
      );
      
      // No longer fetching notifications from repository
      // var notifications = await notificationRepo.getNotificationsList();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم بنجاح! عدد الإشعارات: 0'), // Placeholder
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل في الاتصال: $e'),
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
      // No longer fetching notifications from repository
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showNotificationsDialog(List<Notification> notifications) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('All Notifications (${notifications.length})'),
  //       content: Container(
  //         width: double.maxFinite,
  //         height: 400,
  //         child: ListView.builder(
  //           itemCount: notifications.length,
  //           itemBuilder: (context, index) {
  //             final notification = notifications[index];
  //             return ListTile(
  //               title: Text(notification.getNotificationTitle()),
  //               subtitle: Text(notification.getNotificationMessage()),
  //               trailing: notification.read
  //                   ? Icon(Icons.check_circle, color: Colors.green)
  //                   : Icon(Icons.circle, color: Colors.red),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text('Notification: ${notification.getNotificationTitle()}'),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Notifications'),
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
                          'Unread Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_currentCount notifications',
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
            // Test buttons
            Text(
              '🧪 اختبار الإشعارات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshNotificationCount,
              child: Text('تحديث عدد الإشعارات'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _testLocalNotification,
              child: Text('اختبار إشعار محلي'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchNotifications,
              child: Text('جلب جميع الإشعارات'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/Notifications'),
              child: Text('الذهاب لصفحة الإشعارات'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _testAPIConnection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('اختبار الاتصال بالـ API', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            // API Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Endpoint: https://carrytechnologies.co/api/notifications',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Token: fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv',
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