import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_theme.dart';
import '../chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.matches.isEmpty
                ? _buildEmptyState()
                : _buildChatList()),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
      itemCount: controller.matches.length,
      itemBuilder: (context, index) {
        final match = controller.matches[index];
        return _buildChatItem(match);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> match) {
    return FutureBuilder<String>(
      future: controller.getOtherUserName(match['id']),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? 'Unknown';
        
        return Card(
          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryYellow,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(16),
              ),
            ),
            subtitle: Text(
              match['lastMessage'] ?? 'Start a conversation!',
              style: TextStyle(
                color: AppTheme.lightText,
                fontSize: ScreenUtil().setSp(14),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.primaryYellow,
            ),
            onTap: () => _openChat(match['id'], userName),
          ),
        );
      },
    );
  }

  void _openChat(String matchId, String userName) {
    controller.loadMessages(matchId);
    Get.to(() => _buildChatScreen(matchId, userName));
  }

  Widget _buildChatScreen(String matchId, String userName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.darkText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
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
            // Messages List
            Expanded(
              child: Obx(() => ListView.builder(
                padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              )),
            ),
            
            // Message Input
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateNewMessage,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Obx(() => IconButton(
                    onPressed: controller.newMessage.value.trim().isNotEmpty
                        ? () => controller.sendMessage(controller.newMessage.value)
                        : null,
                    icon: Icon(
                      Icons.send,
                      color: controller.newMessage.value.trim().isNotEmpty
                          ? AppTheme.primaryYellow
                          : AppTheme.lightText,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['senderId'] == controller.currentUserId;
    
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ScreenUtil().setHeight(10),
          left: isCurrentUser ? ScreenUtil().setWidth(50) : 0,
          right: isCurrentUser ? 0 : ScreenUtil().setWidth(50),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppTheme.primaryYellow : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isCurrentUser ? AppTheme.darkText : AppTheme.darkText,
            fontSize: ScreenUtil().setSp(14),
          ),
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
            Icons.chat_bubble_outline,
            size: ScreenUtil().setSp(80),
            color: AppTheme.lightText,
          ),
          SizedBox(height: ScreenUtil().setHeight(20)),
          Text(
            'No matches yet',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              color: AppTheme.lightText,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          Text(
            'Start swiping to find your Caribbean connection!',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              color: AppTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 