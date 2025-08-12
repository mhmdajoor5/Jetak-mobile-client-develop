import 'dart:math';
import '../models/chatbot_message.dart';
import '../helpers/chatbot_translations.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // قائمة الأسئلة الشائعة والإجابات
  final Map<String, String> _faqResponses = {
    'كيف أطلب طعام؟': 'يمكنك طلب الطعام بسهولة:\n1. اختر المطعم المفضل لديك\n2. تصفح القائمة واختر الأطباق\n3. أضف إلى السلة\n4. اختر طريقة الدفع\n5. أكد الطلب',
    
    'ما هي طرق الدفع المتاحة؟': 'طرق الدفع المتاحة:\n• البطاقة الائتمانية\n• PayPal\n• الدفع عند الاستلام\n• المحفظة الإلكترونية',
    
    'كم تستغرق مدة التوصيل؟': 'مدة التوصيل تتراوح بين 20-45 دقيقة حسب:\n• المسافة بينك وبين المطعم\n• حالة الطقس والمرور\n• وقت الذروة',
    
    'كيف أتتبع طلبي؟': 'يمكنك تتبع طلبك من خلال:\n• صفحة التتبع المباشر\n• الإشعارات الفورية\n• تحديثات الحالة في الوقت الفعلي',
    
    'ما هي سياسة الاسترجاع؟': 'سياسة الاسترجاع:\n• يمكنك إلغاء الطلب قبل بدء التحضير\n• في حالة وجود مشكلة، اتصل بنا فوراً\n• نضمن جودة الطعام والخدمة',
    
    'كيف أتغير عنوان التوصيل؟': 'لتغيير عنوان التوصيل:\n1. اذهب إلى الإعدادات\n2. اختر "العناوين المحفوظة"\n3. أضف عنوان جديد أو عدل الموجود',
    
    'هل هناك رسوم توصيل؟': 'رسوم التوصيل:\n• مجانية للطلبات فوق 50 ريال\n• 5 ريال للطلبات أقل من 50 ريال\n• قد تختلف حسب المنطقة',
    
    'كيف أضيف مطعم مفضل؟': 'لإضافة مطعم مفضل:\n1. اذهب لصفحة المطعم\n2. اضغط على أيقونة القلب\n3. سيظهر في قائمة المفضلة',
    
    'ما هي ساعات العمل؟': 'ساعات العمل:\n• من الأحد إلى الخميس: 8 ص - 12 م\n• الجمعة والسبت: 9 ص - 1 ص\n• بعض المطاعم قد تختلف ساعاتها',
    
    'كيف أتواصل مع خدمة العملاء؟': 'للتواصل مع خدمة العملاء:\n• الهاتف: 920000000\n• البريد الإلكتروني: support@jetak.com\n• الدردشة المباشرة: متاحة 24/7',
  };

  // الأسئلة السريعة
  final List<String> _quickQuestions = [
    'كيف أطلب طعام؟',
    'ما هي طرق الدفع المتاحة؟',
    'كم تستغرق مدة التوصيل؟',
    'كيف أتتبع طلبي؟',
    'ما هي سياسة الاسترجاع؟',
    'كيف أتغير عنوان التوصيل؟',
    'هل هناك رسوم توصيل؟',
    'كيف أضيف مطعم مفضل؟',
    'ما هي ساعات العمل؟',
    'كيف أتواصل مع خدمة العملاء؟',
  ];

  // رسالة الترحيب
  String getWelcomeMessage([String languageCode = 'ar']) {
    return ChatbotTranslations.getWelcomeMessage(languageCode);
  }

  // الحصول على إجابة للرسالة
  String getResponse(String userMessage) {
    String message = userMessage.toLowerCase().trim();
    
    // البحث عن تطابق في الأسئلة الشائعة
    for (String question in _faqResponses.keys) {
      if (message.contains(question.toLowerCase()) || 
          _containsSimilarWords(message, question.toLowerCase())) {
        return _faqResponses[question]!;
      }
    }

    // البحث عن كلمات مفتاحية
    if (message.contains('طلب') || message.contains('اطلب') || message.contains('order')) {
      return _faqResponses['كيف أطلب طعام؟']!;
    }
    
    if (message.contains('دفع') || message.contains('payment') || message.contains('pay')) {
      return _faqResponses['ما هي طرق الدفع المتاحة؟']!;
    }
    
    if (message.contains('توصيل') || message.contains('delivery') || message.contains('وقت')) {
      return _faqResponses['كم تستغرق مدة التوصيل؟']!;
    }
    
    if (message.contains('تتبع') || message.contains('track') || message.contains('أين')) {
      return _faqResponses['كيف أتتبع طلبي؟']!;
    }
    
    if (message.contains('استرجاع') || message.contains('إلغاء') || message.contains('refund')) {
      return _faqResponses['ما هي سياسة الاسترجاع؟']!;
    }
    
    if (message.contains('عنوان') || message.contains('address')) {
      return _faqResponses['كيف أتغير عنوان التوصيل؟']!;
    }
    
    if (message.contains('رسوم') || message.contains('تكلفة') || message.contains('سعر')) {
      return _faqResponses['هل هناك رسوم توصيل؟']!;
    }
    
    if (message.contains('مفضل') || message.contains('favorite')) {
      return _faqResponses['كيف أضيف مطعم مفضل؟']!;
    }
    
    if (message.contains('ساعات') || message.contains('وقت') || message.contains('work')) {
      return _faqResponses['ما هي ساعات العمل؟']!;
    }
    
    if (message.contains('خدمة') || message.contains('عملاء') || message.contains('support')) {
      return _faqResponses['كيف أتواصل مع خدمة العملاء؟']!;
    }

    // إجابة افتراضية
    return 'عذراً، لم أفهم سؤالك. يمكنك اختيار أحد الأسئلة التالية أو كتابة سؤالك بطريقة أخرى:\n\n' +
           _quickQuestions.take(5).map((q) => '• $q').join('\n');
  }

  // التحقق من وجود كلمات مشابهة
  bool _containsSimilarWords(String message, String question) {
    List<String> messageWords = message.split(' ');
    List<String> questionWords = question.split(' ');
    
    int matchCount = 0;
    for (String word in messageWords) {
      if (questionWords.any((qWord) => qWord.contains(word) || word.contains(qWord))) {
        matchCount++;
      }
    }
    
    return matchCount >= 2; // تطابق جزئي
  }

  // الحصول على الأسئلة السريعة
  List<String> getQuickQuestions() {
    return _quickQuestions;
  }

  // إنشاء رسالة جديدة
  ChatbotMessage createMessage(String message, bool isUser, {String? quickReply, List<String>? quickReplies}) {
    return ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: isUser,
      timestamp: DateTime.now(),
      quickReply: quickReply,
      quickReplies: quickReplies,
    );
  }

  // الحصول على رسالة ترحيب مع أسئلة سريعة
  ChatbotMessage getWelcomeMessageWithQuickReplies([String languageCode = 'ar']) {
    return createMessage(
      getWelcomeMessage(languageCode),
      false,
      quickReplies: _quickQuestions.take(6).toList(),
    );
  }
}
