import 'package:candle_ledger/core/controllers/notification_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => controller.markAllAsRead(),
                child: Text(
                  "Mark all as read",
                  style: GoogleFonts.outfit(
                    color: Colors.purpleAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.broadcastsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading notifications",
                style: GoogleFonts.outfit(color: Colors.white38),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            );
          }

          // Filter out deleted notifications
          final allDocs = snapshot.data?.docs ?? [];
          final notifications = allDocs
              .where((doc) => !controller.isDeleted(doc.id))
              .toList();

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white10,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildDismissibleCard(doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(String id, Map<String, dynamic> data) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        controller.deleteNotification(id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
      ),
      child: GestureDetector(
        onTap: () => controller.markAsRead(id),
        child: _buildNotificationCard(id, data),
      ),
    );
  }

  Widget _buildNotificationCard(String id, Map<String, dynamic> data) {
    final DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final String timeStr = timestamp != null
        ? DateFormat('dd MMM, hh:mm a').format(timestamp)
        : 'Recently';

    return Obx(() {
      final isRead = controller.isRead(id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isRead ? Colors.white10 : Colors.purpleAccent)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: isRead ? Colors.white38 : Colors.purpleAccent,
                      size: 24,
                    ),
                  ),
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.purpleAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Broadcast',
                            style: GoogleFonts.outfit(
                              color: isRead ? Colors.white60 : Colors.white,
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: GoogleFonts.outfit(
                            color: Colors.white24,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['message'] ?? '',
                      style: GoogleFonts.outfit(
                        color: isRead ? Colors.white38 : Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
