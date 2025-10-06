// Doctor request model for patient-doctor requests
import 'package:cloud_firestore/cloud_firestore.dart';

enum DoctorRequestStatus { pending, accepted, rejected }

extension DoctorRequestStatusExtension on DoctorRequestStatus {
  String get name {
    switch (this) {
      case DoctorRequestStatus.pending:
        return 'pending';
      case DoctorRequestStatus.accepted:
        return 'accepted';
      case DoctorRequestStatus.rejected:
        return 'rejected';
    }
  }

  static DoctorRequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return DoctorRequestStatus.pending;
      case 'accepted':
        return DoctorRequestStatus.accepted;
      case 'rejected':
        return DoctorRequestStatus.rejected;
      default:
        return DoctorRequestStatus.pending;
    }
  }
}

class DoctorRequestModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DoctorRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? message; // Optional message from patient
  final String? responseMessage; // Optional response from doctor

  DoctorRequestModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.message,
    this.responseMessage,
  });

  factory DoctorRequestModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return DoctorRequestModel(
      id: documentId ?? map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      status: DoctorRequestStatusExtension.fromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      message: map['message'],
      responseMessage: map['responseMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (message != null) 'message': message,
      if (responseMessage != null) 'responseMessage': responseMessage,
    };
  }

  DoctorRequestModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DoctorRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
    String? responseMessage,
  }) {
    return DoctorRequestModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }
}
