import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false) 
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String receiverId, String message) async {
    
    final String currentUserId = _auth.currentUser!.uid;
    
    final doc = await _firestore
        .collection('users')
        .where('uid', isEqualTo: currentUserId)
        .limit(1)
        .get();
        
    final currentUserUsername = doc.docs.first.data()['username'];
    final Timestamp timestamp = Timestamp.now();

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderUsername': currentUserUsername,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage);
    
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp,
    });
  }
}