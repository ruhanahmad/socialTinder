import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RestaurantsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
  final RxList<String> images = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
    loadUserRestaurants();
  }

  Future<void> loadRestaurants() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      restaurants.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load restaurants';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserRestaurants() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      userRestaurants.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load user restaurants';
    }
  }

  Future<void> createRestaurant() async {
    if (restaurantName.value.isEmpty || description.value.isEmpty || address.value.isEmpty) {
      errorMessage.value = 'Please fill in all required fields';
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Upload images if any
      List<String> imageUrls = [];
      for (String imagePath in images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
        final ref = _storage.ref().child('restaurant_images/$fileName');
        await ref.putFile(File(imagePath));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create restaurant
      await _firestore.collection('restaurants').add({
        'name': restaurantName.value,
        'description': description.value,
        'address': address.value,
        'phone': phone.value,
        'website': website.value,
        'menuItems': menuItems.toList(),
        'specials': specials.toList(),
        'images': imageUrls,
        'ownerId': user.uid,
        'rating': 0.0,
        'totalRatings': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _clearForm();
      await loadUserRestaurants();
    } catch (e) {
      errorMessage.value = 'Failed to create restaurant';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRestaurant(String restaurantId) async {
    try {
      isLoading.value = true;
      
      // Upload new images if any
      List<String> imageUrls = [];
      for (String imagePath in images) {
        if (imagePath.startsWith('http')) {
          imageUrls.add(imagePath); // Keep existing URLs
        } else {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
          final ref = _storage.ref().child('restaurant_images/$fileName');
          await ref.putFile(File(imagePath));
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      await _firestore.collection('restaurants').doc(restaurantId).update({
        'name': restaurantName.value,
        'description': description.value,
        'address': address.value,
        'phone': phone.value,
        'website': website.value,
        'menuItems': menuItems.toList(),
        'specials': specials.toList(),
        'images': imageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      await loadUserRestaurants();
    } catch (e) {
      errorMessage.value = 'Failed to update restaurant';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rateRestaurant(String restaurantId, double rating) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get current restaurant data
      final restaurantDoc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!restaurantDoc.exists) return;

      final data = restaurantDoc.data() as Map<String, dynamic>;
      final currentRating = data['rating'] ?? 0.0;
      final totalRatings = data['totalRatings'] ?? 0;

      // Calculate new rating
      final newTotalRatings = totalRatings + 1;
      final newRating = ((currentRating * totalRatings) + rating) / newTotalRatings;

      // Update restaurant rating
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': newRating,
        'totalRatings': newTotalRatings,
      });

      // Record user rating
      await _firestore.collection('restaurant_ratings').add({
        'restaurantId': restaurantId,
        'userId': user.uid,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await loadRestaurants();
    } catch (e) {
      errorMessage.value = 'Failed to rate restaurant';
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
        images.add(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  void removeImage(int index) {
    if (index < images.length) {
      images.removeAt(index);
    }
  }

  void addMenuItem(String item) {
    if (item.trim().isNotEmpty) {
      menuItems.add(item.trim());
    }
  }

  void removeMenuItem(int index) {
    if (index < menuItems.length) {
      menuItems.removeAt(index);
    }
  }

  void addSpecial(String special) {
    if (special.trim().isNotEmpty) {
      specials.add(special.trim());
    }
  }

  void removeSpecial(int index) {
    if (index < specials.length) {
      specials.removeAt(index);
    }
  }

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

  void clearError() {
    errorMessage.value = '';
  }

  // Update methods for form fields
  void updateRestaurantName(String value) => restaurantName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateAddress(String value) => address.value = value;
  void updatePhone(String value) => phone.value = value;
  void updateWebsite(String value) => website.value = value;
} 