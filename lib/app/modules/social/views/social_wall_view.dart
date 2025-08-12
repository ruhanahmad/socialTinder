import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../social_controller.dart';

class SocialWallView extends GetView<SocialController> {
  const SocialWallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Wall'),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.darkText,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(context),
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
            // Create Post Section
            _buildCreatePostSection(),
            
            // Posts List
            Expanded(
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.posts.isEmpty
                      ? _buildEmptyState()
                      : _buildPostsList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Card(
      margin: EdgeInsets.all(ScreenUtil().setWidth(15)),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
        child: Column(
          children: [
            // Text Input
            TextField(
              onChanged: controller.onPostTextChanged,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
            ),
            
            SizedBox(height: ScreenUtil().setHeight(10)),
            
            // Image Preview
            Obx(() => controller.newPostImages.isNotEmpty
                ? Container(
                    height: ScreenUtil().setHeight(100),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.newPostImages.length,
                      itemBuilder: (context, index) {
                        final image = controller.newPostImages[index];
                        return Container(
                          margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(image.path),
                                  width: ScreenUtil().setWidth(100),
                                  height: ScreenUtil().setHeight(100),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => controller.removeNewPostImage(image),
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
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink()),
            
            SizedBox(height: ScreenUtil().setHeight(10)),
            
            // Action Buttons
            Row(
              children: [
                IconButton(
                  onPressed: controller.pickImages,
                  icon: const Icon(Icons.photo_library, color: AppTheme.primaryYellow),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: controller.createPost,
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
      itemCount: controller.posts.length,
      itemBuilder: (context, index) {
        final post = controller.posts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final user = post['user'] as Map<String, dynamic>? ?? {};
    final isLiked = post['is_liked_by_user'] as bool? ?? false;
    final likesCount = post['likes_count'] as int? ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.lightYellow,
                  backgroundImage: (user['profile_photo_url'] != null && user['profile_photo_url'].isNotEmpty)
                      ? CachedNetworkImageProvider(user['profile_photo_url'])
                      : null,
                  child: (user['profile_photo_url'] == null || user['profile_photo_url'].isEmpty)
                      ? const Icon(Icons.person, color: AppTheme.darkText)
                      : null,
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(16),
                        ),
                      ),
                      Text(
                        _formatDate(post['created_at']),
                        style: TextStyle(
                          color: AppTheme.lightText,
                          fontSize: ScreenUtil().setSp(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ScreenUtil().setHeight(10)),
            
            // Post Text
            if (post['text']?.isNotEmpty == true)
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
                child: Text(
                  post['text'],
                  style: TextStyle(fontSize: ScreenUtil().setSp(14)),
                ),
              ),
            
            // Post Images
            if (post['images']?.isNotEmpty == true)
              Container(
                height: ScreenUtil().setHeight(200),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post['images'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: post['images'][index],
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(200),
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
                    );
                  },
                ),
              ),
            
            SizedBox(height: ScreenUtil().setHeight(10)),
            
            // Action Buttons
            Row(
              children: [
                InkWell(
                  onTap: () => controller.likePost(post['id'].toString()),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : AppTheme.lightText,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        Text(
                          '$likesCount',
                          style: TextStyle(color: AppTheme.lightText),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(20)),
                InkWell(
                  onTap: () { /* TODO: Implement comment functionality */ },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.comment_outlined, color: AppTheme.lightText),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        Text(
                          '${post['comments_count'] ?? 0}',
                          style: TextStyle(color: AppTheme.lightText),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            Icons.people,
            size: ScreenUtil().setSp(80),
            color: AppTheme.lightText,
          ),
          SizedBox(height: ScreenUtil().setHeight(20)),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              color: AppTheme.lightText,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          Text(
            'Be the first to share something!',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              color: AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final userIdController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: userIdController,
          decoration: const InputDecoration(
            labelText: 'User ID',
            hintText: 'Enter the ID of the user to add',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (userIdController.text.trim().isNotEmpty) {
                controller.addFriend(userIdController.text.trim());
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return DateFormat.yMMMd().format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }
} 