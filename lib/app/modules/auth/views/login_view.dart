import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_theme.dart';
import '../auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    print('LoginView build called');
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            child: Column(
              children: [
                SizedBox(height: ScreenUtil().setHeight(60)),
                
                // App Logo
                Container(
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
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
                    size: 50,
                    color: AppTheme.darkText,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                Text(
                  'Sign in to continue your Caribbean journey',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    color: AppTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: ScreenUtil().setHeight(50)),
                
                // Login Form
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: AppTheme.primaryYellow),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        
                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryYellow),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ScreenUtil().setHeight(30)),
                        
                        // Error Message
                        Obx(() {
                          if (controller.errorMessage.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        
                        // Login Button
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: ScreenUtil().setHeight(50),
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      controller.clearError();
                                      controller.signIn(
                                        emailController.text.trim(),
                                        passwordController.text,
                                      );
                                    },
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(color: AppTheme.white)
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(16),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),
                        
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                color: AppTheme.lightText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.SIGNUP),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                  color: AppTheme.primaryYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Beach Decoration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBeachElement(Icons.beach_access, 'Beach'),
                    _buildBeachElement(Icons.park, 'Palm Trees'),
                    _buildBeachElement(Icons.water, 'Ocean'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeachElement(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.white,
          size: ScreenUtil().setSp(24),
        ),
        SizedBox(height: ScreenUtil().setHeight(5)),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: ScreenUtil().setSp(12),
          ),
        ),
      ],
    );
  }
} 