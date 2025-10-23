// Doctor earnings model for tracking financial data
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorEarnings {
  final String doctorId;
  final int totalRequests;
  final double totalEarnings;
  final double platformCommission;
  final double netEarnings;
  final String currency;
  final DateTime lastUpdated;
  final DateTime? lastRequestDate;

  DoctorEarnings({
    required this.doctorId,
    required this.totalRequests,
    required this.totalEarnings,
    required this.platformCommission,
    required this.netEarnings,
    required this.currency,
    required this.lastUpdated,
    this.lastRequestDate,
  });

  factory DoctorEarnings.fromMap(Map<String, dynamic> map) {
    return DoctorEarnings(
      doctorId: map['doctorId'] ?? '',
      totalRequests: map['totalRequests'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      platformCommission: (map['platformCommission'] ?? 0.0).toDouble(),
      netEarnings: (map['netEarnings'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'EGP',
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastRequestDate: (map['lastRequestDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'totalRequests': totalRequests,
      'totalEarnings': totalEarnings,
      'platformCommission': platformCommission,
      'netEarnings': netEarnings,
      'currency': currency,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      if (lastRequestDate != null) 'lastRequestDate': Timestamp.fromDate(lastRequestDate!),
    };
  }

  DoctorEarnings copyWith({
    String? doctorId,
    int? totalRequests,
    double? totalEarnings,
    double? platformCommission,
    double? netEarnings,
    String? currency,
    DateTime? lastUpdated,
    DateTime? lastRequestDate,
  }) {
    return DoctorEarnings(
      doctorId: doctorId ?? this.doctorId,
      totalRequests: totalRequests ?? this.totalRequests,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      platformCommission: platformCommission ?? this.platformCommission,
      netEarnings: netEarnings ?? this.netEarnings,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastRequestDate: lastRequestDate ?? this.lastRequestDate,
    );
  }

  // Calculate commission rate as percentage
  double get commissionRatePercentage {
    if (totalEarnings == 0) return 0.0;
    return (platformCommission / totalEarnings) * 100;
  }

  // Format currency amount
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} $currency';
  }
}

class EarningsBreakdown {
  final double totalEarnings;
  final double platformCommission;
  final double netEarnings;
  final double commissionRate;
  final String currency;

  EarningsBreakdown({
    required this.totalEarnings,
    required this.platformCommission,
    required this.netEarnings,
    required this.commissionRate,
    required this.currency,
  });

  factory EarningsBreakdown.calculate({
    required double totalEarnings,
    required double commissionRate,
    required String currency,
  }) {
    final platformCommission = totalEarnings * commissionRate;
    final netEarnings = totalEarnings - platformCommission;

    return EarningsBreakdown(
      totalEarnings: totalEarnings,
      platformCommission: platformCommission,
      netEarnings: netEarnings,
      commissionRate: commissionRate,
      currency: currency,
    );
  }
}
