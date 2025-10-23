// Pricing service for managing doctor and technical team pricing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PricingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Pricing configuration
  static const String _pricingCollection = 'pricing_config';
  static const String _doctorPricingCollection = 'doctor_pricing';

  /// Get default pricing configuration
  Future<PricingConfig> getDefaultPricing() async {
    try {
      final doc = await _firestore.collection(_pricingCollection).doc('default').get();
      
      if (doc.exists) {
        return PricingConfig.fromMap(doc.data()!);
      } else {
        // Return default pricing if no configuration exists
        return PricingConfig(
          basePrice: 50.0,
          pricePerKm: 2.0,
          pricePerMinute: 1.0,
          minimumPrice: 30.0,
          maximumPrice: 500.0,
          currency: 'SAR',
          isActive: true,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting default pricing: $e');
      }
      // Return fallback pricing
      return PricingConfig(
        basePrice: 50.0,
        pricePerKm: 2.0,
        pricePerMinute: 1.0,
        minimumPrice: 30.0,
        maximumPrice: 500.0,
        currency: 'SAR',
        isActive: true,
      );
    }
  }

  /// Get doctor-specific pricing
  Future<PricingConfig?> getDoctorPricing(String doctorId) async {
    try {
      final doc = await _firestore.collection(_doctorPricingCollection).doc(doctorId).get();
      
      if (doc.exists) {
        return PricingConfig.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting doctor pricing: $e');
      }
      return null;
    }
  }

  /// Set doctor-specific pricing (admin/technical team only)
  Future<void> setDoctorPricing({
    required String doctorId,
    required PricingConfig pricing,
    required String adminId,
  }) async {
    try {
      // Verify admin permissions
      final adminDoc = await _firestore.collection('users').doc(adminId).get();
      final adminData = adminDoc.data();
      
      if (adminData?['role'] != 'admin') {
        throw Exception('Only admins can set doctor pricing');
      }

      // Set doctor pricing
      await _firestore.collection(_doctorPricingCollection).doc(doctorId).set({
        ...pricing.toMap(),
        'setBy': adminId,
        'setAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the pricing change
      await _firestore.collection('pricing_logs').add({
        'doctorId': doctorId,
        'adminId': adminId,
        'action': 'pricing_updated',
        'pricing': pricing.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Doctor pricing updated for doctor: $doctorId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting doctor pricing: $e');
      }
      rethrow;
    }
  }

  /// Update default pricing configuration (admin/technical team only)
  Future<void> updateDefaultPricing({
    required PricingConfig pricing,
    required String adminId,
  }) async {
    try {
      // Verify admin permissions
      final adminDoc = await _firestore.collection('users').doc(adminId).get();
      final adminData = adminDoc.data();
      
      if (adminData?['role'] != 'admin') {
        throw Exception('Only admins can update default pricing');
      }

      // Update default pricing
      await _firestore.collection(_pricingCollection).doc('default').set({
        ...pricing.toMap(),
        'updatedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the pricing change
      await _firestore.collection('pricing_logs').add({
        'adminId': adminId,
        'action': 'default_pricing_updated',
        'pricing': pricing.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Default pricing updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating default pricing: $e');
      }
      rethrow;
    }
  }

  /// Get effective pricing for a doctor (doctor-specific or default)
  Future<PricingConfig> getEffectivePricing(String doctorId) async {
    try {
      // Try to get doctor-specific pricing first
      final doctorPricing = await getDoctorPricing(doctorId);
      if (doctorPricing != null && doctorPricing.isActive) {
        return doctorPricing;
      }

      // Fall back to default pricing
      return await getDefaultPricing();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting effective pricing: $e');
      }
      // Return fallback pricing
      return PricingConfig(
        basePrice: 50.0,
        pricePerKm: 2.0,
        pricePerMinute: 1.0,
        minimumPrice: 30.0,
        maximumPrice: 500.0,
        currency: 'SAR',
        isActive: true,
      );
    }
  }

  /// Calculate price based on distance and time
  double calculatePrice({
    required PricingConfig pricing,
    required double distanceKm,
    required double timeMinutes,
    double? trafficMultiplier,
    double? demandMultiplier,
  }) {
    final basePrice = pricing.basePrice;
    final distancePrice = distanceKm * pricing.pricePerKm;
    final timePrice = timeMinutes * pricing.pricePerMinute;
    
    final trafficMultiplierValue = trafficMultiplier ?? 1.0;
    final demandMultiplierValue = demandMultiplier ?? 1.0;
    
    double totalPrice = (basePrice + distancePrice + timePrice) * trafficMultiplierValue * demandMultiplierValue;
    
    // Apply minimum and maximum price limits
    totalPrice = totalPrice.clamp(pricing.minimumPrice, pricing.maximumPrice);
    
    return totalPrice;
  }

  /// Get pricing history for a doctor
  Future<List<PricingHistory>> getPricingHistory(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pricing_logs')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) => PricingHistory.fromMap(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pricing history: $e');
      }
      return [];
    }
  }

  /// Get all doctor pricing configurations
  Future<List<DoctorPricingInfo>> getAllDoctorPricing() async {
    try {
      final querySnapshot = await _firestore.collection(_doctorPricingCollection).get();
      
      List<DoctorPricingInfo> pricingList = [];
      
      for (var doc in querySnapshot.docs) {
        final pricing = PricingConfig.fromMap(doc.data());
        final doctorDoc = await _firestore.collection('users').doc(doc.id).get();
        final doctorData = doctorDoc.data();
        
        pricingList.add(DoctorPricingInfo(
          doctorId: doc.id,
          doctorName: doctorData?['name'] ?? 'Unknown Doctor',
          pricing: pricing,
          lastUpdated: (doc.data()['updatedAt'] as Timestamp?)?.toDate(),
        ));
      }
      
      return pricingList;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all doctor pricing: $e');
      }
      return [];
    }
  }
}

/// Pricing configuration model
class PricingConfig {
  final double basePrice;
  final double pricePerKm;
  final double pricePerMinute;
  final double minimumPrice;
  final double maximumPrice;
  final String currency;
  final bool isActive;

  PricingConfig({
    required this.basePrice,
    required this.pricePerKm,
    required this.pricePerMinute,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.currency,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'basePrice': basePrice,
      'pricePerKm': pricePerKm,
      'pricePerMinute': pricePerMinute,
      'minimumPrice': minimumPrice,
      'maximumPrice': maximumPrice,
      'currency': currency,
      'isActive': isActive,
    };
  }

  factory PricingConfig.fromMap(Map<String, dynamic> map) {
    return PricingConfig(
      basePrice: (map['basePrice'] ?? 50.0).toDouble(),
      pricePerKm: (map['pricePerKm'] ?? 2.0).toDouble(),
      pricePerMinute: (map['pricePerMinute'] ?? 1.0).toDouble(),
      minimumPrice: (map['minimumPrice'] ?? 30.0).toDouble(),
      maximumPrice: (map['maximumPrice'] ?? 500.0).toDouble(),
      currency: map['currency'] ?? 'SAR',
      isActive: map['isActive'] ?? true,
    );
  }
}

/// Pricing history model
class PricingHistory {
  final String doctorId;
  final String adminId;
  final String action;
  final PricingConfig pricing;
  final DateTime timestamp;

  PricingHistory({
    required this.doctorId,
    required this.adminId,
    required this.action,
    required this.pricing,
    required this.timestamp,
  });

  factory PricingHistory.fromMap(Map<String, dynamic> map) {
    return PricingHistory(
      doctorId: map['doctorId'] ?? '',
      adminId: map['adminId'] ?? '',
      action: map['action'] ?? '',
      pricing: PricingConfig.fromMap(map['pricing'] ?? {}),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

/// Doctor pricing info model
class DoctorPricingInfo {
  final String doctorId;
  final String doctorName;
  final PricingConfig pricing;
  final DateTime? lastUpdated;

  DoctorPricingInfo({
    required this.doctorId,
    required this.doctorName,
    required this.pricing,
    this.lastUpdated,
  });
}
