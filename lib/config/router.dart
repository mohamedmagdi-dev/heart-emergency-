import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Common
import '../features/common/screens/landing_page.dart';
import '../features/common/screens/login_page.dart';

// Auth
import '../features/auth/screens/doctor_auth_screen.dart';
import '../features/auth/screens/patient_auth_screen.dart';
import '../features/auth/screens/admin_auth_screen.dart';

// Doctor
import '../features/doctor/screens/doctor_dashboard.dart';
import '../features/doctor/screens/doctor_registration.dart';

// Patient
import '../features/patient/screens/patient_dashboard.dart';
import '../features/patient/screens/emergency_request.dart';
import '../features/patient/screens/patient_payment.dart';
import '../features/patient/screens/patient_appointment.dart';

// Admin
import '../features/admin/screens/admin_dashboard.dart';

// Wallet
import '../features/wallet/screens/wallet_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) =>  LandingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Auth
    GoRoute(path: '/doctor/auth', builder: (context, state) => const DoctorAuthScreen()),
    GoRoute(path: '/doctor/register', builder: (context, state) => const DoctorRegistrationScreen()),
    GoRoute(path: '/doctor/dashboard', builder: (context, state) => const DoctorDashboardScreen()),

    GoRoute(path: '/patient/auth', builder: (context, state) => const PatientAuthScreen()),
    GoRoute(path: '/patient/dashboard', builder: (context, state) => const PatientDashboardScreen()),
    GoRoute(path: '/patient/payment', builder: (context, state) => const PatientPaymentScreen()),
    GoRoute(path: '/patient/appointment', builder: (context, state) => const PatientAppointmentScreen()),

    // Emergency
    GoRoute(path: '/emergency-request', builder: (context, state) => const EmergencyRequestScreen()),

    // Admin
    GoRoute(path: '/admin/auth', builder: (context, state) => const AdminAuthScreen()),
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),

    // Wallet
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
  ],
);
