import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat.dart';
import '../models/conversation.dart';

class ChatRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool?> signInWithToken(String token) async {
    try {
      final result = await _auth.signInWithCustomToken(token);
      return result.user != null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user != null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addUserInfo(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  Future<QuerySnapshot?> getUserInfo(String token) async {
    try {
      return await FirebaseFirestore.instance.collection("users").where("token", isEqualTo: token).get();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<QuerySnapshot> searchByName(String searchField) {
    return FirebaseFirestore.instance.collection("users").where('userName', isEqualTo: searchField).get();
  }

  Future<void> createConversation(Conversation conversation) {
    return FirebaseFirestore.instance.collection("conversations").doc(conversation.id).set(conversation.toMap()).catchError((e) => print(e));
  }

  Future<Stream<QuerySnapshot>> getUserConversations(String userId) async {
    return FirebaseFirestore.instance.collection("conversations").where('visible_to_users', arrayContains: userId).snapshots();
  }

  Future<Stream<QuerySnapshot>> getChats(Conversation conversation) async {
    await updateConversation(conversation.id, {'read_by_users': conversation.readByUsers});
    return FirebaseFirestore.instance.collection("conversations").doc(conversation.id).collection("chats").orderBy('time', descending: true).snapshots();
  }

  Future<void> addMessage(Conversation conversation, Chat chat) async {
    await FirebaseFirestore.instance.collection("conversations").doc(conversation.id).collection("chats").add(chat.toMap() as Map<String, dynamic>);
    await updateConversation(conversation.id, conversation.toUpdatedMap());
  }

  Future<void> updateConversation(String? conversationId, Map<String, dynamic> data) {
    return FirebaseFirestore.instance.collection("conversations").doc(conversationId).update(data).catchError((e) => print(e.toString()));
  }
}
