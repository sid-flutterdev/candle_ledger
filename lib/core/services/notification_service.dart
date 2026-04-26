import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

        // 2. Subscribe to "all" topic for broadcasts (Common for everyone)
        await _fcm.subscribeToTopic("all");

        // 5. Foreground messages (FCM)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
      }
    } catch (e) {
      if (kDebugMode) print("Notification init error: $e");
    }

    return this;
  }
}
