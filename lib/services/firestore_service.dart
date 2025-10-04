// Comprehensive Firestore service for all database operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/models/request_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/review_model.dart';
import 'dart:math' show sin, cos, sqrt, atan2, pi;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String requestsCollection = 'requests';
  static const String transactionsCollection = 'transactions';

  // ==================== USER OPERATIONS ====================

  // Create user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'فشل في إنشاء المستخدم: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'فشل في جلب بيانات المستخدم: $e';
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    return await getUser(currentUser.uid);
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).update(data);
    } catch (e) {
      throw 'فشل في تحديث بيانات المستخدم: $e';
    }
  }

  // Get all users (for admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Get nearby doctors
  Future<List<UserModel>> getNearbyDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      // First try the optimized query with composite index
      try {
        final snapshot = await _firestore
            .collection(usersCollection)
            .where('role', isEqualTo: 'doctor')
            .where('verified', isEqualTo: true)
            .where('available', isEqualTo: true)
            .get();

        final doctors = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .where((doctor) => doctor.location != null)
            .toList();

        return _filterAndSortDoctorsByDistance(doctors, latitude, longitude, radiusKm);
      } catch (e) {
        // Fallback: Get all doctors and filter in memory if composite index is missing
        print('Composite index missing, falling back to memory filtering: $e');
        
        final snapshot = await _firestore
            .collection(usersCollection)
            .where('role', isEqualTo: 'doctor')
            .where('verified', isEqualTo: true)
            .get();

        final allDoctors = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .where((doctor) => doctor.location != null)
            .toList();

        // Filter by availability in memory
        final availableDoctors = allDoctors.where((doctor) => doctor.available == true).toList();
        
        return _filterAndSortDoctorsByDistance(availableDoctors, latitude, longitude, radiusKm);
      }
    } catch (e) {
      throw 'فشل في جلب الأطباء القريبين: $e';
    }
  }

  // Helper method to filter and sort doctors by distance
  List<UserModel> _filterAndSortDoctorsByDistance(
    List<UserModel> doctors,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    final nearbyDoctors = <UserModel>[];
    
    for (final doctor in doctors) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        doctor.location!.latitude,
        doctor.location!.longitude,
      );
      if (distance <= radiusKm) {
        nearbyDoctors.add(doctor);
      }
    }

    // Sort by distance (closest first)
    nearbyDoctors.sort((a, b) {
      final distanceA = _calculateDistance(
        latitude,
        longitude,
        a.location!.latitude,
        a.location!.longitude,
      );
      final distanceB = _calculateDistance(
        latitude,
        longitude,
        b.location!.latitude,
        b.location!.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyDoctors;
  }

  // Update doctor verification status
  Future<void> updateDoctorVerification(String doctorId, bool verified) async {
    try {
      await updateUser(doctorId, {'verified': verified});
    } catch (e) {
      throw 'فشل في تحديث حالة التحقق: $e';
    }
  }

  // Update user currency
  Future<void> updateUserCurrency(String uid, Currency currency) async {
    try {
      await updateUser(uid, {'currency': currency.name});
    } catch (e) {
      throw 'فشل في تحديث العملة: $e';
    }
  }

  // FIXED: Update doctor availability status
  Future<void> updateDoctorAvailability(String doctorId, bool available) async {
    try {
      await updateUser(doctorId, {'available': available});
    } catch (e) {
      throw 'فشل في تحديث حالة الإتاحة: $e';
    }
  }

  // Update wallet balance
  Future<void> updateWalletBalance(String uid, double newBalance) async {
    try {
      await updateUser(uid, {'walletBalance': newBalance});
    } catch (e) {
      throw 'فشل في تحديث رصيد المحفظة: $e';
    }
  }

  // ==================== REQUEST OPERATIONS ====================

  // Create emergency request
  Future<String> createEmergencyRequest(RequestModel request) async {
    try {
      final docRef = await _firestore.collection(requestsCollection).add(request.toMap());
      // Update the request with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء طلب الطوارئ: $e';
    }
  }

  // FIXED: Get request by ID as stream for real-time updates
  Stream<RequestModel?> getRequestById(String requestId) {
    return _firestore
        .collection(requestsCollection)
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return RequestModel.fromMap(data, documentId: doc.id);
    });
  }

  // Get requests for patient
  Stream<List<RequestModel>> getPatientRequests(String patientId) {
    return _firestore
        .collection(requestsCollection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Get requests for doctor
  Stream<List<RequestModel>> getDoctorRequests(String doctorId) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Get pending requests for doctor
  Stream<List<RequestModel>> getPendingRequestsForDoctor(String doctorId) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, RequestStatus status) async {
    try {
      await _firestore.collection(requestsCollection).doc(requestId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'فشل في تحديث حالة الطلب: $e';
    }
  }

  // Get all requests (for admin)
  Stream<List<RequestModel>> getAllRequests() {
    return _firestore
        .collection(requestsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // ==================== TRANSACTION OPERATIONS ====================

  // Create transaction
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore.collection(transactionsCollection).add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء المعاملة: $e';
    }
  }

  // Process payment transaction
  Future<void> processPayment({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required Currency currency,
  }) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // Calculate commission
      final commission = TransactionModel.calculateCommission(amount);
      final netAmount = amount - commission;

      // Get current balances
      final fromUserDoc = await _firestore.collection(usersCollection).doc(fromUserId).get();
      final toUserDoc = await _firestore.collection(usersCollection).doc(toUserId).get();

      if (!fromUserDoc.exists || !toUserDoc.exists) {
        throw 'المستخدم غير موجود';
      }

      final fromUser = UserModel.fromMap(fromUserDoc.data()!);
      final toUser = UserModel.fromMap(toUserDoc.data()!);

      // Check if sender has enough balance
      if (fromUser.walletBalance < amount) {
        throw 'الرصيد غير كافي';
      }

      // Update balances
      final newFromBalance = fromUser.walletBalance - amount;
      final newToBalance = toUser.walletBalance + netAmount;

      batch.update(_firestore.collection(usersCollection).doc(fromUserId), {
        'walletBalance': newFromBalance,
      });

      batch.update(_firestore.collection(usersCollection).doc(toUserId), {
        'walletBalance': newToBalance,
      });

      // Create transaction record
      final transaction = TransactionModel(
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
        commission: commission,
        status: TransactionStatus.success,
        createdAt: DateTime.now(),
      );

      final transactionRef = _firestore.collection(transactionsCollection).doc();
      batch.set(transactionRef, transaction.toMap());

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw 'فشل في معالجة الدفع: $e';
    }
  }

  // Get user transactions
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection(transactionsCollection)
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Get all transactions (for admin)
  Stream<List<TransactionModel>> getAllTransactions() {
    return _firestore
        .collection(transactionsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // ==================== REVIEW OPERATIONS ====================

  // Add review to doctor
  Future<void> addReviewToDoctor({
    required String doctorId,
    required String patientId,
    required String reviewText,
    required int stars,
  }) async {
    try {
      final doctorDoc = await _firestore.collection(usersCollection).doc(doctorId).get();
      if (!doctorDoc.exists) throw 'الطبيب غير موجود';

      final doctor = UserModel.fromMap(doctorDoc.data()!);
      final reviews = doctor.reviews ?? [];

      // Add new review
      final newReview = Review(
        patientId: patientId,
        reviewText: reviewText,
        stars: stars,
        createdAt: DateTime.now(),
      );
      reviews.add(newReview);

      // Calculate new average rating
      final totalStars = reviews.fold<int>(0, (sum, review) => sum + review.stars);
      final averageRating = totalStars / reviews.length;

      // Update doctor document
      await updateUser(doctorId, {
        'reviews': reviews.map((review) => review.toMap()).toList(),
        'rating': averageRating,
      });
    } catch (e) {
      throw 'فشل في إضافة التقييم: $e';
    }
  }

  // ==================== UTILITY METHODS ====================

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Delete user (for admin)
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      throw 'فشل في حذف المستخدم: $e';
    }
  }

  // Block/Unblock user (for admin)
  Future<void> toggleUserBlock(String uid, bool isBlocked) async {
    try {
      await updateUser(uid, {'isBlocked': isBlocked});
    } catch (e) {
      throw 'فشل في تحديث حالة الحظر: $e';
    }
  }
}