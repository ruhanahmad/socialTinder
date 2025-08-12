import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatingController extends GetxController {
  // API base URL - replace with your Laravel API endpoint
  final String apiBaseUrl = 'https://your-laravel-api.com/api';
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> potentialMatches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;
  
  // Filter settings
  final RxInt minAge = 18.obs;
  final RxInt maxAge = 100.obs;
  final RxDouble maxDistance = 50.0.obs;
  final RxString preferredGender = ''.obs;
  final RxString preferredNationality = ''.obs;
  
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> nationalityOptions = [
    'Jamaica', 'Trinidad & Tobago', 'Barbados', 'Bahamas', 'Grenada',
    'St. Lucia', 'Antigua & Barbuda', 'St. Kitts & Nevis', 'Dominica',
    'St. Vincent & Grenadines', 'Cuba', 'Haiti', 'Dominican Republic',
    'Puerto Rico', 'Other'
  ];

  @override
  void onInit() {
    super.onInit();
    loadPotentialMatches();
    loadMatches();
  }

  Future<void> loadPotentialMatches() async {
    try {
      isLoading.value = true;
      
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      // Call API to get potential matches
      final response = await http.get(
        Uri.parse('$apiBaseUrl/dating/potential-matches'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        potentialMatches.value = List<Map<String, dynamic>>.from(data['matches']);
      } else {
        errorMessage.value = 'Failed to load potential matches';
      }

      // Build query based on filters
      Query query = _firestore.collection('users')
          .where('gender', isEqualTo: preferredGender.value.isEmpty ? userGender : preferredGender.value)
          .where('age', isGreaterThanOrEqualTo: minAge.value)
          .where('age', isLessThanOrEqualTo: maxAge.value);

      if (preferredNationality.value.isNotEmpty) {
        query = query.where('nationality', isEqualTo: preferredNationality.value);
      }

      final QuerySnapshot snapshot = await query.get();
      
      potentialMatches.value = snapshot.docs
          .where((doc) => doc.id != user.uid) // Exclude current user
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();

      // Shuffle the list for random order
      potentialMatches.shuffle();
    } catch (e) {
      errorMessage.value = 'Failed to load potential matches';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMatches() async {
    try {
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
    }
  }

  Future<void> swipeRight(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if the other user has already swiped right on current user
      final existingMatch = await _firestore
          .collection('swipes')
          .where('userId', isEqualTo: userId)
          .where('swipedUserId', isEqualTo: user.uid)
          .where('direction', isEqualTo: 'right')
          .get();

      if (existingMatch.docs.isNotEmpty) {
        // It's a match!
        await _createMatch(userId);
      } else {
        // Record the swipe
        await _firestore.collection('swipes').add({
          'userId': user.uid,
          'swipedUserId': userId,
          'direction': 'right',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Remove from potential matches
      potentialMatches.removeWhere((match) => match['id'] == userId);
    } catch (e) {
      errorMessage.value = 'Failed to process swipe';
    }
  }

  Future<void> swipeLeft(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Record the swipe
      await _firestore.collection('swipes').add({
        'userId': user.uid,
        'swipedUserId': userId,
        'direction': 'left',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove from potential matches
      potentialMatches.removeWhere((match) => match['id'] == userId);
    } catch (e) {
      errorMessage.value = 'Failed to process swipe';
    }
  }

  Future<void> _createMatch(String otherUserId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create match document
      await _firestore.collection('matches').add({
        'users': [user.uid, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      });

      // Add to matches list
      await loadMatches();
    } catch (e) {
      errorMessage.value = 'Failed to create match';
    }
  }

  void updateMinAge(int value) => minAge.value = value;
  void updateMaxAge(int value) => maxAge.value = value;
  void updateMaxDistance(double value) => maxDistance.value = value;
  void updatePreferredGender(String? value) => preferredGender.value = value ?? '';
  void updatePreferredNationality(String? value) => preferredNationality.value = value ?? '';

  void applyFilters() {
    loadPotentialMatches();
  }

  void clearError() {
    errorMessage.value = '';
  }
}