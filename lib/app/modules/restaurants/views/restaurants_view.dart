import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../restaurants_controller.dart';

class RestaurantsView extends GetView<RestaurantsController> {
  const RestaurantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.darkText,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showAddRestaurantDialog(context),
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
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildRestaurantsList()),
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
      itemCount: controller.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = controller.restaurants[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image
          if (restaurant['images']?.isNotEmpty == true)
            Container(
              height: ScreenUtil().setHeight(200),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl: restaurant['images'][0],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.lightYellow,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.lightYellow,
                    child: const Icon(Icons.restaurant, size: 80),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant['name'] ?? 'Restaurant',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(18),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.primaryYellow, size: ScreenUtil().setSp(20)),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        Text(
                          '${(restaurant['rating'] ?? 0.0).toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: ScreenUtil().setHeight(5)),
                
                // Description
                Text(
                  restaurant['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    color: AppTheme.lightText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: ScreenUtil().setSp(16), color: AppTheme.lightText),
                    SizedBox(width: ScreenUtil().setWidth(5)),
                    Expanded(
                      child: Text(
                        restaurant['address'] ?? 'Address not available',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          color: AppTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                // Specials
                if (restaurant['specials']?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Specials:',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(5)),
                      ...(restaurant['specials'] as List).take(3).map((special) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(2)),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, size: ScreenUtil().setSp(12), color: AppTheme.primaryYellow),
                              SizedBox(width: ScreenUtil().setWidth(5)),
                              Expanded(
                                child: Text(
                                  special,
                                  style: TextStyle(fontSize: ScreenUtil().setSp(12)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                
                SizedBox(height: ScreenUtil().setHeight(15)),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showRestaurantDetails(restaurant),
                        child: const Text('View Details'),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    ElevatedButton(
                      onPressed: () => _showRatingDialog(restaurant['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.oceanBlue,
                      ),
                      child: const Text('Rate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    Get.dialog(
      AlertDialog(
        title: Text(restaurant['name'] ?? 'Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (restaurant['description']?.isNotEmpty == true) ...[
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(restaurant['description']),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              if (restaurant['address']?.isNotEmpty == true) ...[
                Text(
                  'Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(restaurant['address']),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              if (restaurant['phone']?.isNotEmpty == true) ...[
                Text(
                  'Phone:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(restaurant['phone']),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              if (restaurant['menuItems']?.isNotEmpty == true) ...[
                Text(
                  'Menu Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(restaurant['menuItems'] as List).map((item) {
                  return Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    child: Text('• $item'),
                  );
                }),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              if (restaurant['specials']?.isNotEmpty == true) ...[
                Text(
                  'Specials:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(restaurant['specials'] as List).map((special) {
                  return Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    child: Text('• $special'),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(String restaurantId) {
    double rating = 3.0;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Rate Restaurant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How would you rate this restaurant?'),
            SizedBox(height: ScreenUtil().setHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    rating = index + 1.0;
                  },
                  child: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryYellow,
                    size: ScreenUtil().setSp(30),
                  ),
                );
              }),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Text('${rating.toInt()} stars'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.rateRestaurant(restaurantId, rating);
              Get.back();
            },
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }

  void _showAddRestaurantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final websiteController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name *',
                ),
                onChanged: controller.updateRestaurantName,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                ),
                maxLines: 3,
                onChanged: controller.updateDescription,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                ),
                onChanged: controller.updateAddress,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
                onChanged: controller.updatePhone,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                ),
                onChanged: controller.updateWebsite,
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
              controller.createRestaurant();
              Get.back();
            },
            child: const Text('Add Restaurant'),
          ),
        ],
      ),
    );
  }
} 