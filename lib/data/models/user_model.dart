// // CHANGED_FOR_FIREBASE_INTEGRATION: User model matching exact schema requirements
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'review_model.dart';
//
// enum Currency { egp, usd, sar, yerNew, yerOld }
//
// extension CurrencyExtension on Currency {
//   String get name {
//     switch (this) {
//       case Currency.egp:
//         return 'EGP';
//       case Currency.usd:
//         return 'USD';
//       case Currency.sar:
//         return 'SAR';
//       case Currency.yerNew:
//         return 'YER-new';
//       case Currency.yerOld:
//         return 'YER-old';
//     }
//   }
//
//   static Currency fromString(String value) {
//     switch (value) {
//       case 'EGP':
//         return Currency.egp;
//       case 'USD':
//         return Currency.usd;
//       case 'SAR':
//         return Currency.sar;
//       case 'YER-new':
//         return Currency.yerNew;
//       case 'YER-old':
//         return Currency.yerOld;
//       default:
//         return Currency.egp; // Default currency
//     }
//   }
// }
//
// class UserModel {
//   final String uid;
//   final String role; // 'patient', 'doctor', 'admin'
//   final String name;
//   final String email;
//   final String phone;
//   final String? profileImage; // URL from Firebase Storage
//   final Currency currency;
//   final double walletBalance;
//   final DateTime createdAt;
//
//   // Doctor-specific fields
//   final String? specialization;
//   final GeoPoint? location; // Doctor location
//   final bool? verified; // Doctor verification status
//   final bool? available; // FIXED: Doctor availability status for receiving emergency requests
//   final List<String>? certificates; // Array of URLs from Firebase Storage
//   final double? rating; // 1-5 rating
//   final List<Review>? reviews; // Array of review objects
//
//   // FCM token for notifications
//   final String? fcmToken;
//
//   UserModel({
//     required this.uid,
//     required this.role,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.currency,
//     required this.walletBalance,
//     required this.createdAt,
//     this.profileImage,
//     this.specialization,
//     this.location,
//     this.verified,
//     this.available, // FIXED: Added available parameter
//     this.certificates,
//     this.rating,
//     this.reviews,
//     this.fcmToken,
//   });
//
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     // Parse reviews array
//     List<Review>? parseReviews() {
//       final reviewsData = map['reviews'];
//       if (reviewsData == null) return null;
//       if (reviewsData is List) {
//         return reviewsData
//             .map((reviewMap) => Review.fromMap(Map<String, dynamic>.from(reviewMap)))
//             .toList();
//       }
//       return null;
//     }
//
//     return UserModel(
//       uid: map['uid'] ?? '',
//       role: map['role'] ?? 'patient',
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       phone: map['phone'] ?? '',
//       profileImage: map['profileImage'],
//       currency: CurrencyExtension.fromString(map['currency'] ?? 'EGP'),
//       walletBalance: (map['walletBalance'] ?? 0).toDouble(),
//       createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       specialization: map['specialization'],
//       location: map['location'] as GeoPoint?,
//       verified: map['verified'],
//       available: map['available'] ?? true, // FIXED: Default to true for new doctors
//       certificates: map['certificates'] != null
//           ? List<String>.from(map['certificates'])
//           : null,
//       rating: map['rating']?.toDouble(),
//       reviews: parseReviews(),
//       fcmToken: map['fcmToken'],
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'role': role,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'currency': currency.name,
//       'walletBalance': walletBalance,
//       'createdAt': Timestamp.fromDate(createdAt),
//       if (profileImage != null) 'profileImage': profileImage,
//       if (specialization != null) 'specialization': specialization,
//       if (location != null) 'location': location,
//       if (verified != null) 'verified': verified,
//       if (available != null) 'available': available, // FIXED: Include available in toMap
//       if (certificates != null) 'certificates': certificates,
//       if (rating != null) 'rating': rating,
//       if (reviews != null) 'reviews': reviews!.map((review) => review.toMap()).toList(),
//       if (fcmToken != null) 'fcmToken': fcmToken,
//     };
//   }
//
//   UserModel copyWith({
//     String? uid,
//     String? role,
//     String? name,
//     String? email,
//     String? phone,
//     String? profileImage,
//     Currency? currency,
//     double? walletBalance,
//     DateTime? createdAt,
//     String? specialization,
//     GeoPoint? location,
//     bool? verified,
//     bool? available, // FIXED: Added available to copyWith
//     List<String>? certificates,
//     double? rating,
//     List<Review>? reviews,
//     String? fcmToken,
//   }) {
//     return UserModel(
//       uid: uid ?? this.uid,
//       role: role ?? this.role,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//       profileImage: profileImage ?? this.profileImage,
//       currency: currency ?? this.currency,
//       walletBalance: walletBalance ?? this.walletBalance,
//       createdAt: createdAt ?? this.createdAt,
//       specialization: specialization ?? this.specialization,
//       location: location ?? this.location,
//       verified: verified ?? this.verified,
//       available: available ?? this.available, // FIXED: Include available in copyWith return
//       certificates: certificates ?? this.certificates,
//       rating: rating ?? this.rating,
//       reviews: reviews ?? this.reviews,
//       fcmToken: fcmToken ?? this.fcmToken,
//     );
//   }
// }
//
// CHANGED_FOR_FIREBASE_INTEGRATION: User model matching exact schema requirements
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_model.dart';

