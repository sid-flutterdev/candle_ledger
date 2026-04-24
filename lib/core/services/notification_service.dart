import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<NotificationService> init() async {
    try {
      // 1. Request permissions (iOS + Android 13+)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) print('User granted permission');

        // 2. Subscribe to "all" topic for broadcasts
        await _fcm.subscribeToTopic("all");

        // 3. Get FCM token
        String? token = await _fcm.getToken();

        if (kDebugMode) print("FCM Token: $token");

        if (token != null) {
          _saveToken(token);
        }

        // 4. Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          if (kDebugMode) print("Refreshed Token: $newToken");
          _saveToken(newToken);
        });

        // 5. Foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('Foreground message received');
            print('Data: ${message.data}');
          }

          if (message.notification != null) {
            Get.snackbar(
              message.notification!.title ?? "Notification",
              message.notification!.body ?? "",
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF1A1A1A),
              colorText: Colors.white,
            );
          }
        });

        // 6. Listener for Firestore Broadcasts (Real-time fallback)
        _listenForFirestoreBroadcasts();
      } else {
        if (kDebugMode) print('User denied notification permission');
      }
    } catch (e) {
      if (kDebugMode) print("Notification init error: $e");
    }

    return this;
  }

  void _listenForFirestoreBroadcasts() {
    // We only listen for broadcasts created after the app was opened
    final startTime = DateTime.now();

    FirebaseFirestore.instance
        .collection('broadcasts')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startTime))
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          
          Get.snackbar(
            data['title'] ?? "Broadcast",
            data['message'] ?? "",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
            borderColor: Colors.purpleAccent.withValues(alpha: 0.3),
            borderWidth: 1,
            icon: const Icon(Icons.campaign_rounded, color: Colors.purpleAccent),
          );
        }
      }
    });
  }

  void _saveToken(String token) {
    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().saveFcmToken(token);
    } else {
      if (kDebugMode) print("UserController not registered");
    }
  }
}
