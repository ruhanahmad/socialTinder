import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxString newMessage = ''.obs;
  final RxString selectedMatchId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('matches')
          .where('users', arrayContains: user.uid)
          .get();

      matches.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load matches';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String matchId) async {
    try {
      selectedMatchId.value = matchId;
      
      final QuerySnapshot snapshot = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      messages.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || selectedMatchId.value.isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('matches')
          .doc(selectedMatchId.value)
          .collection('messages')
          .add({
        'text': text.trim(),
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message in match
      await _firestore.collection('matches').doc(selectedMatchId.value).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      newMessage.value = '';
      await loadMessages(selectedMatchId.value);
    } catch (e) {
      errorMessage.value = 'Failed to send message';
    }
  }

  Future<String> getOtherUserName(String matchId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Unknown';

      final matchDoc = await _firestore.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) return 'Unknown';

      final data = matchDoc.data() as Map<String, dynamic>;
      final users = List<String>.from(data['users'] ?? []);
      
      final otherUserId = users.firstWhere((id) => id != user.uid, orElse: () => '');
      if (otherUserId.isEmpty) return 'Unknown';

      final userDoc = await _firestore.collection('users').doc(otherUserId).get();
      if (!userDoc.exists) return 'Unknown';

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['name'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  void updateNewMessage(String value) {
    newMessage.value = value;
  }

  String get currentUserId => _auth.currentUser?.uid ?? '';
} 