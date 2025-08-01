import 'dart:convert';
import '../helpers/custom_trace.dart';

class Notification {
  String id;
  String type;
  String notifiableType;
  int notifiableId;
  Map<String, dynamic> data;
  bool read;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> customFields;

  Notification({
    this.id = '',
    this.type = '',
    this.notifiableType = '',
    this.notifiableId = 0,
    this.data = const {},
    this.read = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.customFields = const [],
  }) : createdAt = createdAt ?? DateTime(0),
       updatedAt = updatedAt ?? DateTime(0);

  factory Notification.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      print('Parsing notification: $jsonMap'); // Debug log
      
      // Parse data field - it might be a string or already a Map
      Map<String, dynamic> parsedData = {};
      if (jsonMap?['data'] != null) {
        if (jsonMap!['data'] is String) {
          try {
            parsedData = json.decode(jsonMap['data']);
          } catch (e) {
            parsedData = {'raw': jsonMap['data']};
          }
        } else if (jsonMap['data'] is Map<String, dynamic>) {
          parsedData = jsonMap['data'];
        }
      }

      final notification = Notification(
        id: jsonMap?['id']?.toString() ?? '',
        type: jsonMap?['type']?.toString() ?? '',
        notifiableType: jsonMap?['notifiable_type']?.toString() ?? '',
        notifiableId: int.tryParse(jsonMap?['notifiable_id']?.toString() ?? '0') ?? 0,
        data: parsedData,
        read: jsonMap?['read_at'] != null,
        createdAt: jsonMap?['created_at'] != null 
          ? DateTime.tryParse(jsonMap!['created_at']) ?? DateTime(0) 
          : DateTime(0),
        updatedAt: jsonMap?['updated_at'] != null 
          ? DateTime.tryParse(jsonMap!['updated_at']) ?? DateTime(0) 
          : DateTime(0),
        customFields: jsonMap?['custom_fields'] is List 
          ? jsonMap!['custom_fields'] 
          : [],
      );
      
      print('Parsed notification: ${notification.id} - ${notification.type}'); // Debug log
      print('Data title: ${notification.getDataTitle()}'); // Debug log
      print('Data body: ${notification.getDataBody()}'); // Debug log
      return notification;
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error parsing notification: $e'));
      return Notification();
    }
  }

  Map<String, dynamic> markReadMap() {
    return {
      "id": id,
      "read_at": !read ? DateTime.now().toIso8601String() : null
    };
  }

  // Helper method to get order ID from notification data
  String? get orderId {
    if (data.containsKey('order_id')) {
      return data['order_id']?.toString();
    }
    return null;
  }

  // Helper method to check if notification is order-related
  bool get isOrderNotification {
    return type.contains('Order') || orderId != null;
  }

  // Helper method to get a readable notification title
  String getNotificationTitle() {
    switch (type) {
      case 'App\\Notifications\\StatusChangedOrder':
        return 'Order Status Changed';
      case 'App\\Notifications\\NewOrder':
        return 'New Order';
      default:
        return type.split('\\').last;
    }
  }

  // Helper method to get notification message
  String getNotificationMessage() {
    if (isOrderNotification && orderId != null) {
      return 'Order #$orderId has been updated';
    }
    return 'You have a new notification';
  }

  // Helper method to get title from data field
  String getDataTitle() {
    if (data.containsKey('title')) {
      return data['title']?.toString() ?? '';
    }
    return '';
  }

  // Helper method to get body from data field
  String getDataBody() {
    if (data.containsKey('body')) {
      return data['body']?.toString() ?? '';
    }
    return '';
  }

  // Helper method to get a readable notification title
  String getDisplayTitle() {
    // First try to get title from data field
    String dataTitle = getDataTitle();
    if (dataTitle.isNotEmpty) {
      return dataTitle;
    }
    
    // Fallback to type-based title
    switch (type) {
      case 'App\\Notifications\\StatusChangedOrder':
        return 'Order Status Changed';
      case 'App\\Notifications\\NewOrder':
        return 'New Order';
      case 'fcm':
        return 'Push Notification';
      default:
        return type.split('\\').last;
    }
  }

  // Helper method to get a readable notification message
  String getDisplayMessage() {
    // First try to get body from data field
    String dataBody = getDataBody();
    if (dataBody.isNotEmpty) {
      return dataBody;
    }
    
    // Fallback to raw data if parsing failed
    if (data.containsKey('raw')) {
      return data['raw']?.toString() ?? '';
    }
    
    // Fallback to default message
    if (isOrderNotification && orderId != null) {
      return 'Order #$orderId has been updated';
    }
    return 'You have a new notification';
  }

  // Helper method to get raw data for debugging
  String getRawData() {
    return data.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
