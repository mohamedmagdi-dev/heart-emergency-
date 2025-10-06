// Rating model for the rating system
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String role; // 'doctor' or 'patient'
  final double rating; // 1.0 to 5.0
  final String? comment;
  final DateTime createdAt;
  final String? requestId; // Optional: link to the request that triggered this rating

  RatingModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.role,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.requestId,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return RatingModel(
      id: documentId ?? map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      role: map['role'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestId: map['requestId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'role': role,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      if (requestId != null) 'requestId': requestId,
    };
  }

  RatingModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? role,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? requestId,
  }) {
    return RatingModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      requestId: requestId ?? this.requestId,
    );
  }

  // Validation methods
  bool get isValid => rating >= 1.0 && rating <= 5.0 && fromUserId.isNotEmpty && toUserId.isNotEmpty;
  
  String get ratingText {
    if (rating >= 4.5) return 'ممتاز';
    if (rating >= 3.5) return 'جيد جداً';
    if (rating >= 2.5) return 'جيد';
    if (rating >= 1.5) return 'مقبول';
    return 'ضعيف';
  }
}
