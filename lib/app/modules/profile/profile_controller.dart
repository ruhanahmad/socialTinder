import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  // API base URL - replace with your Laravel API endpoint
  final String apiBaseUrl = 'https://your-laravel-api.com/api';
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> photos = <String>[].obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedNationality = ''.obs;
  
  // Profile fields
  final RxString name = ''.obs;
  final RxInt age = 18.obs;
  final RxString location = ''.obs;
  final RxString nationality = ''.obs;
  final RxString gender = ''.obs;
  final RxDouble height = 170.0.obs;
  final RxList<String> interests = <String>[].obs;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> nationalityOptions = [
    'Jamaica', 'Trinidad & Tobago', 'Barbados', 'Bahamas', 'Grenada',
    'St. Lucia', 'Antigua & Barbuda', 'St. Kitts & Nevis', 'Dominica',
    'St. Vincent & Grenadines', 'Cuba', 'Haiti', 'Dominican Republic',
    'Puerto Rico', 'Other'
  ];

  final List<String> interestOptions = [
    'Beach Activities', 'Water Sports', 'Dancing', 'Music', 'Food & Cuisine',
    'Travel', 'Fitness', 'Reading', 'Gaming', 'Art & Culture',
    'Photography', 'Cooking', 'Hiking', 'Swimming', 'Fishing',
    'Sailing', 'Diving', 'Snorkeling', 'Volleyball', 'Tennis'
  ];

  void updateName(String value) => name.value = value;
  void updateAge(int value) => age.value = value;
  void updateLocation(String value) => location.value = value;
  void updateHeight(double value) => height.value = value;
  void updateGender(String? value) => gender.value = value ?? '';
  void updateNationality(String? value) => nationality.value = value ?? '';

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        isLoading.value = true;
        
        // Get auth token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) {
          errorMessage.value = 'User not authenticated.';
          isLoading.value = false;
          return;
        }
        
        // Create form data for image upload
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$apiBaseUrl/profile/upload-photo'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          image.path,
        ));
        
        var response = await request.send();
        
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var data = json.decode(responseData);
          photos.add(data['photo_url']);
        } else {
          errorMessage.value = 'Failed to upload image. Please try again.';
        }
        
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to upload image. Please try again.';
    }
  }

  void removePhoto(int index) {
    if (index < photos.length) {
      photos.removeAt(index);
    }
  }

  Future<void> saveProfile() async {
    if (name.value.isEmpty || location.value.isEmpty || 
        gender.value.isEmpty || nationality.value.isEmpty || photos.isEmpty) {
      errorMessage.value = 'Please fill in all required fields and add at least one photo.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        return;
      }

      final profileData = {
        'name': name.value,
        'age': age.value,
        'location': location.value,
        'nationality': nationality.value,
        'gender': gender.value,
        'height': height.value,
        'interests': interests.toList(),
        'photos': photos.toList(),
      };

      // Call API to save profile
      final response = await http.post(
        Uri.parse('$apiBaseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        Get.offAllNamed(AppRoutes.MAIN_HOME);
      } else {
        errorMessage.value = 'Failed to save profile. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to save profile. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}