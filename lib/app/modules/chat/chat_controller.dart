import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_config.dart';

class ChatController extends GetxController {
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  final RxString newMessage = ''.obs;
  final RxString currentMatchId = ''.obs;
  final RxString currentChatPartnerName = ''.obs;

  Timer? _pollingTimer;
  String? currentUserId;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    loadMatches();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadCurrentUser() async {
      final prefs = await SharedPreferences.getInstance();
      // Assuming user ID is stored as a string. Adapt if it's an int.
      currentUserId = prefs.getString('user_id');
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

  Future<void> loadMatches() async {
    await _withAuthToken((token) async {
      try {
        isLoading.value = true;
        errorMessage.value = '';
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/matches'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          matches.value = List<Map<String, dynamic>>.from(data['matches']);
        } else {
          errorMessage.value = 'Failed to load matches: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  void selectMatch(String matchId, String partnerName) {
    if (currentMatchId.value == matchId) return;

    currentMatchId.value = matchId;
    currentChatPartnerName.value = partnerName;
    messages.clear();
    _pollingTimer?.cancel();

    if (matchId.isNotEmpty) {
      loadMessages();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => loadMessages(isPolling: true));
    }
  }

  Future<void> loadMessages({bool isPolling = false}) async {
    if (currentMatchId.value.isEmpty) return;

    await _withAuthToken((token) async {
      if (!isPolling) isLoading.value = true;
      errorMessage.value = '';
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/matches/${currentMatchId.value}/messages'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newMessages = List<Map<String, dynamic>>.from(data['messages']);
          if (newMessages.length > messages.length) {
              messages.value = newMessages;
          }
        } else {
          errorMessage.value = 'Failed to load messages: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        if (!isPolling) isLoading.value = false;
      }
    });
  }

  Future<void> sendMessage() async {
    final text = newMessage.value.trim();
    if (text.isEmpty || currentMatchId.value.isEmpty) return;

    final optimisticMessage = {
      'text': text,
      'sender_id': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
      'is_optimistic': true,
    };
    messages.add(optimisticMessage);
    final originalMessage = newMessage.value;
    newMessage.value = '';

    await _withAuthToken((token) async {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/matches/${currentMatchId.value}/messages'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'text': text}),
        );

        messages.removeWhere((m) => m['is_optimistic'] == true);
        if (response.statusCode == 201) {
            final sentMessage = json.decode(response.body)['message'];
            messages.add(sentMessage);
        } else {
          errorMessage.value = 'Failed to send message: ${response.body}';
          newMessage.value = originalMessage; // Restore text on failure
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
        messages.removeWhere((m) => m['is_optimistic'] == true);
        newMessage.value = originalMessage;
      }
    });
  }

  void onNewMessageChanged(String text) {
    newMessage.value = text;
  }

  void clearError() {
    errorMessage.value = '';
  }
}