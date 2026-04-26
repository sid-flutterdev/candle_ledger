import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt unreadCount = 0.obs;

  Stream<QuerySnapshot> get broadcastsStream => _firestore
      .collection('broadcasts')
      .orderBy('timestamp', descending: true)
      .snapshots();

  void markAsRead(String id) {
    // Logic removed: common for everyone
  }

  void markAllAsRead() {
    // Logic removed: common for everyone
  }

  void deleteNotification(String id) {
    // Logic removed: common for everyone
  }

  bool isRead(String id) => true; // All are "read" or no unread state
  bool isDeleted(String id) => false;
}
