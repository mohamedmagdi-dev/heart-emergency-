// Firebase-based Router with Authentication Guards
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Common
import '../features/common/screens/firebase_welcome_screen.dart';

// Auth
import '../features/auth/screens/firebase_patient_auth_screen.dart';
import '../features/auth/screens/firebase_doctor_auth_screen.dart';
import '../features/auth/screens/firebase_admin_login_screen.dart';
import '../features/auth/screens/doctor_verification_pending_screen.dart';

// Doctor
import '../features/doctor/screens/doctor_dashboard_screen.dart';

// Patient
import '../features/patient/screens/patient_dashboard_screen.dart';
import '../features/patient/screens/emergency_request_screen.dart';
import '../features/patient/screens/simple_payment_screen.dart';
import '../features/patient/screens/simple_wallet_screen.dart';
import '../features/patient/screens/simple_appointment_screen.dart';
import '../features/patient/screens/request_tracking_screen.dart'; // FIXED: Added import

// Admin
import '../features/admin/screens/admin_dashboard_screen.dart';

// Wallet - removed, using simple wallet screen instead

// Auth guard to check user authentication and role
Future<String?> _authGuard(BuildContext context, GoRouterState state, String requiredRole) async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    // Not logged in, redirect based on role
    if (requiredRole == 'patient') return '/patient/auth';
    if (requiredRole == 'doctor') return '/doctor/auth';
    if (requiredRole == 'admin') return '/admin/login';
    return '/';
  }

  try {
    // Get user data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    if (!userDoc.exists) {
      await FirebaseAuth.instance.signOut();
      return '/';
    }

    final userData = userDoc.data()!;
    final userRole = userData['role'] as String?;
    final isVerified = userData['verified'] as bool? ?? false;
    final isBlocked = userData['isBlocked'] as bool? ?? false;

    // Check if user is blocked
    if (isBlocked) {
      await FirebaseAuth.instance.signOut();
      return '/';
    }

    // Check role match
    if (userRole != requiredRole) {
      return '/';
    }

    // Check doctor verification
    if (requiredRole == 'doctor' && !isVerified) {
      if (state.uri.toString() != '/doctor/pending-verification') {
        return '/doctor/pending-verification';
      }
    }

    return null; // Allow access
  } catch (e) {
    print('Auth guard error: $e');
    return '/';
  }
}

// Create app router with Firebase authentication
GoRouter createFirebaseRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.uri.toString();

      // Public routes
      if (path == '/' || 
          path == '/patient/auth' || 
          path == '/doctor/auth' || 
          path == '/admin/login') {
        return null;
      }

      // If not logged in, redirect to home
      if (user == null) {
        return '/';
      }

      // Auto-redirect logged-in users trying to access auth pages
      if (path == '/patient/auth' || path == '/doctor/auth' || path == '/admin/login') {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          if (userDoc.exists) {
            final role = userDoc.data()?['role'];
            final isVerified = userDoc.data()?['verified'] ?? false;
            
            if (role == 'patient') return '/patient/dashboard';
            if (role == 'doctor') {
              return isVerified ? '/doctor/dashboard' : '/doctor/pending-verification';
            }
            if (role == 'admin') return '/admin/dashboard';
          }
        } catch (e) {
          print('Redirect error: $e');
        }
      }

      return null;
    },
    routes: [
      // Home/Welcome page
      GoRoute(
        path: '/',
        builder: (context, state) => const FirebaseWelcomeScreen(),
      ),

      // Patient Auth (Login & Signup)
      GoRoute(
        path: '/patient/auth',
        builder: (context, state) => const FirebasePatientAuthScreen(),
      ),

      // Doctor Auth (Login & Signup)
      GoRoute(
        path: '/doctor/auth',
        builder: (context, state) => const FirebaseDoctorAuthScreen(),
      ),

      // Doctor Verification Pending
      GoRoute(
        path: '/doctor/pending-verification',
        builder: (context, state) => const DoctorVerificationPendingScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),

      // Admin Login
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const FirebaseAdminLoginScreen(),
      ),

      // Patient Routes
      GoRoute(
        path: '/patient/dashboard',
        builder: (context, state) => const PatientDashboardScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/emergency-request',
        builder: (context, state) => const EmergencyRequestScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/payment',
        builder: (context, state) => const SimplePaymentScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/wallet',
        builder: (context, state) => const SimpleWalletScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/appointment',
        builder: (context, state) => const SimpleAppointmentScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      // FIXED: Added missing request tracking route
      GoRoute(
        path: '/patient/request-tracking/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return RequestTrackingScreen(requestId: requestId);
        },
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),

      // Doctor Routes
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) => _authGuard(context, state, 'admin'),
      ),

      // Wallet (accessible by all authenticated users)
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const SimpleWalletScreen(),
        redirect: (context, state) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return '/';
          return null;
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'الصفحة غير موجودة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('العودة للصفحة الرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}

