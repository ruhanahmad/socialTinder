import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user has completed profile setup
      // For now, navigate to main home
      Get.offAllNamed(AppRoutes.MAIN_HOME);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
} 