// ✅ 1. تم إضافة العملة الجديدة هنا
enum Currency { egp, usd, sar, yerNew, yerOld, aed }

extension CurrencyExtension on Currency {
  String get arabicName {
    switch (this) {
      case Currency.egp:
        return 'جنيه مصري';
      case Currency.usd:
        return 'دولار أمريكي';
      case Currency.sar:
        return 'ريال سعودي';
      case Currency.yerNew:
        return 'ريال يمني (جديد)';
      case Currency.yerOld:
        return 'ريال يمني (قديم)';
    // ✅ 2. تم إضافة الاسم العربي هنا
      case Currency.aed:
        return 'درهم إماراتي';
    }
  }

  String get name {
    switch (this) {
      case Currency.egp:
        return 'EGP';
      case Currency.usd:
        return 'USD';
      case Currency.sar:
        return 'SAR';
      case Currency.yerNew:
        return 'YER-new';
      case Currency.yerOld:
        return 'YER-old';
    // ✅ 3. تم إضافة الرمز للحفظ في قاعدة البيانات
      case Currency.aed:
        return 'AED';
    }
  }

  static Currency fromString(String value) {
    switch (value) {
      case 'EGP':
        return Currency.egp;
      case 'USD':
        return Currency.usd;
      case 'SAR':
        return Currency.sar;
      case 'YER-new':
        return Currency.yerNew;
      case 'YER-old':
        return Currency.yerOld;
    // ✅ 4. تم إضافة الرمز للقراءة من قاعدة البيانات
      case 'AED':
        return Currency.aed;
      default:
        return Currency.egp; // Default currency
    }
  }
}

class UserModel {
  final String uid;
  final String role; // 'patient', 'doctor', 'admin'
  final String name;
  final String email;
  final String phone;
  final String? profileImage; // URL from Firebase Storage
  final Currency currency;
  final double walletBalance;
  final DateTime createdAt;

  // Doctor-specific fields
  final String? specialization;
  final GeoPoint? location; // Doctor location
  final bool? verified; // Doctor verification status
  final bool? available; // FIXED: Doctor availability status for receiving emergency requests
  final List<String>? certificates; // Array of URLs from Firebase Storage
  final double? rating; // 1-5 rating
  final List<Review>? reviews; // Array of review objects

  // FCM token for notifications
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.currency,
    required this.walletBalance,
    required this.createdAt,
    this.profileImage,
    this.specialization,
    this.location,
    this.verified,
    this.available, // FIXED: Added available parameter
    this.certificates,
    this.rating,
    this.reviews,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Parse reviews array
    List<Review>? parseReviews() {
      final reviewsData = map['reviews'];
      if (reviewsData == null) return null;
      if (reviewsData is List) {
        return reviewsData
            .map((reviewMap) => Review.fromMap(Map<String, dynamic>.from(reviewMap)))
            .toList();
      }
      return null;
    }

    return UserModel(
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'patient',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      currency: CurrencyExtension.fromString(map['currency'] ?? 'EGP'),
      walletBalance: (map['walletBalance'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specialization: map['specialization'],
      location: map['location'] as GeoPoint?,
      verified: map['verified'],
      available: map['available'] ?? true, // FIXED: Default to true for new doctors
      certificates: map['certificates'] != null
          ? List<String>.from(map['certificates'])
          : null,
      rating: map['rating']?.toDouble(),
      reviews: parseReviews(),
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'currency': currency.name,
      'walletBalance': walletBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      if (profileImage != null) 'profileImage': profileImage,
      if (specialization != null) 'specialization': specialization,
      if (location != null) 'location': location,
      if (verified != null) 'verified': verified,
      if (available != null) 'available': available, // FIXED: Include available in toMap
      if (certificates != null) 'certificates': certificates,
      if (rating != null) 'rating': rating,
      if (reviews != null) 'reviews': reviews!.map((review) => review.toMap()).toList(),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? role,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    Currency? currency,
    double? walletBalance,
    DateTime? createdAt,
    String? specialization,
    GeoPoint? location,
    bool? verified,
    bool? available, // FIXED: Added available to copyWith
    List<String>? certificates,
    double? rating,
    List<Review>? reviews,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      currency: currency ?? this.currency,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      specialization: specialization ?? this.specialization,
      location: location ?? this.location,
      verified: verified ?? this.verified,
      available: available ?? this.available, // FIXED: Include available in copyWith return
      certificates: certificates ?? this.certificates,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
