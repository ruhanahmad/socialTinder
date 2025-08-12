import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_config.dart';

class RestaurantsController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> restaurants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userRestaurants = <Map<String, dynamic>>[].obs;

  // Restaurant form fields
  final RxString restaurantName = ''.obs;
  final RxString description = ''.obs;
  final RxString address = ''.obs;
  final RxString phone = ''.obs;
  final RxString website = ''.obs;
  final RxList<String> menuItems = <String>[].obs;
  final RxList<String> specials = <String>[].obs;
  // Use a dynamic list to hold image URLs (String) and new local files (XFile)
  final RxList<dynamic> images = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
    loadUserRestaurants();
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

  Future<void> loadRestaurants() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/restaurants'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        restaurants.value = List<Map<String, dynamic>>.from(data['restaurants']);
      } else {
        errorMessage.value = 'Failed to load restaurants: ${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserRestaurants() async {
    await _withAuthToken((token) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/my-restaurants'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          userRestaurants.value = List<Map<String, dynamic>>.from(data['restaurants']);
        } else {
          errorMessage.value = 'Failed to load your restaurants: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> saveRestaurant({String? restaurantId}) async {
    if (restaurantName.value.isEmpty || description.value.isEmpty || address.value.isEmpty) {
      errorMessage.value = 'Name, description, and address are required.';
      return;
    }

    await _withAuthToken((token) async {
      isLoading.value = true;
      errorMessage.value = '';
      try {
        final isUpdating = restaurantId != null;
        final uri = isUpdating
            ? Uri.parse('${ApiConfig.baseUrl}/restaurants/$restaurantId')
            : Uri.parse('${ApiConfig.baseUrl}/restaurants');

        var request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json';

        if (isUpdating) {
          request.fields['_method'] = 'PUT';
        }

        request.fields.addAll({
          'name': restaurantName.value,
          'description': description.value,
          'address': address.value,
          'phone': phone.value,
          'website': website.value,
          'menu_items': json.encode(menuItems),
          'specials': json.encode(specials),
          'existing_images': json.encode(images.whereType<String>().toList()),
        });

        for (var image in images.whereType<XFile>()) {
          request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.back(); // Exit create/edit screen
          _clearForm();
          await loadUserRestaurants();
          await loadRestaurants();
          Get.snackbar('Success', 'Restaurant saved successfully!');
        } else {
          errorMessage.value = 'Save failed: $responseBody';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> rateRestaurant(String restaurantId, double rating) async {
    await _withAuthToken((token) async {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/restaurants/$restaurantId/rate'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'rating': rating}),
        );

        if (response.statusCode == 200) {
          await loadRestaurants();
          Get.snackbar('Success', 'Rating submitted!');
        } else {
          errorMessage.value = 'Rating failed: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
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

  void setFormForEdit(Map<String, dynamic> restaurant) {
    _clearForm();
    restaurantName.value = restaurant['name'] ?? '';
    description.value = restaurant['description'] ?? '';
    address.value = restaurant['address'] ?? '';
    phone.value = restaurant['phone'] ?? '';
    website.value = restaurant['website'] ?? '';
    menuItems.value = List<String>.from(restaurant['menu_items'] ?? []);
    specials.value = List<String>.from(restaurant['specials'] ?? []);
    images.value = List<dynamic>.from(restaurant['images'] ?? []);
  }

  void addMenuItem(String item) {
    if (item.trim().isNotEmpty) menuItems.add(item.trim());
  }

  void removeMenuItem(int index) => menuItems.removeAt(index);

  void addSpecial(String special) {
    if (special.trim().isNotEmpty) specials.add(special.trim());
  }

  void removeSpecial(int index) => specials.removeAt(index);

  void _clearForm() {
    restaurantName.value = '';
    description.value = '';
    address.value = '';
    phone.value = '';
    website.value = '';
    menuItems.clear();
    specials.clear();
    images.clear();
  }

  void clearError() => errorMessage.value = '';

  // Update methods for form fields
  void updateRestaurantName(String value) => restaurantName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateAddress(String value) => address.value = value;
  void updatePhone(String value) => phone.value = value;
  void updateWebsite(String value) => website.value = value;
}