// Review model for doctor ratings and reviews
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String patientId;
  final String reviewText;
  final int stars; // 1-5 rating
  final DateTime createdAt;

  Review({
    required this.patientId,
    required this.reviewText,
    required this.stars,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      patientId: map['patientId'] ?? '',
      reviewText: map['reviewText'] ?? '',
      stars: map['stars'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'reviewText': reviewText,
      'stars': stars,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Review copyWith({
    String? patientId,
    String? reviewText,
    int? stars,
    DateTime? createdAt,
  }) {
    return Review(
      patientId: patientId ?? this.patientId,
      reviewText: reviewText ?? this.reviewText,
      stars: stars ?? this.stars,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}