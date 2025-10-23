// Enhanced Local Notification Service for request status and verification updates
import 'package:flutter/foundation.dart';
import '../features/notifications/notfication_services.dart';
import '../data/models/request_model.dart';
import '../data/models/user_model.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  /// Show notification when request is accepted by doctor
  Future<void> showRequestAcceptedNotification({
    required String doctorName,
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم قبول طلبك 🎉',
        body: 'قبل د. $doctorName طلب الطوارئ الخاص بك',
        payload: 'request_accepted:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Request accepted notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending request accepted notification: $e');
      }
    }
  }

  /// Show notification when request is rejected by doctor
  Future<void> showRequestRejectedNotification({
    required String doctorName,
    required String requestId,
    String? reason,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم رفض طلبك 😔',
        body: reason != null 
            ? 'رفض د. $doctorName طلبك. السبب: $reason'
            : 'رفض د. $doctorName طلب الطوارئ الخاص بك',
        payload: 'request_rejected:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Request rejected notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending request rejected notification: $e');
      }
    }
  }

  /// Show notification when request is completed
  Future<void> showRequestCompletedNotification({
    required String doctorName,
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم إكمال الخدمة ✅',
        body: 'أكمل د. $doctorName خدمة الطوارئ الخاصة بك بنجاح',
        payload: 'request_completed:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Request completed notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending request completed notification: $e');
      }
    }
  }

  /// Show notification when doctor account is verified by admin
  Future<void> showDoctorVerifiedNotification({
    required String doctorName,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم توثيق حسابك 🎉',
        body: 'مبروك! تم توثيق حسابك من قبل الإدارة. يمكنك الآن استقبال المرضى',
        payload: 'doctor_verified',
      );
      
      if (kDebugMode) {
        print('✅ Doctor verification notification sent for: $doctorName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending doctor verification notification: $e');
      }
    }
  }

  /// Show notification when doctor account verification is rejected
  Future<void> showDoctorVerificationRejectedNotification({
    required String doctorName,
    String? reason,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم رفض توثيق حسابك ❌',
        body: reason != null 
            ? 'تم رفض توثيق حسابك من قبل الإدارة. السبب: $reason'
            : 'تم رفض توثيق حسابك من قبل الإدارة. يرجى التواصل مع الدعم',
        payload: 'doctor_verification_rejected',
      );
      
      if (kDebugMode) {
        print('✅ Doctor verification rejected notification sent for: $doctorName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending doctor verification rejected notification: $e');
      }
    }
  }

  /// Show notification when doctor is on the way to patient
  Future<void> showDoctorOnTheWayNotification({
    required String doctorName,
    required String requestId,
    String? estimatedTime,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'الطبيب في الطريق 🚗',
        body: estimatedTime != null 
            ? 'د. $doctorName في الطريق إليك. الوقت المتوقع: $estimatedTime'
            : 'د. $doctorName في الطريق إليك الآن',
        payload: 'doctor_on_way:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Doctor on the way notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending doctor on the way notification: $e');
      }
    }
  }

  /// Show notification when doctor arrives at patient location
  Future<void> showDoctorArrivedNotification({
    required String doctorName,
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'وصل الطبيب 📍',
        body: 'وصل د. $doctorName إلى موقعك. يمكنك الآن الخروج للقائه',
        payload: 'doctor_arrived:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Doctor arrived notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending doctor arrived notification: $e');
      }
    }
  }

  /// Show notification for new emergency request (for doctors)
  Future<void> showNewEmergencyRequestNotification({
    required String patientName,
    required String requestId,
    String? symptoms,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'طلب طوارئ جديد 🚨',
        body: symptoms != null 
            ? 'طلب طوارئ من $patientName. الأعراض: $symptoms'
            : 'طلب طوارئ جديد من $patientName',
        payload: 'new_emergency_request:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ New emergency request notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending new emergency request notification: $e');
      }
    }
  }

  /// Show notification for payment received
  Future<void> showPaymentReceivedNotification({
    required double amount,
    required String currency,
    String? requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم استلام الدفع 💰',
        body: 'تم استلام مبلغ $amount $currency بنجاح',
        payload: requestId != null ? 'payment_received:$requestId' : 'payment_received',
      );
      
      if (kDebugMode) {
        print('✅ Payment received notification sent for amount: $amount $currency');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending payment received notification: $e');
      }
    }
  }

  /// Show notification for commission earned
  Future<void> showCommissionEarnedNotification({
    required double commission,
    required String currency,
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'عمولة جديدة 💵',
        body: 'تم إضافة عمولة $commission $currency إلى رصيدك',
        payload: 'commission_earned:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Commission earned notification sent for amount: $commission $currency');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending commission earned notification: $e');
      }
    }
  }

  /// Show notification for rating received
  Future<void> showRatingReceivedNotification({
    required double rating,
    required String patientName,
    String? review,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تقييم جديد ⭐',
        body: review != null 
            ? 'تقييم $rating/5 من $patientName: "$review"'
            : 'تقييم $rating/5 من $patientName',
        payload: 'rating_received',
      );
      
      if (kDebugMode) {
        print('✅ Rating received notification sent: $rating stars from $patientName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending rating received notification: $e');
      }
    }
  }

  /// Show general system notification
  Future<void> showSystemNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: title,
        body: body,
        payload: payload,
      );
      
      if (kDebugMode) {
        print('✅ System notification sent: $title');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending system notification: $e');
      }
    }
  }

  /// Show notification when doctor sets a price
  Future<void> showPriceSetNotification({
    required double amount,
    required String currency,
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم تحديد السعر 💰',
        body: 'قام الطبيب بتحديد السعر: ${amount.toStringAsFixed(2)} $currency',
        payload: 'price_set:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Price set notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending price set notification: $e');
      }
    }
  }

  /// Show notification when patient accepts doctor's price
  Future<void> showPriceAcceptedNotification({
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم قبول السعر ✅',
        body: 'وافق المريض على السعر المقترح',
        payload: 'price_accepted:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Price accepted notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending price accepted notification: $e');
      }
    }
  }

  /// Show notification when patient declines doctor's price
  Future<void> showPriceDeclinedNotification({
    required String requestId,
  }) async {
    try {
      await NotificationService.showLocalNotification(
        title: 'تم رفض السعر ❌',
        body: 'رفض المريض السعر المقترح',
        payload: 'price_declined:$requestId',
      );
      
      if (kDebugMode) {
        print('✅ Price declined notification sent for request: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending price declined notification: $e');
      }
    }
  }
}
