// // Connectivity service to monitor internet connection and update doctor availability
// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
//
// class ConnectivityService {
//   static final ConnectivityService _instance = ConnectivityService._internal();
//   factory ConnectivityService() => _instance;
//   ConnectivityService._internal();
//
//   final Connectivity _connectivity = Connectivity();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   StreamSubscription<ConnectivityResult>? _connectivitySubscription;
//   bool _isListening = false;
//   Timer? _offlineTimer;
//
//   /// Start monitoring connectivity for the current user
//   void startMonitoring() {
//     if (_isListening) return;
//
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     _isListening = true;
//
//     if (kDebugMode) {
//       print('🔗 Starting connectivity monitoring for user: ${user.uid}');
//     }
//
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
//       _handleConnectivityChange,
//       onError: (error) {
//         if (kDebugMode) {
//           print('❌ Connectivity monitoring error: $error');
//         }
//       },
//     );
//   }
//
//   /// Stop monitoring connectivity
//   void stopMonitoring() {
//     if (!_isListening) return;
//
//     _isListening = false;
//     _connectivitySubscription?.cancel();
//     _offlineTimer?.cancel();
//
//     if (kDebugMode) {
//       print('🔗 Stopped connectivity monitoring');
//     }
//   }
//
//   /// Handle connectivity changes
//   void _handleConnectivityChange(ConnectivityResult result) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     // Check if user is a doctor
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     if (!userDoc.exists) return;
//
//     final userData = userDoc.data();
//     if (userData?['role'] != 'doctor') return;
//
//     if (kDebugMode) {
//       print('🔗 Connectivity changed: $result');
//     }
//
//     if (result == ConnectivityResult.none) {
//       // User went offline - start timer to mark as unavailable after 30 seconds
//       _offlineTimer?.cancel();
//       _offlineTimer = Timer(const Duration(seconds: 30), () {
//         _markDoctorAsUnavailable(user.uid);
//       });
//     } else {
//       // User came back online - cancel timer and mark as available
//       _offlineTimer?.cancel();
//       await _markDoctorAsAvailable(user.uid);
//     }
//   }
//
//   /// Mark doctor as unavailable
//   Future<void> _markDoctorAsUnavailable(String doctorId) async {
//     try {
//       await _firestore.collection('users').doc(doctorId).update({
//         'available': false,
//         'lastOfflineTime': FieldValue.serverTimestamp(),
//       });
//
//       if (kDebugMode) {
//         print('👨‍⚕️ Doctor marked as unavailable due to offline status');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ Error marking doctor as unavailable: $e');
//       }
//     }
//   }
//
//   /// Mark doctor as available
//   Future<void> _markDoctorAsAvailable(String doctorId) async {
//     try {
//       await _firestore.collection('users').doc(doctorId).update({
//         'available': true,
//         'lastOnlineTime': FieldValue.serverTimestamp(),
//       });
//
//       if (kDebugMode) {
//         print('👨‍⚕️ Doctor marked as available');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ Error marking doctor as available: $e');
//       }
//     }
//   }
//
//   /// Check current connectivity status
//   Future<ConnectivityResult> getCurrentConnectivity() async {
//     return await _connectivity.checkConnectivity();
//   }
//
//   /// Check if device is currently connected to internet
//   Future<bool> isConnected() async {
//     final result = await _connectivity.checkConnectivity();
//     return result != ConnectivityResult.none;
//   }
// }
