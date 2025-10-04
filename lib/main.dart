// CHANGED_FOR_FIREBASE_INTEGRATION: Added Firebase initialization with auto-login
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/firebase_router.dart';
import 'firebase_options.dart';
import 'core/cache/shared_pref_cache.dart';
import 'data/local/hive_manager.dart';
// Removed offline data initializer - using Firebase services now
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // CHANGED_FOR_FIREBASE_INTEGRATION: Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // CHANGED_FOR_FIREBASE_INTEGRATION: Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Initialize Hive for local caching
  await Hive.initFlutter();
  await HiveManager.init();
  
  // Initialize SharedPreferences
  await SharedPreference.init();
  
  // Offline data initialization removed - using Firebase services now
  
  // CHANGED_FOR_FIREBASE_INTEGRATION: Initialize FCM service
  final fcmService = FCMService();
  await fcmService.initialize();
  
  runApp(const ProviderScope(child: EmergencyApp()));
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'من قلب الطوارئ',
        routerConfig: createFirebaseRouter(),
        theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Janna',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
