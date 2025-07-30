import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../profile_controller.dart';

class ProfileSetupView extends GetView<ProfileController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.darkText,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightYellow,
              AppTheme.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                Text(
                  'Create your Caribbean profile to connect with others',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    color: AppTheme.lightText,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Photos Section
                _buildPhotosSection(),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Basic Information
                _buildBasicInfoSection(),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Location & Nationality
                _buildLocationSection(),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Physical Information
                _buildPhysicalInfoSection(),
                
                SizedBox(height: ScreenUtil().setHeight(30)),
                
                // Interests
                _buildInterestsSection(),
                
                SizedBox(height: ScreenUtil().setHeight(40)),
                
                // Error Message
                Obx(() => controller.errorMessage.isNotEmpty
                    ? Container(
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
                      )
                    : const SizedBox.shrink()),
                
                SizedBox(height: ScreenUtil().setHeight(20)),
                
                // Save Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: ScreenUtil().setHeight(50),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.saveProfile,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: AppTheme.white)
                        : Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos *',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: ScreenUtil().setWidth(10),
                mainAxisSpacing: ScreenUtil().setWidth(10),
              ),
              itemCount: controller.photos.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.photos.length) {
                  return GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightYellow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryYellow, style: BorderStyle.solid),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: AppTheme.primaryYellow,
                        size: 30,
                      ),
                    ),
                  );
                }
                
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: controller.photos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightYellow,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.lightYellow,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => controller.removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppTheme.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Name
            TextField(
              onChanged: controller.updateName,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person, color: AppTheme.primaryYellow),
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Age
            Row(
              children: [
                Text(
                  'Age: ${controller.age.value}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    color: AppTheme.darkText,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.age.value.toDouble(),
                    min: 18,
                    max: 100,
                    divisions: 82,
                    activeColor: AppTheme.primaryYellow,
                    onChanged: (value) => controller.updateAge(value.toInt()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location & Nationality',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Location
            TextField(
              onChanged: controller.updateLocation,
              decoration: const InputDecoration(
                labelText: 'Where are you from? *',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryYellow),
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Nationality
            DropdownButtonFormField<String>(
              value: controller.nationality.value.isEmpty ? null : controller.nationality.value,
              decoration: const InputDecoration(
                labelText: 'Nationality *',
                prefixIcon: Icon(Icons.flag, color: AppTheme.primaryYellow),
              ),
              items: controller.nationalityOptions.map((nationality) {
                return DropdownMenuItem(
                  value: nationality,
                  child: Text(nationality),
                );
              }).toList(),
              onChanged: controller.updateNationality,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical Information',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Gender
            DropdownButtonFormField<String>(
              value: controller.gender.value.isEmpty ? null : controller.gender.value,
              decoration: const InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryYellow),
              ),
              items: controller.genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: controller.updateGender,
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            // Height
            Row(
              children: [
                Text(
                  'Height: ${controller.height.value.toInt()} cm',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    color: AppTheme.darkText,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.height.value,
                    min: 140,
                    max: 220,
                    divisions: 80,
                    activeColor: AppTheme.primaryYellow,
                    onChanged: controller.updateHeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interests',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(15)),
            
            Obx(() => Wrap(
              spacing: ScreenUtil().setWidth(10),
              runSpacing: ScreenUtil().setHeight(10),
              children: controller.interestOptions.map((interest) {
                final isSelected = controller.interests.contains(interest);
                return GestureDetector(
                  onTap: () => controller.toggleInterest(interest),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(15),
                      vertical: ScreenUtil().setHeight(8),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryYellow : AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryYellow : AppTheme.lightText,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? AppTheme.darkText : AppTheme.lightText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }
} 