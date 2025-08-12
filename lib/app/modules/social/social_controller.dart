import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_config.dart';

class SocialController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> friends = <Map<String, dynamic>>[].obs;

  final RxString newPostText = ''.obs;
  final RxList<XFile> newPostImages = <XFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    loadFriends();
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

  Future<void> loadPosts() async {
    await _withAuthToken((token) async {
      try {
        isLoading.value = true;
        errorMessage.value = '';
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/posts'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          posts.value = List<Map<String, dynamic>>.from(data['posts']);
        } else {
          errorMessage.value = 'Failed to load posts: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> loadFriends() async {
    await _withAuthToken((token) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/friends'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          friends.value = List<Map<String, dynamic>>.from(data['friends']);
        } else {
          errorMessage.value = 'Failed to load friends: ${response.body}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> createPost() async {
    if (newPostText.value.trim().isEmpty && newPostImages.isEmpty) {
      errorMessage.value = 'Please write something or add an image.';
      return;
    }

    await _withAuthToken((token) async {
      isLoading.value = true;
      errorMessage.value = '';
      try {
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/posts'))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..fields['text'] = newPostText.value.trim();

        for (var imageFile in newPostImages) {
          request.files.add(await http.MultipartFile.fromPath('images[]', imageFile.path));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          newPostText.value = '';
          newPostImages.clear();
          await loadPosts(); // Refresh posts
        } else {
          errorMessage.value = 'Failed to create post: $responseBody';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> likePost(String postId) async {
    await _withAuthToken((token) async {
      final postIndex = posts.indexWhere((p) => p['id'].toString() == postId);
      if (postIndex == -1) return;

      // Optimistic update
      final post = posts[postIndex];
      final isLiked = post['is_liked_by_user'] ?? false;
      final likesCount = post['likes_count'] ?? 0;
      posts[postIndex] = {
        ...post,
        'is_liked_by_user': !isLiked,
        'likes_count': isLiked ? likesCount - 1 : likesCount + 1,
      };

      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/posts/$postId/like'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          await loadPosts(); // Revert on failure
          errorMessage.value = 'Failed to update like status.';
        } else {
           final updatedPost = json.decode(response.body)['post'];
           posts[postIndex] = updatedPost;
        }
      } catch (e) {
        await loadPosts(); // Revert on failure
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> addFriend(String userId) async {
    await _withAuthToken((token) async {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/friends/add'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'user_id': userId}),
        );
        if (response.statusCode == 200) {
          await loadFriends();
          Get.snackbar('Success', 'Friend request sent!');
        } else {
          errorMessage.value = 'Failed to add friend: ${json.decode(response.body)['message']}';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred: $e';
      }
    });
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: 80,
      );
      if (pickedFiles.isNotEmpty) {
        newPostImages.addAll(pickedFiles);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick images: $e';
    }
  }

  void removeNewPostImage(XFile image) {
    newPostImages.remove(image);
  }

  void onPostTextChanged(String text) {
    newPostText.value = text;
  }

  void clearError() {
    errorMessage.value = '';
  }
}