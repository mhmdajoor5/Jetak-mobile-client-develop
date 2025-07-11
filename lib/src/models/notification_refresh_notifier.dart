import 'package:flutter/material.dart';

class NotificationRefreshNotifier {
  static final ValueNotifier<bool> notifier = ValueNotifier(false);

  static void trigger() {
    notifier.value = !notifier.value; // Toggle to notify listeners
  }
} 