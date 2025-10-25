// // Doctor earnings service for tracking and calculating financial data
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../data/models/earnings_model.dart';
// import '../data/models/request_model.dart';
//
// class EarningsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   static const String earningsCollection = 'doctor_earnings';
//   static const String requestsCollection = 'requests';
//   static const double defaultCommissionRate = 0.12; // 12%
//
//   /// Get doctor earnings summary
//   Future<DoctorEarnings?> getDoctorEarnings(String doctorId) async {
//     try {
//       final doc = await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .get();
//
//       if (doc.exists) {
//         return DoctorEarnings.fromMap(doc.data()!);
//       } else {
//         // Create empty earnings document if it doesn't exist
//         await _createEmptyEarnings(doctorId);
//         return await getDoctorEarnings(doctorId); // Recursive call to get the created document
//       }
//     } catch (e) {
//       print('Error getting doctor earnings: $e');
//       return null;
//     }
//   }
//
//   /// Stream doctor earnings for real-time updates
//   Stream<DoctorEarnings?> streamDoctorEarnings(String doctorId) {
//     return _firestore
//         .collection(earningsCollection)
//         .doc(doctorId)
//         .snapshots()
//         .map((doc) {
//       if (doc.exists) {
//         return DoctorEarnings.fromMap(doc.data()!);
//       } else {
//         // Return null if document doesn't exist - let the UI handle initialization
//         return null;
//       }
//     });
//   }
//
//   /// Calculate and update doctor earnings from completed requests
//   Future<void> updateDoctorEarnings(String doctorId) async {
//     try {
//       // Get all completed requests for this doctor
//       final completedRequests = await _firestore
//           .collection(requestsCollection)
//           .where('doctorId', isEqualTo: doctorId)
//           .where('status', isEqualTo: 'completed')
//           .get();
//
//       if (completedRequests.docs.isEmpty) {
//         // No completed requests, create empty earnings record
//         await _createEmptyEarnings(doctorId);
//         return;
//       }
//
//       // Calculate totals
//       int totalRequests = completedRequests.docs.length;
//       double totalEarnings = 0.0;
//       DateTime? lastRequestDate;
//
//       for (final doc in completedRequests.docs) {
//         final data = doc.data();
//         final price = (data['finalPrice'] as num?)?.toDouble() ??
//                      (data['price'] as num?)?.toDouble() ?? 0.0;
//         totalEarnings += price;
//
//         // Track the most recent request date
//         final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
//         if (completedAt != null) {
//           if (lastRequestDate == null || completedAt.isAfter(lastRequestDate)) {
//             lastRequestDate = completedAt;
//           }
//         }
//       }
//
//       // Calculate commission and net earnings
//       final commissionRate = defaultCommissionRate;
//       final platformCommission = totalEarnings * commissionRate;
//       final netEarnings = totalEarnings - platformCommission;
//
//       // Get doctor's currency
//       final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
//       final doctorData = doctorDoc.data();
//       final currency = doctorData?['currency'] ?? 'EGP';
//
//       // Check if earnings document exists and compare values
//       final existingEarningsDoc = await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .get();
//
//       if (existingEarningsDoc.exists) {
//         final existingData = existingEarningsDoc.data()!;
//         final existingTotalRequests = existingData['totalRequests'] as int? ?? 0;
//         final existingTotalEarnings = (existingData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
//
//         // Only update if values have changed
//         if (existingTotalRequests == totalRequests &&
//             existingTotalEarnings == totalEarnings) {
//           return; // No changes needed
//         }
//       }
//
//       // Create or update earnings record
//       final earnings = DoctorEarnings(
//         doctorId: doctorId,
//         totalRequests: totalRequests,
//         totalEarnings: totalEarnings,
//         platformCommission: platformCommission,
//         netEarnings: netEarnings,
//         currency: currency,
//         lastUpdated: DateTime.now(),
//         lastRequestDate: lastRequestDate,
//       );
//
//       await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .set(earnings.toMap());
//
//     } catch (e) {
//       print('Error updating doctor earnings: $e');
//       throw 'فشل في تحديث أرباح الطبيب: $e';
//     }
//   }
//
//   /// Create empty earnings record for new doctor
//   Future<void> _createEmptyEarnings(String doctorId) async {
//     try {
//       // Get doctor's currency
//       final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
//       final doctorData = doctorDoc.data();
//       final currency = doctorData?['currency'] ?? 'EGP';
//
//       final earnings = DoctorEarnings(
//         doctorId: doctorId,
//         totalRequests: 0,
//         totalEarnings: 0.0,
//         platformCommission: 0.0,
//         netEarnings: 0.0,
//         currency: currency,
//         lastUpdated: DateTime.now(),
//       );
//
//       await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .set(earnings.toMap());
//     } catch (e) {
//       print('Error creating empty earnings: $e');
//       // If we can't get doctor's currency, create with default
//       final earnings = DoctorEarnings(
//         doctorId: doctorId,
//         totalRequests: 0,
//         totalEarnings: 0.0,
//         platformCommission: 0.0,
//         netEarnings: 0.0,
//         currency: 'EGP',
//         lastUpdated: DateTime.now(),
//       );
//
//       await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .set(earnings.toMap());
//     }
//   }
//
//   /// Get earnings breakdown for a specific period
//   Future<EarningsBreakdown> getEarningsBreakdown({
//     required String doctorId,
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     try {
//       Query query = _firestore
//           .collection(requestsCollection)
//           .where('doctorId', isEqualTo: doctorId)
//           .where('status', isEqualTo: 'completed');
//
//       if (startDate != null) {
//         query = query.where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
//       }
//       if (endDate != null) {
//         query = query.where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
//       }
//
//       final snapshot = await query.get();
//       double totalEarnings = 0.0;
//
//       for (final doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final price = (data['finalPrice'] as num?)?.toDouble() ??
//                      (data['price'] as num?)?.toDouble() ?? 0.0;
//         totalEarnings += price;
//       }
//
//       // Get doctor's currency
//       final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
//       final doctorData = doctorDoc.data();
//       final currency = doctorData?['currency'] ?? 'EGP';
//
//       return EarningsBreakdown.calculate(
//         totalEarnings: totalEarnings,
//         commissionRate: defaultCommissionRate,
//         currency: currency,
//       );
//     } catch (e) {
//       print('Error getting earnings breakdown: $e');
//       throw 'فشل في حساب تفاصيل الأرباح: $e';
//     }
//   }
//
//   /// Get recent completed requests for earnings history
//   Future<List<RequestModel>> getRecentCompletedRequests({
//     required String doctorId,
//     int limit = 10,
//   }) async {
//     try {
//       final snapshot = await _firestore
//           .collection(requestsCollection)
//           .where('doctorId', isEqualTo: doctorId)
//           .where('status', isEqualTo: 'completed')
//           .orderBy('completedAt', descending: true)
//           .limit(limit)
//           .get();
//
//       return snapshot.docs
//           .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
//           .toList();
//     } catch (e) {
//       print('Error getting recent completed requests: $e');
//       return [];
//     }
//   }
//
//   /// Stream recent completed requests for real-time updates
//   Stream<List<RequestModel>> streamRecentCompletedRequests({
//     required String doctorId,
//     int limit = 10,
//   }) {
//     return _firestore
//         .collection(requestsCollection)
//         .where('doctorId', isEqualTo: doctorId)
//         .where('status', isEqualTo: 'completed')
//         .orderBy('completedAt', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
//             .toList());
//   }
//
//   /// Update earnings when a request is completed
//   Future<void> onRequestCompleted(String doctorId) async {
//     await updateDoctorEarnings(doctorId);
//   }
//
//   /// Initialize earnings for a doctor (useful for existing doctors)
//   Future<void> initializeDoctorEarnings(String doctorId) async {
//     try {
//       // Check if earnings document exists
//       final doc = await _firestore
//           .collection(earningsCollection)
//           .doc(doctorId)
//           .get();
//
//       if (!doc.exists) {
//         // Create empty earnings document
//         await _createEmptyEarnings(doctorId);
//       } else {
//         // Update existing earnings
//         await updateDoctorEarnings(doctorId);
//       }
//     } catch (e) {
//       print('Error initializing doctor earnings: $e');
//     }
//   }
//
//   /// Get monthly earnings for chart display
//   Future<List<Map<String, dynamic>>> getMonthlyEarnings({
//     required String doctorId,
//     int months = 6,
//   }) async {
//     try {
//       final now = DateTime.now();
//       final startDate = DateTime(now.year, now.month - months + 1, 1);
//
//       final snapshot = await _firestore
//           .collection(requestsCollection)
//           .where('doctorId', isEqualTo: doctorId)
//           .where('status', isEqualTo: 'completed')
//           .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .get();
//
//       // Group by month
//       final Map<String, double> monthlyEarnings = {};
//
//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
//         if (completedAt != null) {
//           final monthKey = '${completedAt.year}-${completedAt.month.toString().padLeft(2, '0')}';
//           final price = (data['finalPrice'] as num?)?.toDouble() ??
//                        (data['price'] as num?)?.toDouble() ?? 0.0;
//           monthlyEarnings[monthKey] = (monthlyEarnings[monthKey] ?? 0.0) + price;
//         }
//       }
//
//       // Convert to list format
//       final List<Map<String, dynamic>> result = [];
//       for (int i = 0; i < months; i++) {
//         final date = DateTime(now.year, now.month - months + 1 + i, 1);
//         final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
//         final earnings = monthlyEarnings[monthKey] ?? 0.0;
//
//         result.add({
//           'month': monthKey,
//           'earnings': earnings,
//           'date': date,
//         });
//       }
//
//       return result;
//     } catch (e) {
//       print('Error getting monthly earnings: $e');
//       return [];
//     }
//   }
// }
// Fixed Doctor earnings service - يحسب كل الطلبات المكتملة
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/earnings_model.dart';
import '../data/models/request_model.dart';

class EarningsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String earningsCollection = 'doctor_earnings';
  static const String requestsCollection = 'requests';
  static const double defaultCommissionRate = 0.12; // 12%

  /// Get doctor earnings summary
  Future<DoctorEarnings?> getDoctorEarnings(String doctorId) async {
    try {
      final doc = await _firestore
          .collection(earningsCollection)
          .doc(doctorId)
          .get();

      if (doc.exists) {
        return DoctorEarnings.fromMap(doc.data()!);
      } else {
        // Create empty earnings document if it doesn't exist
        await _createEmptyEarnings(doctorId);
        // 🔥 بعد ما نعمل document فاضي، نحدثه بالطلبات الموجودة
        await updateDoctorEarnings(doctorId);
        return await getDoctorEarnings(doctorId);
      }
    } catch (e) {
      print('Error getting doctor earnings: $e');
      return null;
    }
  }

  /// Stream doctor earnings for real-time updates
  Stream<DoctorEarnings?> streamDoctorEarnings(String doctorId) {
    return _firestore
        .collection(earningsCollection)
        .doc(doctorId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return DoctorEarnings.fromMap(doc.data()!);
      } else {
        // Return null if document doesn't exist - let the UI handle initialization
        return null;
      }
    });
  }

  /// 🔥 Calculate and update doctor earnings from ALL completed requests
  Future<void> updateDoctorEarnings(String doctorId) async {
    try {
      print('🔄 Updating earnings for doctor: $doctorId');

      // Get all completed requests for this doctor
      final completedRequests = await _firestore
          .collection(requestsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .get();

      print('📊 Found ${completedRequests.docs.length} completed requests');

      if (completedRequests.docs.isEmpty) {
        // No completed requests, create empty earnings record
        await _createEmptyEarnings(doctorId);
        return;
      }

      // Calculate totals
      int totalRequests = completedRequests.docs.length;
      double totalEarnings = 0.0;
      DateTime? lastRequestDate;

      for (final doc in completedRequests.docs) {
        final data = doc.data();

        // 🔥 جرب تجيب السعر من finalPrice أو price
        final price = (data['finalPrice'] as num?)?.toDouble() ??
            (data['price'] as num?)?.toDouble() ?? 0.0;

        print('💰 Request ${doc.id}: price = $price');
        totalEarnings += price;

        // Track the most recent request date
        final completedAt = (data['completedAt'] as Timestamp?)?.toDate() ??
            (data['updatedAt'] as Timestamp?)?.toDate();
        if (completedAt != null) {
          if (lastRequestDate == null || completedAt.isAfter(lastRequestDate)) {
            lastRequestDate = completedAt;
          }
        }
      }

      print('💵 Total earnings before commission: $totalEarnings');

      // Calculate commission and net earnings
      final commissionRate = defaultCommissionRate;
      final platformCommission = totalEarnings * commissionRate;
      final netEarnings = totalEarnings - platformCommission;

      print('📉 Commission: $platformCommission');
      print('✅ Net earnings: $netEarnings');

      // Get doctor's currency
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      final doctorData = doctorDoc.data();
      final currency = doctorData?['currency'] ?? 'EGP';

      // Create or update earnings record
      final earnings = DoctorEarnings(
        doctorId: doctorId,
        totalRequests: totalRequests,
        totalEarnings: totalEarnings,
        platformCommission: platformCommission,
        netEarnings: netEarnings,
        currency: currency,
        lastUpdated: DateTime.now(),
        lastRequestDate: lastRequestDate,
      );

      await _firestore
          .collection(earningsCollection)
          .doc(doctorId)
          .set(earnings.toMap(), SetOptions(merge: true)); // 🔥 merge عشان ميمسحش بيانات تانية

      print('✅ Earnings updated successfully!');

    } catch (e) {
      print('❌ Error updating doctor earnings: $e');
      throw 'فشل في تحديث أرباح الطبيب: $e';
    }
  }

  /// Create empty earnings record for new doctor
  Future<void> _createEmptyEarnings(String doctorId) async {
    try {
      // Get doctor's currency
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      final doctorData = doctorDoc.data();
      final currency = doctorData?['currency'] ?? 'EGP';

      final earnings = DoctorEarnings(
        doctorId: doctorId,
        totalRequests: 0,
        totalEarnings: 0.0,
        platformCommission: 0.0,
        netEarnings: 0.0,
        currency: currency,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(earningsCollection)
          .doc(doctorId)
          .set(earnings.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating empty earnings: $e');
    }
  }

  /// Get earnings breakdown for a specific period
  Future<EarningsBreakdown> getEarningsBreakdown({
    required String doctorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(requestsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed');

      if (startDate != null) {
        query = query.where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      double totalEarnings = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final price = (data['finalPrice'] as num?)?.toDouble() ??
            (data['price'] as num?)?.toDouble() ?? 0.0;
        totalEarnings += price;
      }

      // Get doctor's currency
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      final doctorData = doctorDoc.data();
      final currency = doctorData?['currency'] ?? 'EGP';

      return EarningsBreakdown.calculate(
        totalEarnings: totalEarnings,
        commissionRate: defaultCommissionRate,
        currency: currency,
      );
    } catch (e) {
      print('Error getting earnings breakdown: $e');
      throw 'فشل في حساب تفاصيل الأرباح: $e';
    }
  }

  /// Get recent completed requests for earnings history
  Future<List<RequestModel>> getRecentCompletedRequests({
    required String doctorId,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(requestsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      print('Error getting recent completed requests: $e');
      return [];
    }
  }

  /// Stream recent completed requests for real-time updates
  Stream<List<RequestModel>> streamRecentCompletedRequests({
    required String doctorId,
    int limit = 10,
  }) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
        .toList());
  }

  /// Update earnings when a request is completed
  Future<void> onRequestCompleted(String doctorId) async {
    await updateDoctorEarnings(doctorId);
  }

  /// 🔥 Initialize earnings for a doctor - يحسب كل الطلبات المكتملة
  Future<void> initializeDoctorEarnings(String doctorId) async {
    try {
      print('🚀 Initializing earnings for doctor: $doctorId');

      // Check if earnings document exists
      final doc = await _firestore
          .collection(earningsCollection)
          .doc(doctorId)
          .get();

      if (!doc.exists) {
        print('📝 Creating new earnings document...');
        await _createEmptyEarnings(doctorId);
      }

      // 🔥 دايماً نحدث الأرباح من كل الطلبات المكتملة
      print('🔄 Updating earnings from all completed requests...');
      await updateDoctorEarnings(doctorId);

    } catch (e) {
      print('❌ Error initializing doctor earnings: $e');
    }
  }

  /// Get monthly earnings for chart display
  Future<List<Map<String, dynamic>>> getMonthlyEarnings({
    required String doctorId,
    int months = 6,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months + 1, 1);

      final snapshot = await _firestore
          .collection(requestsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      // Group by month
      final Map<String, double> monthlyEarnings = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
        if (completedAt != null) {
          final monthKey = '${completedAt.year}-${completedAt.month.toString().padLeft(2, '0')}';
          final price = (data['finalPrice'] as num?)?.toDouble() ??
              (data['price'] as num?)?.toDouble() ?? 0.0;
          monthlyEarnings[monthKey] = (monthlyEarnings[monthKey] ?? 0.0) + price;
        }
      }

      // Convert to list format
      final List<Map<String, dynamic>> result = [];
      for (int i = 0; i < months; i++) {
        final date = DateTime(now.year, now.month - months + 1 + i, 1);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final earnings = monthlyEarnings[monthKey] ?? 0.0;

        result.add({
          'month': monthKey,
          'earnings': earnings,
          'date': date,
        });
      }

      return result;
    } catch (e) {
      print('Error getting monthly earnings: $e');
      return [];
    }
  }
}