import 'package:get/get.dart';
import 'dating_controller.dart';

class DatingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatingController>(() => DatingController());
  }
} 