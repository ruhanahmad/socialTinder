import 'package:get/get.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/views/profile_setup_view.dart';
import '../modules/main/main_binding.dart';
import '../modules/main/views/main_home_view.dart';
import '../modules/social/social_binding.dart';
import '../modules/social/views/social_wall_view.dart';
import '../modules/dating/dating_binding.dart';
import '../modules/dating/views/dating_view.dart';
import '../modules/restaurants/restaurants_binding.dart';
import '../modules/restaurants/views/restaurants_view.dart';
import '../modules/events/events_binding.dart';
import '../modules/events/views/events_view.dart';
import '../modules/chat/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE_SETUP,
      page: () => const ProfileSetupView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN_HOME,
      page: () => const MainHomeView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.SOCIAL_WALL,
      page: () => const SocialWallView(),
      binding: SocialBinding(),
    ),
    GetPage(
      name: AppRoutes.DATING,
      page: () => const DatingView(),
      binding: DatingBinding(),
    ),
    GetPage(
      name: AppRoutes.RESTAURANTS,
      page: () => const RestaurantsView(),
      binding: RestaurantsBinding(),
    ),
    GetPage(
      name: AppRoutes.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
} 