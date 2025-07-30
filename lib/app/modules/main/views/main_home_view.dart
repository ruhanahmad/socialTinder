import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_theme.dart';
import '../main_controller.dart';
import '../../social/views/social_wall_view.dart';
import '../../dating/views/dating_view.dart';
import '../../restaurants/views/restaurants_view.dart';
import '../../events/views/events_view.dart';

class MainHomeView extends GetView<MainController> {
  const MainHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SocialWallView(),
      const DatingView(),
      const RestaurantsView(),
      const EventsView(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.primaryYellow,
          unselectedItemColor: AppTheme.lightText,
          selectedLabelStyle: TextStyle(
            fontSize: ScreenUtil().setSp(12),
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ScreenUtil().setSp(12),
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Social',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Dating',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Restaurants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
          ],
        )),
      ),
    );
  }
} 