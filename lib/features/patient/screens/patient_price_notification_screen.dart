// Patient Price Notification Screen - Shows doctor's price and allows response
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/request_model.dart';
import '../../../services/request_service.dart';
import '../widgets/patient_price_response_widget.dart';

class PatientPriceNotificationScreen extends ConsumerStatefulWidget {
  final String requestId;

  const PatientPriceNotificationScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<PatientPriceNotificationScreen> createState() => _PatientPriceNotificationScreenState();
}

class _PatientPriceNotificationScreenState extends ConsumerState<PatientPriceNotificationScreen> {
  final RequestService _requestService = RequestService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إشعار السعر'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('requests').doc(widget.requestId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل البيانات: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('الطلب غير موجود'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? '';

          // Only show price response if status is 'price_set'
          if (status != 'price_set') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'accepted' ? Icons.check_circle : Icons.info,
                    size: 64,
                    color: status == 'accepted' ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status == 'accepted' 
                        ? 'تم قبول السعر مسبقاً'
                        : 'لم يتم تحديد السعر بعد',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final price = (data['price'] as num?)?.toDouble() ?? 0.0;
          final currency = data['currency'] as String? ?? 'EGP';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Request details card
                _buildRequestDetailsCard(data),
                const SizedBox(height: 20),
                
                // Price response widget
                PatientPriceResponseWidget(
                  requestId: widget.requestId,
                  price: price,
                  currency: currency,
                  onResponse: () {
                    // Navigate back or refresh
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestDetailsCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('الأعراض:', data['symptoms'] ?? 'غير محدد'),
          const SizedBox(height: 8),
          _buildDetailRow('مستوى الأولوية:', _getUrgencyText(data['urgencyLevel'] ?? 'medium')),
          const SizedBox(height: 8),
          _buildDetailRow('الموقع:', data['patientAddress'] ?? 'غير محدد'),
          const SizedBox(height: 8),
          _buildDetailRow('تاريخ الطلب:', _formatDate(data['createdAt'])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getUrgencyText(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'low':
        return 'منخفض';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'عالي';
      case 'critical':
        return 'حرج';
      default:
        return 'متوسط';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return 'غير محدد';
    }
    
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
