import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../routes/app_routes.dart';
import '../../data/api_config.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Use a dynamic list to hold image URLs (String) and new local files (XFile)
  final RxList<dynamic> photos = <dynamic>[].obs;
  
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

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        photos.addAll(pickedFiles);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick images. Please try again.';
    }
  }

  void removePhoto(dynamic photo) {
    photos.remove(photo);
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

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        errorMessage.value = 'User not authenticated.';
        isLoading.value = false;
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/profile'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = name.value;
      request.fields['age'] = age.value.toString();
      request.fields['location'] = location.value;
      request.fields['nationality'] = nationality.value;
      request.fields['gender'] = gender.value;
      request.fields['height'] = height.value.toString();
      request.fields['interests'] = json.encode(interests);

      // Separate existing photos from new ones
      List<String> existingPhotos = photos.whereType<String>().toList();
      request.fields['existing_photos'] = json.encode(existingPhotos);

      List<XFile> newPhotos = photos.whereType<XFile>().toList();
      for (var photoFile in newPhotos) {
        request.files.add(await http.MultipartFile.fromPath('photos[]', photoFile.path));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Get.offAllNamed(AppRoutes.MAIN_HOME);
      } else {
        errorMessage.value = 'Failed to save profile: $responseBody';
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