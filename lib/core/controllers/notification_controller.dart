import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<String> readIds = <String>[].obs;
  final RxList<String> deletedIds = <String>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToUserPreferences();
  }

  void _listenToUserPreferences() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Listen to User Preferences (Read/Deleted IDs)
    _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        readIds.value = List<String>.from(data?['readNotifications'] ?? []);
        deletedIds.value = List<String>.from(data?['deletedNotifications'] ?? []);
        _updateUnreadCount();
      }
    });

    // Also listen to the Broadcasts collection to detect new messages
    _firestore.collection('broadcasts').snapshots().listen((_) {
      _updateUnreadCount();
    });
  }

  Stream<QuerySnapshot> get broadcastsStream => _firestore
      .collection('broadcasts')
      .orderBy('timestamp', descending: true)
      .snapshots();

  void _updateUnreadCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // We need to check the broadcasts against readIds and deletedIds
    final broadcasts = await _firestore.collection('broadcasts').get();
    int count = 0;
    for (var doc in broadcasts.docs) {
      if (!readIds.contains(doc.id) && !deletedIds.contains(doc.id)) {
        count++;
      }
    }
    unreadCount.value = count;
  }

  Future<void> markAsRead(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!readIds.contains(id)) {
      await _firestore.collection('users').doc(user.uid).update({
        'readNotifications': FieldValue.arrayUnion([id])
      });
    }
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final broadcasts = await _firestore.collection('broadcasts').get();
    final allIds = broadcasts.docs.map((d) => d.id).toList();

    await _firestore.collection('users').doc(user.uid).update({
      'readNotifications': FieldValue.arrayUnion(allIds)
    });
  }

  Future<void> deleteNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'deletedNotifications': FieldValue.arrayUnion([id])
    });
  }

  bool isRead(String id) => readIds.contains(id);
  bool isDeleted(String id) => deletedIds.contains(id);
}
