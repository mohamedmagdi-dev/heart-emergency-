import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/rating_service.dart';

final ratingProvider = StateNotifierProvider<RatingNotifier, RatingState>((ref) {
  return RatingNotifier();
});

class RatingState {
  final double rating;
  final String comment;
  final bool hasRatedBefore;
  final bool isSubmitting;
  final double? existingRating;
  final String? existingComment;

  RatingState({
    this.rating = 0.0,
    this.comment = '',
    this.hasRatedBefore = false,
    this.isSubmitting = false,
    this.existingRating,
    this.existingComment,
  });

  RatingState copyWith({
    double? rating,
    String? comment,
    bool? hasRatedBefore,
    bool? isSubmitting,
    double? existingRating,
    String? existingComment,
  }) {
    return RatingState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      hasRatedBefore: hasRatedBefore ?? this.hasRatedBefore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      existingRating: existingRating ?? this.existingRating,
      existingComment: existingComment ?? this.existingComment,
    );
  }
}

class RatingNotifier extends StateNotifier<RatingState> {
  final RatingService _ratingService = RatingService();

  RatingNotifier() : super(RatingState());

  // دالة علشان تشوف إذا اتعمل تقييم قبل كده
  Future<void> checkExistingRating(String? requestId) async {
    if (requestId == null) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // استخدم الـ service الموجودة عندك
      final ratings = await _ratingService.getRatingsByCurrentUserForRequest(requestId).first;

      if (ratings.isNotEmpty) {
        final existingRating = ratings.first;
        state = state.copyWith(
          hasRatedBefore: true,
          existingRating: existingRating.rating,
          existingComment: existingRating.comment,
        );
      }
    } catch (e) {
      print('❌ Error checking existing rating: $e');
    }
  }

  // دالة علشان تعدل التقييم
  void updateRating(double rating) {
    state = state.copyWith(rating: rating);
  }

  // دالة علشان تعدل التعليق
  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  // دالة علشان تعمل التقييم
  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  // دالة علشان تعمل التقييم وتخلي state إنه اتعمل تقييم
  void setRatedSuccessfully(double rating, String comment) {
    state = state.copyWith(
      hasRatedBefore: true,
      isSubmitting: false,
      existingRating: rating,
      existingComment: comment,
    );
  }

  // دالة علشان تريست ال state
  void reset() {
    state = RatingState();
  }

  // دالة علشان تعمل التقييم الجديد
  Future<void> submitRating({
    required String toUserId,
    required String role,
    required String? requestId,
  }) async {
    if (state.rating == 0) {
      throw 'يرجى اختيار تقييم';
    }

    state = state.copyWith(isSubmitting: true);

    try {
      await _ratingService.createRating(
        toUserId: toUserId,
        role: role,
        rating: state.rating,
        comment: state.comment.trim().isNotEmpty ? state.comment.trim() : null,
        requestId: requestId,
      );

      // Mark the related request as rated to hide rate button later
      if (requestId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(requestId)
              .update({'isRated': true, 'updatedAt': FieldValue.serverTimestamp()});
        } catch (_) {}
      }

      setRatedSuccessfully(state.rating, state.comment);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}