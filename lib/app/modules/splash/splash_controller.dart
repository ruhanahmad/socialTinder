import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if user is logged in using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && token.isNotEmpty) {
        // User is logged in, navigate to main home
        Get.offAllNamed(AppRoutes.MAIN_HOME);
      } else {
        // User is not logged in, navigate to login
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      // If there's an error, go to login
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}