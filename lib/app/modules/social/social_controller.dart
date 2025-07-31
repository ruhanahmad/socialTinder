import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SocialController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;
  final RxList<String> friends = <String>[].obs;
  final RxString newPostText = ''.obs;
  final RxList<String> selectedImages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    loadFriends();
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      posts.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load posts';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFriends() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          friends.value = List<String>.from(data['friends'] ?? []);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load friends';
    }
  }

  Future<void> createPost() async {
    if (newPostText.value.trim().isEmpty && selectedImages.isEmpty) {
      errorMessage.value = 'Please add some content to your post';
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
      for (String imagePath in selectedImages) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
        final ref = _storage.ref().child('post_images/$fileName');
        await ref.putFile(File(imagePath));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create post
      await _firestore.collection('posts').add({
        'userId': user.uid,
        'text': newPostText.value.trim(),
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
      });

      // Clear form
      newPostText.value = '';
      selectedImages.clear();
      
      // Reload posts
      await loadPosts();
    } catch (e) {
      errorMessage.value = 'Failed to create post';
    } finally {
      isLoading.value = false;
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
        selectedImages.add(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  void removeImage(int index) {
    if (index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<void> addFriend(String username) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Find user by username
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isEmpty) {
        errorMessage.value = 'User not found';
        return;
      }

      final friendId = snapshot.docs.first.id;
      if (friendId == user.uid) {
        errorMessage.value = 'You cannot add yourself as a friend';
        return;
      }

      // Add to friends list
      await _firestore.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayUnion([friendId])
      });

      await loadFriends();
    } catch (e) {
      errorMessage.value = 'Failed to add friend';
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();
      
      if (post.exists) {
        final data = post.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes'] ?? []);
        
        if (likes.contains(user.uid)) {
          likes.remove(user.uid);
        } else {
          likes.add(user.uid);
        }
        
        await postRef.update({'likes': likes});
        await loadPosts();
      }
    } catch (e) {
      errorMessage.value = 'Failed to like post';
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Update methods
  void updateNewPostText(String value) => newPostText.value = value;

  // Getter for current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';
} 