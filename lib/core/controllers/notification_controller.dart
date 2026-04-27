import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<String> deletedIds = <String>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeletedIds();
  }

  Stream<QuerySnapshot> get broadcastsStream => _firestore
      .collection('broadcasts')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Future<void> fetchDeletedIds() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('deleted_notifications')
          .get();

      deletedIds.assignAll(snapshot.docs.map((doc) => doc.id));
    } catch (e) {
      print("Error fetching deleted notifications: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Add to local list immediately for responsive UI
      deletedIds.add(id);

      // Persist in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('deleted_notifications')
          .doc(id)
          .set({'deletedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  bool isRead(String id) => true;
  bool isDeleted(String id) => deletedIds.contains(id);

  void markAsRead(String id) {}
  void markAllAsRead() {}
}
