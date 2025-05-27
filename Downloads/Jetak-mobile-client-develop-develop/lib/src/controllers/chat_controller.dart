import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/chat.dart';
import '../models/conversation.dart';
import '../repository/chat_repository.dart';
import '../repository/notification_repository.dart';
import '../repository/user_repository.dart';

class ChatController extends ControllerMVC {
  Conversation? conversation;
  late final ChatRepository _chatRepository;
  Stream<QuerySnapshot>? conversations;
  Stream<QuerySnapshot>? chats;
  late final GlobalKey<ScaffoldState> scaffoldKey;

  ChatController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    _chatRepository = ChatRepository();
  }

  void signIn() {
    // _chatRepository.signInWithToken(currentUser.value.apiToken);
  }

  void createConversation(Conversation _conversation) async {
    _conversation.users.insert(0, currentUser.value);
    _conversation.lastMessageTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    _conversation.readByUsers = [currentUser.value.id!];
    setState(() {
      conversation = _conversation;
    });
    if (conversation != null) {
      await _chatRepository.createConversation(conversation!);
      listenForChats(conversation!);
    }
  }

  void listenForConversations() async {
    final snapshot = await _chatRepository.getUserConversations(currentUser.value.id!);
    setState(() {
      conversations = snapshot;
    });
  }

  void listenForChats(Conversation _conversation) async {
    if (!_conversation.readByUsers.contains(currentUser.value.id)) {
      _conversation.readByUsers.add(currentUser.value.id!);
    }
    final snapshot = await _chatRepository.getChats(_conversation);
    setState(() {
      chats = snapshot;
    });
  }

  void addMessage(Conversation _conversation, String text) {
    final chat = Chat(text: text, time: DateTime.now().toUtc().millisecondsSinceEpoch, userId: currentUser.value.id!);

    if (_conversation.id == null) {
      _conversation.id = UniqueKey().toString();
      createConversation(_conversation);
    }

    _conversation.lastMessage = text;
    _conversation.lastMessageTime = chat.time;
    _conversation.readByUsers = [currentUser.value.id!];

    _chatRepository.addMessage(_conversation, chat).then((_) {
      for (var user in _conversation.users) {
        if (user.id != currentUser.value.id) {
          sendNotification(text, '${S.of(state!.context).newMessageFrom} ${currentUser.value.name!}', user);
        }
      }
    });
  }

  List<QueryDocumentSnapshot> orderSnapshotByTime(AsyncSnapshot snapshot) {
    final List<QueryDocumentSnapshot> docs = snapshot.data.docs;
    docs.sort((a, b) => b.get('time').compareTo(a.get('time')));
    return docs;
  }
}
