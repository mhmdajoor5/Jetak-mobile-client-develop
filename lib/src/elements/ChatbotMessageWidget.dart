import 'package:flutter/material.dart';
import '../models/chatbot_message.dart';
import '../helpers/chatbot_translations.dart';

class ChatbotMessageWidget extends StatelessWidget {
  final ChatbotMessage message;
  final Function(String)? onQuickReplyTap;

  const ChatbotMessageWidget({
    Key? key,
    required this.message,
    this.onQuickReplyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(context, false),
            SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             Text(
                         message.message,
                         style: TextStyle(
                           color: message.isUser ? Colors.white : Colors.black,
                           fontSize: 14,
                           height: 1.4,
                           fontWeight: message.isUser ? FontWeight.w500 : FontWeight.w600,
                         ),
                         textDirection: TextDirection.rtl,
                       ),
                      
                      // الأسئلة السريعة
                      if (message.quickReplies != null && !message.isUser)
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.quickReplies!.map((reply) {
                              return _buildQuickReplyButton(context, reply);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // وقت الرسالة
                Container(
                  margin: EdgeInsets.only(top: 4, right: 4, left: 4),
                                     child: Text(
                     _formatTime(message.timestamp),
                     style: TextStyle(
                       color: Colors.black,
                       fontSize: 11,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                ),
              ],
            ),
          ),
          
          if (message.isUser) ...[
            SizedBox(width: 8),
            _buildAvatar(context, true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser 
            ? Colors.grey[300] 
            : Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.grey[600] : Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildQuickReplyButton(BuildContext context, String reply) {
    return GestureDetector(
      onTap: () => onQuickReplyTap?.call(reply),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
                                         border: Border.all(
                                 color: Colors.black.withOpacity(0.3),
                                 width: 2,
                               ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
                                       child: Text(
                                 reply,
                                 style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 12,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 textDirection: TextDirection.rtl,
                               ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return ChatbotTranslations.getTimeText('ar', timestamp);
  }
}
