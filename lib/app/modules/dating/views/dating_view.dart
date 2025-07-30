import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../dating_controller.dart';

class DatingView extends GetView<DatingController> {
  const DatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dating'),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.darkText,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
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
        child: Column(
          children: [
            // Matches Section
            _buildMatchesSection(),
            
            // Swipe Cards Section
            Expanded(
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.potentialMatches.isEmpty
                      ? _buildEmptyState()
                      : _buildSwipeCards()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesSection() {
    return Obx(() => controller.matches.isNotEmpty
        ? Container(
            height: ScreenUtil().setHeight(100),
            padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Matches',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(10)),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.matches.length,
                    itemBuilder: (context, index) {
                      final match = controller.matches[index];
                      return _buildMatchCard(match);
                    },
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Container(
      width: ScreenUtil().setWidth(80),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
      child: Column(
        children: [
          CircleAvatar(
            radius: ScreenUtil().setSp(30),
            backgroundColor: AppTheme.primaryYellow,
            child: const Icon(Icons.person, color: AppTheme.darkText),
          ),
          SizedBox(height: ScreenUtil().setHeight(5)),
          Text(
            match['name'] ?? 'Match',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(12),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCards() {
    return Stack(
      children: [
        // Background cards
        for (int i = controller.potentialMatches.length - 1; i >= 0 && i >= controller.potentialMatches.length - 3; i--)
          Positioned(
            top: ScreenUtil().setHeight(20 + (controller.potentialMatches.length - 1 - i) * 10),
            left: ScreenUtil().setWidth(20 + (controller.potentialMatches.length - 1 - i) * 5),
            right: ScreenUtil().setWidth(20 + (controller.potentialMatches.length - 1 - i) * 5),
            child: _buildProfileCard(controller.potentialMatches[i], false),
          ),
        
        // Top card with swipe gestures
        if (controller.potentialMatches.isNotEmpty)
          Positioned(
            top: ScreenUtil().setHeight(20),
            left: ScreenUtil().setWidth(20),
            right: ScreenUtil().setWidth(20),
            child: GestureDetector(
              onPanUpdate: (details) {
                // Handle swipe gestures
                if (details.delta.dx > 50) {
                  // Swipe right
                  controller.swipeRight(controller.potentialMatches.first['id']);
                } else if (details.delta.dx < -50) {
                  // Swipe left
                  controller.swipeLeft(controller.potentialMatches.first['id']);
                }
              },
              child: _buildProfileCard(controller.potentialMatches.first, true),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile, bool isTop) {
    return Card(
      elevation: isTop ? 10 : 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: ScreenUtil().setHeight(400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.white,
              AppTheme.lightYellow,
            ],
          ),
        ),
        child: Column(
          children: [
            // Profile Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: AppTheme.primaryYellow,
                ),
                child: profile['photos']?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: profile['photos'][0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.lightYellow,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.lightYellow,
                            child: const Icon(Icons.person, size: 80),
                          ),
                        ),
                      )
                    : const Icon(Icons.person, size: 80, color: AppTheme.darkText),
              ),
            ),
            
            // Profile Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile['name'] ?? 'Anonymous',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        Text(
                          '${profile['age'] ?? 25}',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(16),
                            color: AppTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    
                    Row(
                      children: [
                        Icon(Icons.location_on, size: ScreenUtil().setSp(16), color: AppTheme.lightText),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        Text(
                          profile['location'] ?? 'Unknown location',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
                            color: AppTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    
                    Text(
                      profile['nationality'] ?? 'Unknown nationality',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        color: AppTheme.lightText,
                      ),
                    ),
                    
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    
                    // Interests
                    if (profile['interests']?.isNotEmpty == true)
                      Wrap(
                        spacing: ScreenUtil().setWidth(5),
                        children: (profile['interests'] as List).take(3).map((interest) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setHeight(4),
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(12),
                                color: AppTheme.darkText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: ScreenUtil().setSp(80),
            color: AppTheme.lightText,
          ),
          SizedBox(height: ScreenUtil().setHeight(20)),
          Text(
            'No more profiles',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              color: AppTheme.lightText,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          Text(
            'Try adjusting your filters or check back later!',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              color: AppTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setHeight(20)),
          ElevatedButton(
            onPressed: controller.loadPotentialMatches,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Dating Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Age Range
              Text('Age Range: ${controller.minAge.value} - ${controller.maxAge.value}'),
              RangeSlider(
                values: RangeValues(controller.minAge.value.toDouble(), controller.maxAge.value.toDouble()),
                min: 18,
                max: 100,
                divisions: 82,
                activeColor: AppTheme.primaryYellow,
                onChanged: (values) {
                  controller.updateMinAge(values.start.toInt());
                  controller.updateMaxAge(values.end.toInt());
                },
              ),
              
              SizedBox(height: ScreenUtil().setHeight(20)),
              
              // Distance
              Text('Max Distance: ${controller.maxDistance.value.toInt()} km'),
              Slider(
                value: controller.maxDistance.value,
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: AppTheme.primaryYellow,
                onChanged: controller.updateMaxDistance,
              ),
              
              SizedBox(height: ScreenUtil().setHeight(20)),
              
              // Gender
              DropdownButtonFormField<String>(
                value: controller.preferredGender.value.isEmpty ? null : controller.preferredGender.value,
                decoration: const InputDecoration(
                  labelText: 'Preferred Gender',
                ),
                items: controller.genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: controller.updatePreferredGender,
              ),
              
              SizedBox(height: ScreenUtil().setHeight(20)),
              
              // Nationality
              DropdownButtonFormField<String>(
                value: controller.preferredNationality.value.isEmpty ? null : controller.preferredNationality.value,
                decoration: const InputDecoration(
                  labelText: 'Preferred Nationality',
                ),
                items: controller.nationalityOptions.map((nationality) {
                  return DropdownMenuItem(
                    value: nationality,
                    child: Text(nationality),
                  );
                }).toList(),
                onChanged: controller.updatePreferredNationality,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
} 