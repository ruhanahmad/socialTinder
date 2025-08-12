import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_config.dart';

class DatingController extends GetxController {
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

  Future<void> _withAuthToken(Future<void> Function(String token) action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      errorMessage.value = 'Authentication error. Please log in again.';
      return;
    }
    await action(token);
  }

  Future<void> loadPotentialMatches() async {
    await _withAuthToken((token) async {
      try {
        isLoading.value = true;
        errorMessage.value = '';

        final queryParams = {
          'minAge': minAge.value.toString(),
          'maxAge': maxAge.value.toString(),
          'maxDistance': maxDistance.value.toString(),
          if (preferredGender.value.isNotEmpty) 'gender': preferredGender.value,
          if (preferredNationality.value.isNotEmpty) 'nationality': preferredNationality.value,
        };

        final uri = Uri.parse('${ApiConfig.baseUrl}/dating/potential-matches').replace(queryParameters: queryParams);

        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          potentialMatches.value = List<Map<String, dynamic>>.from(data['matches']);
          potentialMatches.shuffle();
        } else {
          errorMessage.value = 'Failed to load potential matches: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred while loading matches: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> loadMatches() async {
    await _withAuthToken((token) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/dating/matches'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          matches.value = List<Map<String, dynamic>>.from(data['matches']);
        } else {
          errorMessage.value = 'Failed to load your matches: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred while loading your matches: $e';
      }
    });
  }

  Future<void> swipe(String swipedUserId, String direction) async {
    potentialMatches.removeWhere((match) => match['id'] == swipedUserId);

    await _withAuthToken((token) async {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/dating/swipe'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'swiped_user_id': swipedUserId,
            'direction': direction,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['match_status'] == true) {
            Get.snackbar('It\'s a Match!', 'You can now start chatting.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            await loadMatches();
          }
        } else {
          errorMessage.value = 'Failed to process swipe: ${response.body}';
          // Re-fetch potential matches to revert optimistic swipe
          await loadPotentialMatches();
        }
      } catch (e) {
        errorMessage.value = 'An error occurred during swipe: $e';
        await loadPotentialMatches();
      }
    });
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