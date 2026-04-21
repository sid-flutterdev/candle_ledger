import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/transaction_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:candle_ledger/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Proper Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("CRITICAL: Firebase initialization failed: $e");
    debugPrint("Ensure google-services.json is in android/app/");
  }

  // -------------------------
  // Hive Initialization
  // -------------------------
  await Hive.initFlutter();

  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TradeSegmentAdapter());
  Hive.registerAdapter(OptionTypeAdapter());
  Hive.registerAdapter(TradeTypeAdapter());
  Hive.registerAdapter(TradeAdapter());

  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Trade>('trades');
  await Hive.openBox('settings');
  await Hive.openBox('transactions');

  // -------------------------
  // Dependency Injection (AFTER Firebase init)
  // -------------------------
  Get.put(FirebaseAuthService());
  Get.put(AccountController());
  Get.put(TradeController());
  Get.put(TransactionController());
  Get.put(UserController());
  Get.put(NavigationController());

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
