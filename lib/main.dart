import 'package:candle_ledger/core/constants/app_constants.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/transaction_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/controllers/risk_management_controller.dart';
import 'package:candle_ledger/core/controllers/notification_controller.dart';
import 'package:candle_ledger/core/repositories/account_repository.dart';
import 'package:candle_ledger/core/repositories/trade_repository.dart';
import 'package:candle_ledger/core/repositories/transaction_repository.dart';
import 'package:candle_ledger/core/repositories/goal_repository.dart';
import 'package:candle_ledger/core/controllers/goal_controller.dart';
import 'package:candle_ledger/core/services/storage_service.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:candle_ledger/core/theme/app_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Proper Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Enable Offline Persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    debugPrint("Firebase initialized successfully with offline support");
  } catch (e) {
    debugPrint("CRITICAL: Firebase initialization failed: $e");
  }

  // -------------------------
  // Dependency Injection (Order matters: Services/Repos -> Controllers)
  // -------------------------

  Get.put(FirebaseAuthService());

  // Repositories
  Get.put(AccountRepository());
  Get.put(TradeRepository());
  Get.put(TransactionRepository());
  Get.put(GoalRepository());

  // Services
  Get.put(StorageService());
  await Get.putAsync(() => NotificationService().init());

  // Controllers
  Get.put(AccountController());
  Get.put(TradeController());
  Get.put(TransactionController());
  Get.put(UserController());
  Get.put(NotificationController());
  Get.put(RiskManagementController(), permanent: true);
  Get.put(NavigationController());
  Get.put(GoalController());

  // -------------------------
  // System UI
  // -------------------------

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const ScreenSplash(),
    );
  }
}

//CandleAdminAccess
