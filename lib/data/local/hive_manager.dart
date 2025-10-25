import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String users = 'users';
  static const String patients = 'patients';
  static const String doctors = 'doctors';
  static const String emergencyRequests = 'emergencyRequests';
  static const String appointments = 'appointments';
  static const String wallets = 'wallets';
  static const String transactions = 'transactions';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
  static const String systemSettings = 'systemSettings';
  static const String currentUser = 'currentUser';
  static const String outbox = 'outbox';
}

class HiveManager {
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters here if needed
    // Hive.registerAdapter(UserAdapter());
    
    // Open all required boxes
    await Hive.openBox(HiveBoxes.users);
    await Hive.openBox(HiveBoxes.patients);
    await Hive.openBox(HiveBoxes.doctors);
    await Hive.openBox(HiveBoxes.emergencyRequests);
    await Hive.openBox(HiveBoxes.appointments);
    await Hive.openBox(HiveBoxes.wallets);
    await Hive.openBox(HiveBoxes.transactions);
    await Hive.openBox(HiveBoxes.reviews);
    await Hive.openBox(HiveBoxes.notifications);
    await Hive.openBox(HiveBoxes.systemSettings);
    await Hive.openBox(HiveBoxes.currentUser);
    await Hive.openBox(HiveBoxes.outbox);
  }
}
