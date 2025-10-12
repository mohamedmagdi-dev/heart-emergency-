// Firebase-based Router with Authentication Guards

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Common
import '../data/models/user_model.dart';
// Admin
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/auth/screens/doctor_verification_pending_screen.dart';
import '../features/auth/screens/firebase_admin_login_screen.dart';
import '../features/auth/screens/firebase_doctor_auth_screen.dart';
// Auth
import '../features/auth/screens/firebase_patient_auth_screen.dart';
import '../features/common/screens/firebase_welcome_screen.dart';
// Doctor
import '../features/doctor/screens/doctor_dashboard_screen.dart';
import '../features/doctor/screens/doctor_emergancy_map.dart';
import '../features/doctor/screens/doctor_notification_screen.dart';
import '../features/doctor/screens/doctor_profile_screen.dart';
import '../features/doctor/screens/doctor_requests_history_screen.dart';
import '../features/doctor/screens/doctor_requests_screen.dart';
import '../features/doctor/screens/doctor_reviews_screen.dart';
import '../features/doctor/screens/doctor_settings_screen.dart';
import '../features/doctor/screens/doctor_statistics_screen.dart';
import '../features/doctor/screens/forget_password_screen.dart';
import '../features/doctor/screens/rate_patient_screen.dart';
import '../features/patient/screens/emergency_request_screen.dart';
import '../features/patient/screens/medical_file_screen.dart';
import '../features/patient/screens/nearby_doctors_screen.dart';
import '../features/patient/screens/patient_appointment.dart';
// Patient
import '../features/patient/screens/patient_dashboard_screen.dart';
import '../features/patient/screens/patient_notification_screen.dart';
import '../features/patient/screens/patient_requests_screen.dart';
import '../features/patient/screens/patient_settings_screen.dart';
import '../features/patient/screens/rate_doctor_screen.dart';
import '../features/patient/screens/rated_doctors_screen.dart';
import '../features/patient/screens/request_history_screen.dart';
import '../features/patient/screens/request_tracking_screen.dart'; // FIXED: Added import
import '../features/splash/splash_screen.dart';


