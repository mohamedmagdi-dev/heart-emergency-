// FIXED: Unit tests for UserModel data model
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../lib/data/models/user_model.dart';
import '../../lib/data/models/review_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel with required fields', () {
      final user = UserModel(
        uid: 'test-uid',
        role: 'patient',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+1234567890',
        currency: Currency.EGP,
        walletBalance: 100,
        createdAt: DateTime.now(),
      );

      expect(user.uid, equals('test-uid'));
      expect(user.role, equals('patient'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.phone, equals('+1234567890'));
      expect(user.currency, equals(Currency.EGP));
      expect(user.walletBalance, equals(100.0));
      expect(user.available, isNull); // Should be null for patients
    });

    test('should create doctor UserModel with doctor-specific fields', () {
      final reviews = [
        Review(
          patientId: 'patient-1',
          reviewText: 'Great doctor!',
          stars: 5,
          createdAt: DateTime.now(),
        ),
      ];

      final doctor = UserModel(
        uid: 'doctor-uid',
        role: 'doctor',
        name: 'Dr. Test',
        email: 'doctor@example.com',
        phone: '+1234567890',
        currency: Currency.EGP,
        walletBalance: 500.0,
        createdAt: DateTime.now(),
        specialization: 'Cardiology',
        location: const GeoPoint(30.0444, 31.2357),
        verified: true,
        available: true,
        certificates: ['cert1.pdf', 'cert2.pdf'],
        rating: 4.5,
        reviews: reviews,
        fcmToken: 'fcm-token-123',
      );

      expect(doctor.role, equals('doctor'));
      expect(doctor.specialization, equals('Cardiology'));
      expect(doctor.location, isNotNull);
      expect(doctor.verified, isTrue);
      expect(doctor.available, isTrue);
      expect(doctor.certificates, hasLength(2));
      expect(doctor.rating, equals(4.5));
      expect(doctor.reviews, hasLength(1));
      expect(doctor.fcmToken, equals('fcm-token-123'));
    });

    test('should convert UserModel to Map correctly', () {
      final user = UserModel(
        uid: 'test-uid',
        role: 'patient',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+1234567890',
        currency: Currency.USD,
        walletBalance: 100,
        createdAt: DateTime(2023, 1, 1),
      );

      final map = user.toMap();

      expect(map['uid'], equals('test-uid'));
      expect(map['role'], equals('patient'));
      expect(map['name'], equals('Test User'));
      expect(map['email'], equals('test@example.com'));
      expect(map['phone'], equals('+1234567890'));
      expect(map['currency'], equals('USD'));
      expect(map['walletBalance'], equals(100.0));
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('should create UserModel from Map correctly', () {
      final map = {
        'uid': 'test-uid',
        'role': 'doctor',
        'name': 'Dr. Test',
        'email': 'doctor@example.com',
        'phone': '+1234567890',
        'currency': 'SAR',
        'walletBalance': 250.0,
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'specialization': 'Neurology',
        'location': const GeoPoint(24.7136, 46.6753),
        'verified': false,
        'available': true,
        'certificates': ['cert1.pdf'],
        'rating': 4.2,
        'fcmToken': 'fcm-token-456',
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, equals('test-uid'));
      expect(user.role, equals('doctor'));
      expect(user.name, equals('Dr. Test'));
      expect(user.currency, equals(Currency.SAR));
      expect(user.specialization, equals('Neurology'));
      expect(user.verified, isFalse);
      expect(user.available, isTrue);
      expect(user.certificates, hasLength(1));
      expect(user.rating, equals(4.2));
      expect(user.fcmToken, equals('fcm-token-456'));
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {
        'uid': 'test-uid',
        'role': 'patient',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+1234567890',
        'currency': 'EGP',
        'walletBalance': 0.0,
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      final user = UserModel.fromMap(map);

      expect(user.specialization, isNull);
      expect(user.location, isNull);
      expect(user.verified, isNull);
      expect(user.available, isTrue); // Should default to true
      expect(user.certificates, isNull);
      expect(user.rating, isNull);
      expect(user.reviews, isNull);
      expect(user.fcmToken, isNull);
    });

    test('should create copy with updated fields', () {
      final original = UserModel(
        uid: 'test-uid',
        role: 'doctor',
        name: 'Dr. Original',
        email: 'original@example.com',
        phone: '+1234567890',
        currency: Currency.EGP,
        walletBalance: 100,
        createdAt: DateTime.now(),
        available: false,
      );

      final updated = original.copyWith(
        name: 'Dr. Updated',
        available: true,
        walletBalance: 200.0,
      );

      expect(updated.uid, equals(original.uid)); // Unchanged
      expect(updated.role, equals(original.role)); // Unchanged
      expect(updated.name, equals('Dr. Updated')); // Changed
      expect(updated.available, isTrue); // Changed
      expect(updated.walletBalance, equals(200.0)); // Changed
      expect(updated.email, equals(original.email)); // Unchanged
    });
  });

  group('Currency Extension Tests', () {
    test('should convert Currency enum to string correctly', () {
      expect(Currency.EGP.name, equals('EGP'));
      expect(Currency.USD.name, equals('USD'));
      expect(Currency.SAR.name, equals('SAR'));
      expect(Currency.YER_NEW.name, equals('YER-new'));
      expect(Currency.YER_OLD.name, equals('YER-old'));
    });

    test('should convert string to Currency enum correctly', () {
      expect(CurrencyExtension.fromString('EGP'), equals(Currency.EGP));
      expect(CurrencyExtension.fromString('USD'), equals(Currency.USD));
      expect(CurrencyExtension.fromString('SAR'), equals(Currency.SAR));
      expect(CurrencyExtension.fromString('YER-new'), equals(Currency.YER_NEW));
      expect(CurrencyExtension.fromString('YER-old'), equals(Currency.YER_OLD));
    });

    test('should default to EGP for invalid currency string', () {
      expect(CurrencyExtension.fromString('INVALID'), equals(Currency.EGP));
      expect(CurrencyExtension.fromString(''), equals(Currency.EGP));
    });
  });
}
