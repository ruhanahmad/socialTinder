import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../data/api_config.dart';

class AuthController extends GetxController {
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
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        body: {
          'email': email,
          'password': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        token.value = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value);
        await prefs.setString('user_id', responseData['user']['id'].toString());

        Get.offAllNamed(AppRoutes.MAIN_HOME);
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
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        body: {
          'name': 'New User', // The API likely requires a name
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        token.value = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.value);
        await prefs.setString('user_id', responseData['user']['id'].toString());
        
        Get.offAllNamed(AppRoutes.PROFILE_SETUP);
      } else {
        errorMessage.value = 'Registration failed: ${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}