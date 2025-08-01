import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:async';

import '../../generated/l10n.dart';
import '../models/notification.dart' as model;
import '../repository/notification_repository.dart';
import '../repository/user_repository.dart';

class NotificationController extends ControllerMVC {
  List<model.Notification> notifications = <model.Notification>[];
  int unReadNotificationsCount = 0;
  bool isLoading = false;
  late GlobalKey<ScaffoldState> scaffoldKey;
  Timer? _refreshTimer;

  NotificationController() {
    this.scaffoldKey = GlobalKey<ScaffoldState>();
    listenForNotifications();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      refreshNotifications(showMessage: false);
    });
  }

  void listenForNotifications({String? message}) async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    try {
    final Stream<model.Notification> stream = await getNotifications();
      stream.listen((model.Notification notification) {
        setState(() {
          // Avoid duplicates
          if (!notifications.any((n) => n.id == notification.id)) {
            notifications.add(notification);
          }
        });
      },
      //     onError: (error) {
      //   print('Error listening for notifications: $error');
      //   _showSnackBar(S.of(state!.context).verify_your_internet_connection);
      // },
          onDone: () {
        setState(() {
          isLoading = false;
        });
        _updateUnreadCount();
        if (message != null) {
          _showSnackBar(message);
        }
      });
    }
    catch (e) {
      setState(() {
        isLoading = false;
      });
      //_showSnackBar(S.of(state!.context).verify_your_internet_connection);
    }
  }

  Future<void> loadNotificationsList() async {
    if (isLoading) return;
    
    // Check if user is logged in
    if (currentUser.value.apiToken == null) {
      print('User not logged in, skipping notifications load');
      setState(() {
        isLoading = false;
        notifications = [];
      });
      return;
    }
    
    setState(() {
      isLoading = true;
    });

    try {
      print('Loading notifications list...'); // Debug log
      final List<model.Notification> fetchedNotifications = await getNotificationsList();
      print('Fetched ${fetchedNotifications.length} notifications'); // Debug log
      
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
      _updateUnreadCount();
    } catch (e) {
      print('Error loading notifications: $e'); // Debug log
      setState(() {
        isLoading = false;
      });
      if (state?.context != null) {
        _showSnackBar('Error loading notifications: $e');
      }
    }
  }

  Future<void> refreshNotifications({bool showMessage = true}) async {
    notifications.clear();
    await loadNotificationsList();
    if (showMessage) {
      _showSnackBar(S.of(state!.context).notifications_refreshed_successfuly);
    }
  }

  void _updateUnreadCount() async {
    try {
      final int count = await getUnreadNotificationsCount();
      setState(() {
        unReadNotificationsCount = count;
      });
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  void doMarkAsReadNotifications(model.Notification notification) async {
    try {
      final updatedNotification = await markAsReadNotifications(notification);
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = updatedNotification;
          if (!updatedNotification.read && notification.read) {
            unReadNotificationsCount++;
          } else if (updatedNotification.read && !notification.read) {
            unReadNotificationsCount--;
          }
        }
      });
      _showSnackBar(S.of(state!.context).thisNotificationHasMarkedAsRead);
    } catch (e) {
      _showSnackBar('Error marking notification as read');
    }
  }

  void doMarkAsUnReadNotifications(model.Notification notification) async {
    try {
      // Create a copy with read = false to send to API
      final unreadNotification = model.Notification(
        id: notification.id,
        type: notification.type,
        notifiableType: notification.notifiableType,
        notifiableId: notification.notifiableId,
        data: notification.data,
        read: false,
        createdAt: notification.createdAt,
        updatedAt: notification.updatedAt,
        customFields: notification.customFields,
      );
      
      final updatedNotification = await markAsReadNotifications(unreadNotification);
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = updatedNotification;
          if (!updatedNotification.read && notification.read) {
            unReadNotificationsCount++;
          } else if (updatedNotification.read && !notification.read) {
            unReadNotificationsCount--;
          }
        }
      });
      _showSnackBar(S.of(state!.context).thisNotificationHasMarkedAsUnread);
    } catch (e) {
      _showSnackBar('Error marking notification as unread');
    }
  }

  void doRemoveNotification(model.Notification notification) async {
    try {
      await removeNotification(notification);
      setState(() {
        if (!notification.read) {
          unReadNotificationsCount--;
        }
        notifications.removeWhere((n) => n.id == notification.id);
      });
      _showSnackBar(S.of(state!.context).notificationWasRemoved);
    } catch (e) {
      _showSnackBar('Error removing notification');
    }
  }

  void doMarkAllAsRead() async {
    try {
      final success = await markAllAsRead();
      if (success) {
        setState(() {
          notifications = notifications.map((n) => model.Notification(
            id: n.id,
            type: n.type,
            notifiableType: n.notifiableType,
            notifiableId: n.notifiableId,
            data: n.data,
            read: true,
            createdAt: n.createdAt,
            updatedAt: n.updatedAt,
            customFields: n.customFields,
          )).toList();
          unReadNotificationsCount = 0;
        });
        _showSnackBar('All notifications marked as read');
      }
    } catch (e) {
      _showSnackBar('Error marking all notifications as read');
    }
  }

  void handleNotificationTap(model.Notification notification) {
    // Mark as read if not already read
    if (!notification.read) {
      doMarkAsReadNotifications(notification);
    }

    // Navigate based on notification type
    if (notification.isOrderNotification) {
      // Navigate to orders page
      Navigator.of(state!.context).pushNamed('/Pages', arguments: 3);
    } else if (notification.type.contains('Message')) {
      // Navigate to messages page
      Navigator.of(state!.context).pushNamed('/Pages', arguments: 4);
    }
  }

  void _showSnackBar(String message) {
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // Helper methods for UI
  List<model.Notification> get unreadNotifications {
    return notifications.where((n) => !n.read).toList();
  }

  List<model.Notification> get readNotifications {
    return notifications.where((n) => n.read).toList();
  }

  bool get hasUnreadNotifications {
    return unReadNotificationsCount > 0;
  }

  bool get hasNotifications {
    return notifications.isNotEmpty;
  }
}
