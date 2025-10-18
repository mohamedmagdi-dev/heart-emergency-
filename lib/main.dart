// // CHANGED_FOR_FIREBASE_INTEGRATION: Added Firebase initialization with auto-login
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
//
// import 'config/firebase_router.dart';
// import 'firebase_options.dart';
// import 'core/cache/shared_pref_cache.dart';
// import 'data/local/hive_manager.dart';
// // Removed offline data initializer - using Firebase services now
// import 'services/fcm_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // CHANGED_FOR_FIREBASE_INTEGRATION: Initialize Firebase with options
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // CHANGED_FOR_FIREBASE_INTEGRATION: Enable offline persistence for Firestore
//   FirebaseFirestore.instance.settings = const Settings(
//     persistenceEnabled: true,
//     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
//   );
//
//   // Initialize Hive for local caching
//   await Hive.initFlutter();
//   await HiveManager.init();
//
//   // Initialize SharedPreferences
//   await SharedPreference.init();
//
//   // Offline data initialization removed - using Firebase services now
//
//   // CHANGED_FOR_FIREBASE_INTEGRATION: Initialize FCM service
//   final fcmService = FCMService();
//   await fcmService.initialize();
//
//   runApp(const ProviderScope(child: EmergencyApp()));
// }
//
// class EmergencyApp extends StatelessWidget {
//   const EmergencyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: MaterialApp.router(
//         debugShowCheckedModeBanner: false,
//         title: 'من قلب الطوارئ',
//         routerConfig: createFirebaseRouter(),
//         theme: ThemeData(
//           primarySwatch: Colors.red,
//           fontFamily: 'Janna',
//           useMaterial3: true,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Colors.red,
//             brightness: Brightness.light,
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             filled: true,
//             fillColor: Colors.grey[100],
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart_emergency/services/fcm_service.dart';
import 'package:hive_flutter/adapters.dart';

import 'config/firebase_router.dart';
import 'core/cache/shared_pref_cache.dart';
import 'core/cubits/theme_cubit.dart';
import 'core/utils/shared_preferences_helper.dart';
import 'data/local/hive_manager.dart';
import 'features/notifications/forground_background_notfications.dart';
import 'features/notifications/notfication_services.dart';
import 'firebase_options.dart';
import 'services/notification_listener.dart';

// // 1. الدالة اللي بتشتغل لما ييجي إشعار والتطبيق مقفول تماماً
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling background message: ${message.messageId}");
// }


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final localPlugin = NotificationService.plugin;
  final firebaseMessagingService = FirebaseMessagingService(localPlugin);
  firebaseMessagingService.listenToForegroundMessages();

  // شغل التعامل مع ضغطات المستخدم على الإشعارات
  firebaseMessagingService.handleNotificationClick();
  firebaseMessagingService.handleTerminatedMessage();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await Hive.initFlutter();
  await HiveManager.init();
  await SharedPreference.init();

  final fcmService = FCMService();
  await fcmService.initialize();

  // Initialize SharedPreferencesHelper
  await SharedPreferencesHelper.init();

  final themeCubit = ThemeCubit();

  // ✅ Cache the router once so it doesn't rebuild on theme change
  final router = createFirebaseRouter();

  // Initialize local notifications service
  // Keep icon default to app launcher icon
  // No UI changes are introduced here
  await NotificationService.init();

  // Start Firestore notifications listener after auth is ready
  // If the user is not authenticated, it will no-op
  NotificationListenerService().start();
  // // تهيئة إشعارات التطبيق
  // await NotificationService().initialize(
  //   androidDefaultIcon: '@mipmap/ic_launcher',
  // );

  // تسجيل background handler

  runApp(
    BlocProvider.value(
      value: themeCubit,
      child: ProviderScope(child: EmergencyApp(router: router)),
    ),
  );
}

class EmergencyApp extends StatelessWidget {
  final RouterConfig<Object> router;
  const EmergencyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'من قلب الطوارئ',
            routerConfig: router,
            theme: theme,
            themeMode: ThemeMode.system,
          ),
        );
      },
    );
  }
}
