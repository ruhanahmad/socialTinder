import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void navigateToSocial() {
    Get.toNamed(AppRoutes.SOCIAL_WALL);
  }

  void navigateToDating() {
    Get.toNamed(AppRoutes.DATING);
  }

  void navigateToRestaurants() {
    Get.toNamed(AppRoutes.RESTAURANTS);
  }

  void navigateToEvents() {
    Get.toNamed(AppRoutes.EVENTS);
  }
} 