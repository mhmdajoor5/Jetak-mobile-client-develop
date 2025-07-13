import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/notification.dart' as model;
import '../repository/notification_repository.dart';
import '../helpers/custom_trace.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification count stream
  final StreamController<int> _notificationCountController = StreamController<int>.broadcast();
  Stream<int> get notificationCountStream => _notificationCountController.stream;

  // Notification updates stream
  final StreamController<model.Notification> _notificationUpdateController = StreamController<model.Notification>.broadcast();
  Stream<model.Notification> get notificationUpdateStream => _notificationUpdateController.stream;

  // Current notification count
  int _currentNotificationCount = 0;
  int get currentNotificationCount => _currentNotificationCount;

  // Initialization
  Future<void> initialize() async {
    try {
      await _updateNotificationCount();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error initializing NotificationService: $e'));
    }
  }

  // Update notification count
  Future<void> _updateNotificationCount() async {
    try {
      final int count = await   getUnreadNotificationsCount();
      _currentNotificationCount = count;
      // _notificationCounءذtController.add(count);
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error updating notification count: $e'));
    }
  }

  // Refresh notification count
  Future<void> refreshNotificationCount() async {
    await _updateNotificationCount();
  }

  // Show simple notification (using Firebase only for now)
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // For now, just print the notification
      print('Local Notification: $title - $body');
      // In the future, we can add flutter_local_notifications here
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error showing local notification: $e'));
    }
  }

  // Handle Firebase message
  Future<void> handleFirebaseMessage(RemoteMessage message) async {
    try {
      final String title = message.notification?.title ?? 'New Notification';
      final String body = message.notification?.body ?? 'You have a new notification';
      final Map<String, dynamic> data = message.data;

      // Show simple notification (no local notifications for now)
      await showLocalNotification(
        id: message.hashCode,
        title: title,
        body: body,
        payload: data.toString(),
      );

      // Update notification count
      await _updateNotificationCount();

      // Broadcast notification update
      _notificationUpdateController.add(model.Notification(
        id: message.messageId ?? '',
        type: data['type'] ?? 'Unknown',
        notifiableType: data['notifiable_type'] ?? '',
        notifiableId: int.tryParse(data['notifiable_id']?.toString() ?? '0') ?? 0,
        data: data,
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customFields: [],
      ));
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error handling Firebase message: $e'));
    }
  }

  // Mark notification as read
  Future<void> markAsRead(model.Notification notification) async {
    try {
      await markAsReadNotifications(notification);
      await _updateNotificationCount();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error marking notification as read: $e'));
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      await markAllAsRead(); // Call repository function
      await _updateNotificationCount();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error marking all notifications as read: $e'));
    }
  }

  // Remove notification
  Future<void> removeNotificationById(model.Notification notification) async {
    try {
      await removeNotification(notification); // Call repository function
      await _updateNotificationCount();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error removing notification: $e'));
    }
  }

  // Get notification icon based on type
  IconData getNotificationIcon(String type) {
    if (type.contains('Order')) {
      return Icons.shopping_bag;
    } else if (type.contains('Message')) {
      return Icons.message;
    } else if (type.contains('Payment')) {
      return Icons.payment;
    } else if (type.contains('Delivery')) {
      return Icons.local_shipping;
    } else {
      return Icons.notifications;
    }
  }

  // Get notification color based on type
  Color getNotificationColor(String type) {
    if (type.contains('Order')) {
      return Colors.orange;
    } else if (type.contains('Message')) {
      return Colors.blue;
    } else if (type.contains('Payment')) {
      return Colors.green;
    } else if (type.contains('Delivery')) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  // Dispose
  void dispose() {
    _notificationCountController.close();
    _notificationUpdateController.close();
  }
} 