// Auth guard to check user authentication and role
Future<String?> _authGuard(
  BuildContext context,
  GoRouterState state,
  String requiredRole,
) async {
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
    // initialLocation: '/splash',
    // redirect: (context, state) async {
    //   final user = FirebaseAuth.instance.currentUser;
    //   final path = state.uri.toString();
    //
    //   // If user is logged in and trying to access splash, home, or auth pages
    //   if (user != null &&
    //       (path == '/splash' ||
    //           path == '/' ||
    //           path == '/patient/auth' ||
    //           path == '/doctor/auth' ||
    //           path == '/admin/login')) {
    //     try {
    //       final userDoc = await FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(user.uid)
    //           .get();
    //
    //       if (userDoc.exists) {
    //         final role = userDoc.data()?['role'];
    //         final isVerified = userDoc.data()?['verified'] ?? false;
    //         final isBlocked = userDoc.data()?['isBlocked'] ?? false;
    //
    //         // If user is blocked, sign out and redirect to home
    //         if (isBlocked) {
    //           await FirebaseAuth.instance.signOut();
    //           return '/';
    //         }
    //
    //         // Redirect based on role
    //         if (role == 'patient') return '/patient/dashboard';
    //         if (role == 'doctor') {
    //           return isVerified
    //               ? '/doctor/dashboard'
    //               : '/doctor/pending-verification';
    //         }
    //         if (role == 'admin') return '/admin/dashboard';
    //       }
    //     } catch (e) {
    //       print('Redirect error: $e');
    //     }
    //   }
    //
    //   // Public routes
    //   if (path == '/' ||
    //       path == '/patient/auth' ||
    //       path == '/doctor/auth' ||
    //       path == '/admin/login' ||
    //       path == '/doctor/forgot-password') {
    //     return null;
    //   }
    //
    //   // If not logged in, redirect to home
    //   if (user == null) {
    //     return '/';
    //   }
    //
    //   return null;
    // },
    initialLocation: '/splash',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.uri.toString();

      // ✅ الإصلاح: تجاهل أي redirect أثناء شاشة السبلاتش
      if (path == '/splash') return null;

      // ✅ لو المستخدم داخل بالفعل وحاول يروح auth أو splash أو home
      if (user != null &&
          (path == '/splash' ||
              path == '/' ||
              path == '/patient/auth' ||
              path == '/doctor/auth' ||
              path == '/admin/login')) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data();
            final role = data?['role'];
            final isVerified = data?['verified'] ?? false;
            final isBlocked = data?['isBlocked'] ?? false;

            if (isBlocked) {
              await FirebaseAuth.instance.signOut();
              return '/';
            }

            // ✅ توجيه حسب الدور
            if (role == 'patient') return '/patient/dashboard';
            if (role == 'doctor') {
              return isVerified
                  ? '/doctor/dashboard'
                  : '/doctor/pending-verification';
            }
            if (role == 'admin') return '/admin/dashboard';
          }
        } catch (e) {
          debugPrint('Redirect error: $e');
        }
      }

      // ✅ المسارات العامة
      if (path == '/' ||
          path == '/patient/auth' ||
          path == '/doctor/auth' ||
          path == '/admin/login' ||
          path == '/doctor/forgot-password') {
        return null;
      }

      // ✅ لو المستخدم مش مسجل دخول
      if (user == null) {
        return '/';
      }

      return null;
    },

    routes: [
      // splash screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

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
      GoRoute(
        path: '/patient/notifications',
        builder: (context, state) {
          final userId = state.extra as String;
          return PatientNotificationsScreen(userId: userId);
        },
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
      // forgetPassword routes
      GoRoute(
        path: '/doctor/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
      // New doctor request routes
      GoRoute(
        path: '/patient/doctor-appointment',
        builder: (context, state) => const AppointmentBookingPage(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/my-requests',
        builder: (context, state) => const PatientRequestsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/rate-doctor',
        builder: (context, state) {
          final doctor = state.extra as UserModel?;
          final requestId = state.uri.queryParameters['requestId'];
          if (doctor == null) {
            return const Scaffold(
              body: Center(child: Text('خطأ: لم يتم العثور على بيانات الطبيب')),
            );
          }
          return RateDoctorScreen(doctor: doctor, requestId: requestId);
        },
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      // New patient routes
      GoRoute(
        path: '/patient/nearby-doctors',
        builder: (context, state) => const NearbyDoctorsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/rated-doctors',
        builder: (context, state) => const RatedDoctorsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/requests-history',
        builder: (context, state) => const RequestHistoryScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/medical-profile',
        builder: (context, state) => const MedicalFileScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),
      GoRoute(
        path: '/patient/settings',
        builder: (context, state) => const PatientSettingsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'patient'),
      ),

      // Doctor Routes
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),
      GoRoute(
        path: '/doctor/profile',
        builder: (context, state) => const DoctorProfileScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),
      GoRoute(
        path: '/doctor/requests-history',
        builder: (context, state) => const DoctorRequestsHistoryScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),
      GoRoute(
        path: '/doctor/requests',
        builder: (context, state) => const DoctorRequestsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),
      GoRoute(
        path: '/doctor/analytics',
        builder: (context, state) => const DoctorStatisticsScreen(),
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),
      GoRoute(
        path: '/doctor/rate-patient',
        builder: (context, state) {
          final patient = state.extra as UserModel?;
          final requestId = state.uri.queryParameters['requestId'];
          if (patient == null) {
            return const Scaffold(
              body: Center(child: Text('خطأ: لم يتم العثور على بيانات المريض')),
            );
          }
          return RatePatientScreen(patient: patient, requestId: requestId);
        },
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
      ),

      // doctor notification routes
      GoRoute(
        path: '/doctor/notifications',
        builder: (context, state) {
          return DoctorNotificationsScreen();
        },
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) => _authGuard(context, state, 'admin'),
      ),
      GoRoute(
        path: '/doctor/reviews',
        builder: (context, state) {
          final doctorId = state.extra as String;
          return DoctorReviewsScreen(doctorId: doctorId);
        },
      ),

      // GoRoute(
      //   path: "/doctor/emergency/map",
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //
      //     if (extra == null ||
      //         extra['request'] == null ||
      //         extra['patient'] == null) {
      //       return const Scaffold(
      //         body: Center(
      //           child: Text('خطأ: لم يتم تمرير بيانات الحالة أو المريض'),
      //         ),
      //       );
      //     }
      //
      //     final request = extra['request'] as RequestModel;
      //     final patient = extra['patient'] as UserModel;
      //
      //     return DoctorEmergencyMapScreen(
      //       request: request,
      //       patient: patient,
      //     );
      //   },
      // ),
      GoRoute(
        path: '/doctor/emergency/map',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final lat = double.tryParse(q['lat'] ?? '');
          final lng = double.tryParse(q['lng'] ?? '');
          final name = q['name'];
          if (lat == null || lng == null) {
            return const Scaffold(
              body: Center(child: Text('إحداثيات غير صالحة')),
            );
          }
          return DoctorEmergencyMapScreen(
            destLat: lat,
            destLng: lng,
            patientName: name,
          );
        },
        redirect: (context, state) => _authGuard(context, state, 'doctor'),
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
      GoRoute(
        path: '/doctor/settings',
        builder: (context, state) => const DoctorSettingsScreen(),
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
