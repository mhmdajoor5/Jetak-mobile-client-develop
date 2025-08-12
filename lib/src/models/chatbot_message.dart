class ChatbotMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? quickReply;
  final List<String>? quickReplies;

  ChatbotMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.quickReply,
    this.quickReplies,
  });

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'],
      message: json['message'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      quickReply: json['quickReply'],
      quickReplies: json['quickReplies'] != null 
          ? List<String>.from(json['quickReplies']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'quickReply': quickReply,
      'quickReplies': quickReplies,
    };
  }
}
