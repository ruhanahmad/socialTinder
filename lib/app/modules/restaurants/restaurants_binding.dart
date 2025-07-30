import 'package:get/get.dart';
import 'restaurants_controller.dart';

class RestaurantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantsController>(() => RestaurantsController());
  }
} 