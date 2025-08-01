import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_theme.dart';
import '../main_controller.dart';

class MainHomeView extends GetView<MainController> {
  const MainHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildPage(controller.currentIndex.value)),
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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildSocialPage();
      case 1:
        return _buildDatingPage();
      case 2:
        return _buildRestaurantsPage();
      case 3:
        return _buildEventsPage();
      default:
        return _buildSocialPage();
    }
  }

  Widget _buildSocialPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: AppTheme.primaryYellow),
          SizedBox(height: 20),
          Text(
            'Social Wall',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.navigateToSocial,
            child: Text('Go to Social Wall'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatingPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 80, color: AppTheme.primaryYellow),
          SizedBox(height: 20),
          Text(
            'Dating',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.navigateToDating,
            child: Text('Go to Dating'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: AppTheme.primaryYellow),
          SizedBox(height: 20),
          Text(
            'Restaurants',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.navigateToRestaurants,
            child: Text('Go to Restaurants'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 80, color: AppTheme.primaryYellow),
          SizedBox(height: 20),
          Text(
            'Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.navigateToEvents,
            child: Text('Go to Events'),
          ),
        ],
      ),
    );
  }
} 