// Rating service for managing ratings between users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/rating_model.dart';
import '../data/models/user_model.dart';
import 'fcm_notification_service.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String ratingsCollection = 'ratings';

  // Create a new rating
  Future<String> createRating({
    required String toUserId,
    required String role, // 'doctor' or 'patient'
    required double rating,
    String? comment,
    String? requestId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Validate rating
      if (rating < 1.0 || rating > 5.0) {
        throw 'التقييم يجب أن يكون بين 1 و 5';
      }

      // Check if user already rated this person for this request
      if (requestId != null) {
        final existingRating = await _firestore
            .collection(ratingsCollection)
            .where('fromUserId', isEqualTo: currentUser.uid)
            .where('toUserId', isEqualTo: toUserId)
            .where('requestId', isEqualTo: requestId)
            .limit(1)
            .get();

        if (existingRating.docs.isNotEmpty) {
          throw 'لقد قمت بتقييم هذا المستخدم مسبقاً لهذا الطلب';
        }
      }

      // Create the rating
      final ratingData = {
        'fromUserId': currentUser.uid,
        'toUserId': toUserId,
        'role': role,
        'rating': rating,
        // 'createdAt': FieldValue.serverTimestamp(),
        'createdAt': Timestamp.now(),

        if (comment != null) 'comment': comment,
        if (requestId != null) 'requestId': requestId,
      };

      final docRef = await _firestore.collection(ratingsCollection).add(ratingData);
      
      // Update user's average rating
      await _updateUserAverageRating(toUserId);
      
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء التقييم: $e';
    }
  }

  // Get all ratings for a specific user
  Stream<List<RatingModel>> getRatingsForUser(String userId) {
    return _firestore
        .collection(ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RatingModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Get ratings by a specific user
  Stream<List<RatingModel>> getRatingsByUser(String userId) {
    return _firestore
        .collection(ratingsCollection)
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('🔥 Ratings count for $userId = ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        return RatingModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Get all ratings (admin only)
  Stream<List<RatingModel>> getAllRatings() {
    return _firestore
        .collection(ratingsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RatingModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Get average rating for a user
  Future<double> getAverageRating(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ratingsCollection)
          .where('toUserId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] ?? 0.0).toDouble();
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Get rating count for a user
  Future<int> getRatingCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ratingsCollection)
          .where('toUserId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting rating count: $e');
      return 0;
    }
  }

  // Update user's average rating in their profile
  Future<void> _updateUserAverageRating(String userId) async {
    try {
      final averageRating = await getAverageRating(userId);
      final ratingCount = await getRatingCount(userId);

      await _firestore.collection('users').doc(userId).update({
        'rating': averageRating,
        'ratingCount': ratingCount,
        'ratingUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user average rating: $e');
    }
  }

  // Get user details for rating display
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Check if user can rate another user for a specific request
  Future<bool> canRateUser(String toUserId, String? requestId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // If no requestId, allow rating
      if (requestId == null) return true;

      // Check if already rated for this request
      final existingRating = await _firestore
          .collection(ratingsCollection)
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .where('requestId', isEqualTo: requestId)
          .limit(1)
          .get();

      return existingRating.docs.isEmpty;
    } catch (e) {
      print('Error checking if can rate user: $e');
      return false;
    }
  }

  // Get ratings statistics for admin
  Future<Map<String, dynamic>> getRatingStatistics() async {
    try {
      final snapshot = await _firestore.collection(ratingsCollection).get();
      
      if (snapshot.docs.isEmpty) {
        return {
          'totalRatings': 0,
          'averageRating': 0.0,
          'ratingDistribution': <String, int>{},
          'recentRatings': 0,
        };
      }

      double totalRating = 0.0;
      final ratingDistribution = <String, int>{};
      int recentRatings = 0;
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0.0).toDouble();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        totalRating += rating;
        
        // Rating distribution
        final ratingKey = '${rating.toStringAsFixed(1)}';
        ratingDistribution[ratingKey] = (ratingDistribution[ratingKey] ?? 0) + 1;
        
        // Recent ratings (last week)
        if (createdAt.isAfter(oneWeekAgo)) {
          recentRatings++;
        }
      }

      return {
        'totalRatings': snapshot.docs.length,
        'averageRating': totalRating / snapshot.docs.length,
        'ratingDistribution': ratingDistribution,
        'recentRatings': recentRatings,
      };
    } catch (e) {
      print('Error getting rating statistics: $e');
      return {
        'totalRatings': 0,
        'averageRating': 0.0,
        'ratingDistribution': <String, int>{},
        'recentRatings': 0,
      };
    }
  }
}
