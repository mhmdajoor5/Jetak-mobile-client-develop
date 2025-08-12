import 'package:flutter/material.dart';
import '../models/chatbot_notification.dart';
import '../helpers/chatbot_translations.dart';

class ChatbotNotificationWidget extends StatelessWidget {
  final ChatbotNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ChatbotNotificationWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getNotificationColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getNotificationBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // أيقونة الإشعار
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 12),
                
                // محتوى الإشعار
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                                                         child: Text(
                               notification.title,
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 shadows: [
                                   Shadow(
                                     offset: Offset(0, 2),
                                     blurRadius: 4,
                                     color: Colors.black.withOpacity(0.5),
                                   ),
                                 ],
                               ),
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                             ),
                          ),
                          
                          // زر الإغلاق
                          if (onDismiss != null)
                            GestureDetector(
                              onTap: onDismiss,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                                                 child: Icon(
                                   Icons.close,
                                   color: Colors.white,
                                   size: 16,
                                 ),
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                                             Text(
                         notification.message,
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 12,
                           fontWeight: FontWeight.w600,
                           shadows: [
                             Shadow(
                               offset: Offset(0, 2),
                               blurRadius: 3,
                               color: Colors.black.withOpacity(0.4),
                             ),
                           ],
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                      
                      SizedBox(height: 4),
                      
                                             Text(
                         ChatbotTranslations.getTimeText('ar', notification.timestamp),
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 10,
                           fontWeight: FontWeight.w600,
                           shadows: [
                             Shadow(
                               offset: Offset(0, 2),
                               blurRadius: 3,
                               color: Colors.black.withOpacity(0.4),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ),
                
                // مؤشر القراءة
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.info:
        return Colors.blue.shade800;
      case NotificationType.warning:
        return Colors.orange.shade800;
      case NotificationType.error:
        return Colors.red.shade800;
      case NotificationType.success:
        return Colors.green.shade800;
      case NotificationType.offer:
        return Colors.purple.shade800;
      case NotificationType.reminder:
        return Colors.teal.shade800;
    }
  }

  Color _getNotificationBorderColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.info:
        return Colors.blue.shade900;
      case NotificationType.warning:
        return Colors.orange.shade900;
      case NotificationType.error:
        return Colors.red.shade900;
      case NotificationType.success:
        return Colors.green.shade900;
      case NotificationType.offer:
        return Colors.purple.shade900;
      case NotificationType.reminder:
        return Colors.teal.shade900;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.schedule;
    }
  }
}
