import 'dart:convert';

class NotificationModel {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> customFields;

  NotificationModel({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.customFields,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      notifiableType: json['notifiable_type'] ?? '',
      notifiableId: json['notifiable_id'] is int
          ? json['notifiable_id']
          : int.tryParse(json['notifiable_id'].toString()) ?? 0,
      data: json['data'] is String
          ? jsonDecode(json['data'])
          : (json['data'] ?? {}),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customFields: json['custom_fields'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_type': notifiableType,
      'notifiable_id': notifiableId,
      'data': jsonEncode(data),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'custom_fields': customFields,
    };
  }
} 