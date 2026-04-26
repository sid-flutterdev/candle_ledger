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
        actions: const [],
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
            return _buildNotificationCard(doc.id, data);
          },
        );
        },
      ),
    );
  }



  Widget _buildNotificationCard(String id, Map<String, dynamic> data) {
    final DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final String timeStr = timestamp != null
        ? DateFormat('dd MMM, hh:mm a').format(timestamp)
        : 'Recently';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.purpleAccent,
                size: 24,
              ),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                      color: Colors.white70,
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
  }
}
