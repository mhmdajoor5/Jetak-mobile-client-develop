import 'dart:async';
import '../models/chatbot_notification.dart';
import '../helpers/chatbot_translations.dart';

class ChatbotNotificationService {
  static final ChatbotNotificationService _instance = ChatbotNotificationService._internal();
  factory ChatbotNotificationService() => _instance;
  ChatbotNotificationService._internal();

  final List<ChatbotNotification> _notifications = [];
  final StreamController<List<ChatbotNotification>> _notificationsController = 
      StreamController<List<ChatbotNotification>>.broadcast();

  Stream<List<ChatbotNotification>> get notificationsStream => _notificationsController.stream;
  List<ChatbotNotification> get notifications => List.unmodifiable(_notifications);

  // عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // إضافة إشعار جديد
  void addNotification(ChatbotNotification notification) {
    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
  }

  // تحديث حالة القراءة
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
    }
  }

  // تحديث جميع الإشعارات كمقروءة
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notificationsController.add(_notifications);
  }

  // حذف إشعار
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
  }

  // حذف جميع الإشعارات
  void clearAllNotifications() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  // إنشاء إشعار ترحيبي
  ChatbotNotification createWelcomeNotification([String languageCode = 'ar']) {
    return ChatbotNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ChatbotTranslations.getText('welcome_notification_title', languageCode),
      message: ChatbotTranslations.getText('welcome_notification_message', languageCode),
      timestamp: DateTime.now(),
      type: NotificationType.info,
    );
  }

  // إنشاء إشعار عرض خاص
  ChatbotNotification createOfferNotification([String languageCode = 'ar']) {
    return ChatbotNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ChatbotTranslations.getText('offer_notification_title', languageCode),
      message: ChatbotTranslations.getText('offer_notification_message', languageCode),
      timestamp: DateTime.now(),
      type: NotificationType.offer,
    );
  }

  // إنشاء إشعار تذكير
  ChatbotNotification createReminderNotification([String languageCode = 'ar']) {
    return ChatbotNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ChatbotTranslations.getText('reminder_notification_title', languageCode),
      message: ChatbotTranslations.getText('reminder_notification_message', languageCode),
      timestamp: DateTime.now(),
      type: NotificationType.reminder,
    );
  }

  // إنشاء إشعار مخصص
  ChatbotNotification createCustomNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    return ChatbotNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  // إضافة إشعارات تجريبية
  void addDemoNotifications([String languageCode = 'ar']) {
    // إشعار ترحيبي
    addNotification(createWelcomeNotification(languageCode));
    
    // إشعار عرض
    Future.delayed(Duration(seconds: 2), () {
      addNotification(createOfferNotification(languageCode));
    });
    
    // إشعار تذكير
    Future.delayed(Duration(seconds: 5), () {
      addNotification(createReminderNotification(languageCode));
    });
  }

  // تنظيف الإشعارات القديمة (أكثر من 7 أيام)
  void cleanupOldNotifications() {
    final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    _notifications.removeWhere((n) => n.timestamp.isBefore(sevenDaysAgo));
    _notificationsController.add(_notifications);
  }

  void dispose() {
    _notificationsController.close();
  }
}
