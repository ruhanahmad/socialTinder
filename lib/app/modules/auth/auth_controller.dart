import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  // API base URL - replace with your Laravel API endpoint
  final String apiBaseUrl = 'https://your-laravel-api.com/api';
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('AuthController initialized');
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Call Laravel API for login
      final response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        // Parse the response and save token
        // This is a placeholder - adjust based on your API response structure
        // final responseData = jsonDecode(response.body);
        // token.value = responseData['token'];
        
        Get.offAllNamed(AppRoutes.PROFILE_SETUP);
      } else {
        errorMessage.value = 'Invalid credentials';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Call Laravel API for registration
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        body: {
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      
      if (response.statusCode == 201) {
        // Parse the response and save token
        // This is a placeholder - adjust based on your API response structure
        // final responseData = jsonDecode(response.body);
        // token.value = responseData['token'];
        
        Get.offAllNamed(AppRoutes.PROFILE_SETUP);
      } else {
        errorMessage.value = 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to handle API error responses
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Invalid credentials.';
      case 422:
        return 'Validation error. Please check your input.';
      case 409:
        return 'An account already exists with this email.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}