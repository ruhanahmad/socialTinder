import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_theme.dart';
import '../splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue,
              AppTheme.oceanBlue,
              AppTheme.sandColor,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Coconut Trees
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Coconut Tree 1
                    Positioned(
                      left: ScreenUtil().setWidth(50),
                      top: ScreenUtil().setHeight(100),
                      child: _buildCoconutTree(),
                    ),
                    // Coconut Tree 2
                    Positioned(
                      right: ScreenUtil().setWidth(30),
                      top: ScreenUtil().setHeight(80),
                      child: _buildCoconutTree(),
                    ),
                    // Coconut Tree 3
                    Positioned(
                      left: ScreenUtil().setWidth(150),
                      top: ScreenUtil().setHeight(120),
                      child: _buildCoconutTree(),
                    ),
                  ],
                ),
              ),
              
              // App Logo and Title
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      width: ScreenUtil().setWidth(120),
                      height: ScreenUtil().setWidth(120),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryYellow.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: AppTheme.darkText,
                      ),
                    ),
                    
                    SizedBox(height: ScreenUtil().setHeight(30)),
                    
                    // App Title
                    Text(
                      'Social Tinder',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        shadows: [
                          Shadow(
                            color: AppTheme.darkText.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    
                    Text(
                      'Caribbean Connection',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loading Indicator
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(20)),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoconutTree() {
    return Column(
      children: [
        // Tree trunk
        Container(
          width: ScreenUtil().setWidth(8),
          height: ScreenUtil().setHeight(80),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Palm leaves
        Container(
          width: ScreenUtil().setWidth(40),
          height: ScreenUtil().setHeight(60),
          decoration: const BoxDecoration(
            color: Color(0xFF228B22),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
} 