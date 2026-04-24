import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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

        // 2. Get FCM token
        String? token = await _fcm.getToken();

        if (kDebugMode) print("FCM Token: $token");

        if (token != null) {
          _saveToken(token);
        }

        // 3. Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          if (kDebugMode) print("Refreshed Token: $newToken");
          _saveToken(newToken);
        });

        // 4. Foreground messages
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
            );
          }
        });
      } else {
        if (kDebugMode) print('User denied notification permission');
      }
    } catch (e) {
      if (kDebugMode) print("Notification init error: $e");
    }

    return this;
  }

  void _saveToken(String token) {
    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().saveFcmToken(token);
    } else {
      if (kDebugMode) print("UserController not registered");
    }
  }
}
