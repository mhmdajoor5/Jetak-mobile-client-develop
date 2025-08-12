class ChatbotTranslations {
  static const Map<String, Map<String, String>> _translations = {
         'ar': {
       'welcome_message': 'مرحباً! 👋 أنا المساعد الذكي لتطبيق جتاك. كيف يمكنني مساعدتك اليوم؟',
       'typing': 'يكتب...',
       'type_message': 'اكتب رسالتك هنا...',
       'smart_assistant': 'المساعد الذكي',
       'online_now': 'متصل الآن',
       'now': 'الآن',
       'minutes_ago': 'منذ {minutes} دقيقة',
       'hours_ago': 'منذ {hours} ساعة',
       'how_to_order': 'كيف أطلب طعام؟',
       'payment_methods': 'ما هي طرق الدفع المتاحة؟',
       'delivery_time': 'كم تستغرق مدة التوصيل؟',
       'track_order': 'كيف أتتبع طلبي؟',
       'return_policy': 'ما هي سياسة الاسترجاع؟',
       'change_address': 'كيف أتغير عنوان التوصيل؟',
       'delivery_fees': 'هل هناك رسوم توصيل؟',
       'add_favorite': 'كيف أضيف مطعم مفضل؟',
       'working_hours': 'ما هي ساعات العمل؟',
       'customer_service': 'كيف أتواصل مع خدمة العملاء؟',
       'sorry_not_understood': 'عذراً، لم أفهم سؤالك. يمكنك اختيار أحد الأسئلة التالية أو كتابة سؤالك بطريقة أخرى:',
       'welcome_notification_title': 'مرحباً بك في جتاك! 🎉',
       'welcome_notification_message': 'نحن هنا لمساعدتك في طلب الطعام بسهولة',
       'offer_notification_title': 'عرض خاص! 🎁',
       'offer_notification_message': 'احصل على خصم 20% على طلبك الأول',
       'reminder_notification_title': 'تذكير! ⏰',
       'reminder_notification_message': 'لا تنسى طلب وجبتك المفضلة',
       'new_message': 'رسالة جديدة',
       'unread_messages': '{count} رسائل غير مقروءة',
     },
    'en': {
      'welcome_message': 'Hello! 👋 I\'m the smart assistant for Jetak app. How can I help you today?',
      'typing': 'Typing...',
      'type_message': 'Type your message here...',
      'smart_assistant': 'Smart Assistant',
      'online_now': 'Online now',
      'now': 'Now',
      'minutes_ago': '{minutes} minutes ago',
      'hours_ago': '{hours} hours ago',
      'how_to_order': 'How do I order food?',
      'payment_methods': 'What payment methods are available?',
      'delivery_time': 'How long does delivery take?',
      'track_order': 'How do I track my order?',
      'return_policy': 'What is the return policy?',
      'change_address': 'How do I change delivery address?',
      'delivery_fees': 'Are there delivery fees?',
      'add_favorite': 'How do I add a favorite restaurant?',
      'working_hours': 'What are the working hours?',
      'customer_service': 'How do I contact customer service?',
      'sorry_not_understood': 'Sorry, I didn\'t understand your question. You can choose one of the following questions or rephrase your question:',
    },
  };

  static String getText(String key, String languageCode, [Map<String, String>? parameters]) {
    final translations = _translations[languageCode] ?? _translations['en']!;
    String text = translations[key] ?? key;
    
    if (parameters != null) {
      parameters.forEach((param, value) {
        text = text.replaceAll('{$param}', value);
      });
    }
    
    return text;
  }

  static String getWelcomeMessage(String languageCode) {
    return getText('welcome_message', languageCode);
  }

  static String getTypingText(String languageCode) {
    return getText('typing', languageCode);
  }

  static String getTypeMessageText(String languageCode) {
    return getText('type_message', languageCode);
  }

  static String getSmartAssistantText(String languageCode) {
    return getText('smart_assistant', languageCode);
  }

  static String getOnlineNowText(String languageCode) {
    return getText('online_now', languageCode);
  }

  static String getTimeText(String languageCode, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return getText('now', languageCode);
    } else if (difference.inMinutes < 60) {
      return getText('minutes_ago', languageCode, {'minutes': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return getText('hours_ago', languageCode, {'hours': difference.inHours.toString()});
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
