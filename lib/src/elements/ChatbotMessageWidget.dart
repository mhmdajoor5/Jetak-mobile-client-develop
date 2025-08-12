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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // Handle tap if needed
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main content area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Message text - centered
                    Text(
                      message.message,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF272727),
                        height: 1.3,
                      ),
                    ),
                    
                    // Quick replies if available and not from user
                    if (message.quickReplies != null && !message.isUser && message.quickReplies!.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: message.quickReplies!.map((reply) {
                            return _buildQuickReplyButton(context, reply);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplyButton(BuildContext context, String reply) {
    return GestureDetector(
      onTap: () => onQuickReplyTap?.call(reply),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            width: 1,
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
            color: Color(0xFF272727),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
