import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_config.dart';

class EventsController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userTickets = <Map<String, dynamic>>[].obs;
  
  // Event form fields
  final RxString eventName = ''.obs;
  final RxString description = ''.obs;
  final RxString location = ''.obs;
  final Rx<DateTime?> date = Rx<DateTime?>(null);
  final RxString time = ''.obs; // The view will provide this in 'HH:mm' format
  final RxDouble ticketPrice = 0.0.obs;
  final RxInt maxTickets = 100.obs;
  final RxList<dynamic> images = <dynamic>[].obs; // For URLs (String) and new files (XFile)

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    loadUserEvents();
    loadUserTickets();
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/events'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        events.value = List<Map<String, dynamic>>.from(data['events']);
      } else {
        errorMessage.value = 'Failed to load events: ${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
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

  Future<void> loadUserEvents() async {
    await _withAuthToken((token) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/my-events'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          userEvents.value = List<Map<String, dynamic>>.from(data['events']);
        } else {
          errorMessage.value = 'Failed to load your events: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> loadUserTickets() async {
    await _withAuthToken((token) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/my-tickets'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          userTickets.value = List<Map<String, dynamic>>.from(data['tickets']);
        } else {
          errorMessage.value = 'Failed to load your tickets: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> createEvent() async {
    if (eventName.value.isEmpty || description.value.isEmpty || location.value.isEmpty || date.value == null || time.value.isEmpty) {
      errorMessage.value = 'Please fill in all required fields.';
      return;
    }

    await _withAuthToken((token) async {
      isLoading.value = true;
      errorMessage.value = '';
      try {
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/events'))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json';

        // Combine date and time, assuming time is in 'HH:mm' format
        final datePart = date.value!.toIso8601String().substring(0, 10);
        final dateTimeString = '$datePart ${time.value}:00';

        request.fields.addAll({
          'name': eventName.value,
          'description': description.value,
          'location': location.value,
          'date_time': dateTimeString,
          'ticket_price': ticketPrice.value.toString(),
          'max_tickets': maxTickets.value.toString(),
        });

        for (var image in images.whereType<XFile>()) {
          request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          Get.back();
          _clearForm();
          await loadUserEvents();
          await loadEvents();
          Get.snackbar('Success', 'Event created successfully!');
        } else {
          errorMessage.value = 'Failed to create event: $responseBody';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> purchaseTicket(String eventId) async {
    await _withAuthToken((token) async {
      isLoading.value = true;
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/events/$eventId/purchase'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        final responseBody = json.decode(response.body);
        if (response.statusCode == 200) {
          await loadUserTickets();
          Get.snackbar('Success', responseBody['message'] ?? 'Ticket purchased successfully!');
        } else {
          errorMessage.value = responseBody['message'] ?? 'Failed to purchase ticket.';
          Get.snackbar('Error', errorMessage.value);
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: 80,
      );
      if (pickedFiles.isNotEmpty) {
        images.addAll(pickedFiles);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick images: $e';
    }
  }

  void removeImage(dynamic image) => images.remove(image);

  void _clearForm() {
    eventName.value = '';
    description.value = '';
    location.value = '';
    date.value = null;
    time.value = '';
    ticketPrice.value = 0.0;
    maxTickets.value = 100;
    images.clear();
  }

  void clearError() => errorMessage.value = '';

  // Update methods for form fields
  void updateEventName(String value) => eventName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateLocation(String value) => location.value = value;
  void updateDate(DateTime? newDate) => date.value = newDate;
  void updateTime(String newTime) => time.value = newTime;
  void updateTicketPrice(double value) => ticketPrice.value = value;
  void updateMaxTickets(int value) => maxTickets.value = value;
}