import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification_model.dart';
import '../models/notification_refresh_notifier.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _futureNotifications;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureNotifications = fetchNotifications();
    NotificationRefreshNotifier.notifier.addListener(_onNotificationRefresh);
  }

  void _onNotificationRefresh() {
    setState(() {
      _futureNotifications = fetchNotifications();
    });
  }

  @override
  void dispose() {
    NotificationRefreshNotifier.notifier.removeListener(_onNotificationRefresh);
    super.dispose();
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final String? apiToken =
        "fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv";
    if (apiToken == null || apiToken.isEmpty) {
      throw Exception('User is not logged in or apiToken is missing');
    }
    final String url =
        'https://carrytechnologies.co/api/notifications?api_token=$apiToken';
    final response = await http.get(Uri.parse(url));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromARGB(255, 120, 13, 96);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 25,
            color: primaryColor,
          ),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureNotifications = fetchNotifications();
          });
        },
        child: FutureBuilder<List<NotificationModel>>(
          future: _futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final notifications = snapshot.data!;
              if (notifications.isEmpty) {
                return Center(child: Text('No notifications available'));
              }

              int unreadCount = notifications.where((n) => !(false)).length;

              return ListView(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: primaryColor,
                            size: 30,
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        unreadCount > 0
                            ? '$unreadCount unread • swipe to refresh'
                            : 'Swipe down to refresh',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: LinearProgressIndicator(
                        color: primaryColor,
                        backgroundColor: primaryColor.withOpacity(0.2),
                      ),
                    ),
                  // Notifications list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: primaryColor,
                            ),
                            title: Text(
                              notification.type.split(RegExp(r'[\\/]+')).last,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(notification.data.toString()),
                                SizedBox(height: 5),
                                Text(
                                  'Date: ${notification.createdAt}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              );
            } else {
              return Center(child: Text('No notifications'));
            }
          },
        ),
      ),
    );
  }
} 