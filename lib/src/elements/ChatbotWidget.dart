import 'package:flutter/material.dart';
import '../models/chatbot_message.dart';
import '../services/chatbot_service.dart';
import '../helpers/chatbot_translations.dart';
import 'ChatbotMessageWidget.dart';

class ChatbotWidget extends StatefulWidget {
  final VoidCallback? onClose;

  const ChatbotWidget({Key? key, this.onClose}) : super(key: key);

  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> with TickerProviderStateMixin {
  final List<ChatbotMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // إضافة رسالة الترحيب
    _addMessage(_chatbotService.getWelcomeMessageWithQuickReplies('ar'));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(ChatbotMessage message) {
    setState(() {
      _messages.add(message);
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    _addMessage(_chatbotService.createMessage(message, true));
    _textController.clear();

    // محاكاة الكتابة
    setState(() {
      _isTyping = true;
    });

    // إضافة إجابة الشات بوت بعد تأخير قصير
    Future.delayed(Duration(milliseconds: 1000), () {
      String response = _chatbotService.getResponse(message);
      _addMessage(_chatbotService.createMessage(response, false));
      
      setState(() {
        _isTyping = false;
      });
    });
  }

  void _sendQuickReply(String reply) {
    _sendMessage(reply);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // نافذة الشات
          if (_isExpanded)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 320,
                      height: 450,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                                                     // رأس الشات
                           Container(
                             padding: EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Theme.of(context).primaryColor,
                               borderRadius: BorderRadius.only(
                                 topLeft: Radius.circular(20),
                                 topRight: Radius.circular(20),
                               ),
                             ),
                             child: Column(
                               children: [
                                 Row(
                                   children: [
                                     Container(
                                       width: 40,
                                       height: 40,
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         shape: BoxShape.circle,
                                       ),
                                       child: Icon(
                                         Icons.smart_toy,
                                         color: Theme.of(context).primaryColor,
                                         size: 24,
                                       ),
                                     ),
                                     SizedBox(width: 12),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             ChatbotTranslations.getSmartAssistantText('ar'),
                                                                                            style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 16,
                                                 fontWeight: FontWeight.bold,
                                                 shadows: [
                                                   Shadow(
                                                     offset: Offset(0, 2),
                                                     blurRadius: 4,
                                                     color: Colors.black.withOpacity(0.6),
                                                   ),
                                                 ],
                                               ),
                                           ),
                                           Text(
                                             ChatbotTranslations.getOnlineNowText('ar'),
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 12,
                                               fontWeight: FontWeight.w600,
                                               shadows: [
                                                 Shadow(
                                                   offset: Offset(0, 2),
                                                   blurRadius: 3,
                                                   color: Colors.black.withOpacity(0.5),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                     IconButton(
                                       onPressed: _toggleExpanded,
                                                                          icon: Icon(
                                     Icons.close,
                                     color: Colors.white,
                                     size: 24,
                                   ),
                                     ),
                                   ],
                                 ),
                                 
                                 
                               ],
                             ),
                           ),
                          
                                                     // منطقة المحتوى
                           Expanded(
                             child: _buildChatTab(),
                           ),
                          
                                                     // منطقة الإدخال
                             Container(
                               padding: EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                 color: Colors.grey[50],
                                 borderRadius: BorderRadius.only(
                                   bottomLeft: Radius.circular(20),
                                   bottomRight: Radius.circular(20),
                                 ),
                               ),
                               child: Row(
                                 children: [
                                   Expanded(
                                                                            child: TextField(
                                         controller: _textController,
                                         style: TextStyle(
                                           color: Colors.black,
                                           fontSize: 14,
                                           fontWeight: FontWeight.w500,
                                         ),
                                       decoration: InputDecoration(
                                         hintText: ChatbotTranslations.getTypeMessageText('ar'),
                                     hintStyle: TextStyle(
                                       color: Colors.black54,
                                       fontSize: 14,
                                       fontWeight: FontWeight.w400,
                                     ),
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(25),
                                           borderSide: BorderSide.none,
                                         ),
                                         filled: true,
                                         fillColor: Colors.white,
                                         contentPadding: EdgeInsets.symmetric(
                                           horizontal: 16,
                                           vertical: 12,
                                         ),
                                       ),
                                       onSubmitted: _sendMessage,
                                     ),
                                   ),
                                   SizedBox(width: 8),
                                   Container(
                                     decoration: BoxDecoration(
                                       color: Theme.of(context).primaryColor,
                                       shape: BoxShape.circle,
                                     ),
                                     child: IconButton(
                                       onPressed: () => _sendMessage(_textController.text),
                                       icon: Icon(
                                         Icons.send,
                                         color: Colors.white,
                                         size: 20,
                                       ),
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
              },
            ),
          
          SizedBox(height: 16),
          
                    // زر الشات
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isExpanded ? Icons.close : Icons.chat_bubble,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildChatTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
            return _buildTypingIndicator();
          }
          
          ChatbotMessage message = _messages[index];
          return ChatbotMessageWidget(
            message: message,
            onQuickReplyTap: (String reply) {
              _sendQuickReply(reply);
            },
          );
        },
      ),
    );
  }

  

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(
              0.3 + (0.7 * ((DateTime.now().millisecondsSinceEpoch / 500 + index) % 3) / 3),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
