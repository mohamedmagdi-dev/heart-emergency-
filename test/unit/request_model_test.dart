// FIXED: Unit tests for RequestModel data model
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../lib/data/models/request_model.dart';

void main() {
  group('RequestModel Tests', () {
    test('should create RequestModel with required fields', () {
      final request = RequestModel(
        id: 'request-123',
        patientId: 'patient-456',
        status: RequestStatus.pending,
        patientLocation: const GeoPoint(30.0444, 31.2357),
        patientAddress: 'Cairo, Egypt',
        symptoms: 'Chest pain and shortness of breath',
        urgencyLevel: 'high',
        createdAt: DateTime(2023, 1, 1, 10, 0),
        updatedAt: DateTime(2023, 1, 1, 10, 0),
      );

      expect(request.id, equals('request-123'));
      expect(request.patientId, equals('patient-456'));
      expect(request.doctorId, isNull);
      expect(request.status, equals(RequestStatus.pending));
      expect(request.patientLocation.latitude, equals(30.0444));
      expect(request.patientLocation.longitude, equals(31.2357));
      expect(request.patientAddress, equals('Cairo, Egypt'));
      expect(request.symptoms, equals('Chest pain and shortness of breath'));
      expect(request.urgencyLevel, equals('high'));
    });

    test('should create RequestModel with doctor assigned', () {
      final request = RequestModel(
        id: 'request-123',
        patientId: 'patient-456',
        doctorId: 'doctor-789',
        status: RequestStatus.accepted,
        patientLocation: const GeoPoint(30.0444, 31.2357),
        patientAddress: 'Cairo, Egypt',
        symptoms: 'Fever and headache',
        urgencyLevel: 'medium',
        createdAt: DateTime(2023, 1, 1, 10, 0),
        updatedAt: DateTime(2023, 1, 1, 10, 30),
      );

      expect(request.doctorId, equals('doctor-789'));
      expect(request.status, equals(RequestStatus.accepted));
      expect(request.urgencyLevel, equals('medium'));
    });

    test('should convert RequestModel to Map correctly', () {
      final request = RequestModel(
        id: 'request-123',
        patientId: 'patient-456',
        doctorId: 'doctor-789',
        status: RequestStatus.completed,
        patientLocation: const GeoPoint(30.0444, 31.2357),
        patientAddress: 'Cairo, Egypt',
        symptoms: 'Back pain',
        urgencyLevel: 'low',
        createdAt: DateTime(2023, 1, 1, 10, 0),
        updatedAt: DateTime(2023, 1, 1, 11, 0),
      );

      final map = request.toMap();

      expect(map['id'], equals('request-123'));
      expect(map['patientId'], equals('patient-456'));
      expect(map['doctorId'], equals('doctor-789'));
      expect(map['status'], equals('completed'));
      expect(map['patientLocation'], isA<GeoPoint>());
      expect(map['patientAddress'], equals('Cairo, Egypt'));
      expect(map['symptoms'], equals('Back pain'));
      expect(map['urgencyLevel'], equals('low'));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
    });

    test('should create RequestModel from Map correctly', () {
      final map = {
        'id': 'request-123',
        'patientId': 'patient-456',
        'doctorId': 'doctor-789',
        'status': 'accepted',
        'patientLocation': const GeoPoint(30.0444, 31.2357),
        'patientAddress': 'Cairo, Egypt',
        'symptoms': 'Stomach ache',
        'urgencyLevel': 'medium',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1, 10, 15)),
      };

      final request = RequestModel.fromMap(map);

      expect(request.id, equals('request-123'));
      expect(request.patientId, equals('patient-456'));
      expect(request.doctorId, equals('doctor-789'));
      expect(request.status, equals(RequestStatus.accepted));
      expect(request.patientLocation.latitude, equals(30.0444));
      expect(request.patientAddress, equals('Cairo, Egypt'));
      expect(request.symptoms, equals('Stomach ache'));
      expect(request.urgencyLevel, equals('medium'));
    });

    test('should handle missing doctorId in fromMap', () {
      final map = {
        'id': 'request-123',
        'patientId': 'patient-456',
        'status': 'pending',
        'patientLocation': const GeoPoint(30.0444, 31.2357),
        'patientAddress': 'Cairo, Egypt',
        'symptoms': 'Headache',
        'urgencyLevel': 'low',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0)),
      };

      final request = RequestModel.fromMap(map);

      expect(request.doctorId, isNull);
      expect(request.status, equals(RequestStatus.pending));
    });

    test('should create copy with updated fields', () {
      final original = RequestModel(
        id: 'request-123',
        patientId: 'patient-456',
        status: RequestStatus.pending,
        patientLocation: const GeoPoint(30.0444, 31.2357),
        patientAddress: 'Cairo, Egypt',
        symptoms: 'Original symptoms',
        urgencyLevel: 'medium',
        createdAt: DateTime(2023, 1, 1, 10, 0),
        updatedAt: DateTime(2023, 1, 1, 10, 0),
      );

      final updated = original.copyWith(
        doctorId: 'doctor-789',
        status: RequestStatus.accepted,
        updatedAt: DateTime(2023, 1, 1, 10, 30),
      );

      expect(updated.id, equals(original.id)); // Unchanged
      expect(updated.patientId, equals(original.patientId)); // Unchanged
      expect(updated.doctorId, equals('doctor-789')); // Changed
      expect(updated.status, equals(RequestStatus.accepted)); // Changed
      expect(updated.symptoms, equals(original.symptoms)); // Unchanged
      expect(updated.updatedAt, equals(DateTime(2023, 1, 1, 10, 30))); // Changed
    });
  });

  group('RequestStatus Extension Tests', () {
    test('should convert RequestStatus enum to string correctly', () {
      expect(RequestStatus.pending.name, equals('pending'));
      expect(RequestStatus.accepted.name, equals('accepted'));
      expect(RequestStatus.rejected.name, equals('rejected'));
      expect(RequestStatus.completed.name, equals('completed'));
    });

    test('should convert string to RequestStatus enum correctly', () {
      expect(RequestStatusExtension.fromString('pending'), equals(RequestStatus.pending));
      expect(RequestStatusExtension.fromString('accepted'), equals(RequestStatus.accepted));
      expect(RequestStatusExtension.fromString('rejected'), equals(RequestStatus.rejected));
      expect(RequestStatusExtension.fromString('completed'), equals(RequestStatus.completed));
    });

    test('should default to pending for invalid status string', () {
      expect(RequestStatusExtension.fromString('invalid'), equals(RequestStatus.pending));
      expect(RequestStatusExtension.fromString(''), equals(RequestStatus.pending));
    });
  });
}
