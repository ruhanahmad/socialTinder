import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage.ref().child('profile_photos/$fileName');
        
        await ref.putFile(File(image.path));
        final String downloadUrl = await ref.getDownloadURL();
        
        photos.add(downloadUrl);
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

      final user = _auth.currentUser;
      if (user == null) {
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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      Get.offAllNamed(AppRoutes.MAIN_HOME);
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