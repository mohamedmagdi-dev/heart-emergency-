// Request model for emergency medical requests
import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected, completed }

extension RequestStatusExtension on RequestStatus {
  String get name {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.rejected:
        return 'rejected';
      case RequestStatus.completed:
        return 'completed';
    }
  }

  static RequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }
}

class RequestModel {
  final String id;
  final String patientId;
  final String? doctorId;
  final RequestStatus status;
  final GeoPoint patientLocation;
  final String patientAddress;
  final String symptoms;
  final String urgencyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Pricing & distance/ETA
  final double? price; // Set by patient at creation
  final double? finalPrice; // Shown on completion
  final double? commissionRate; // e.g., 0.12 for 12%
  final double? commissionAmount; // Calculated at completion
  final double? distanceKm; // Live-updated
  final int? etaMinutes; // Live-updated
  final bool? isRated; // Marked true after patient rates the doctor
  // Timestamps
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  RequestModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.status,
    required this.patientLocation,
    required this.patientAddress,
    required this.symptoms,
    required this.urgencyLevel,
    required this.createdAt,
    required this.updatedAt,
    this.price,
    this.finalPrice,
    this.commissionRate,
    this.commissionAmount,
    this.distanceKm,
    this.etaMinutes,
    this.isRated,
    this.acceptedAt,
    this.completedAt,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return RequestModel(
      id: documentId ?? map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'],
      status: RequestStatusExtension.fromString(map['status'] ?? 'pending'),
      patientLocation: map['patientLocation'] as GeoPoint? ?? const GeoPoint(0, 0),
      patientAddress: map['patientAddress'] ?? '',
      symptoms: map['symptoms'] ?? '',
      urgencyLevel: map['urgencyLevel'] ?? 'medium',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (map['price'] as num?)?.toDouble(),
      finalPrice: (map['finalPrice'] as num?)?.toDouble(),
      commissionRate: (map['commissionRate'] as num?)?.toDouble(),
      commissionAmount: (map['commissionAmount'] as num?)?.toDouble(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      etaMinutes: map['etaMinutes'] as int?,
      isRated: map['isRated'] as bool?,
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      'status': status.name,
      'patientLocation': patientLocation,
      'patientAddress': patientAddress,
      'symptoms': symptoms,
      'urgencyLevel': urgencyLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (price != null) 'price': price,
      if (finalPrice != null) 'finalPrice': finalPrice,
      if (commissionRate != null) 'commissionRate': commissionRate,
      if (commissionAmount != null) 'commissionAmount': commissionAmount,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (etaMinutes != null) 'etaMinutes': etaMinutes,
      if (isRated != null) 'isRated': isRated,
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  RequestModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    RequestStatus? status,
    GeoPoint? patientLocation,
    String? patientAddress,
    String? symptoms,
    String? urgencyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? price,
    double? finalPrice,
    double? commissionRate,
    double? commissionAmount,
    double? distanceKm,
    int? etaMinutes,
    bool? isRated,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      status: status ?? this.status,
      patientLocation: patientLocation ?? this.patientLocation,
      patientAddress: patientAddress ?? this.patientAddress,
      symptoms: symptoms ?? this.symptoms,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      price: price ?? this.price,
      finalPrice: finalPrice ?? this.finalPrice,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      isRated: isRated ?? this.isRated,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}