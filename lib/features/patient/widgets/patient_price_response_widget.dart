// Patient Price Response Widget - For accepting/rejecting doctor's price
import 'package:flutter/material.dart';
import '../../../services/request_service.dart';

class PatientPriceResponseWidget extends StatefulWidget {
  final String requestId;
  final double price;
  final String currency;
  final VoidCallback? onResponse;

  const PatientPriceResponseWidget({
    super.key,
    required this.requestId,
    required this.price,
    required this.currency,
    this.onResponse,
  });

  @override
  State<PatientPriceResponseWidget> createState() => _PatientPriceResponseWidgetState();
}

class _PatientPriceResponseWidgetState extends State<PatientPriceResponseWidget> {
  final RequestService _requestService = RequestService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
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
                  Icons.notifications,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'السعر المقترح من الطبيب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سعر الخدمة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${widget.price.toStringAsFixed(2)} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'عمولة المنصة (12%):',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${(widget.price * 0.12).toStringAsFixed(2)} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'صافي الأرباح للطبيب:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(widget.price * 0.88).toStringAsFixed(2)} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'هل توافق على هذا السعر؟',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _rejectPrice,
                  icon: const Icon(Icons.close),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _acceptPrice,
                  icon: const Icon(Icons.check),
                  label: const Text('قبول'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptPrice() async {
    await _respondToPrice(true);
  }

  Future<void> _rejectPrice() async {
    await _respondToPrice(false);
  }

  Future<void> _respondToPrice(bool accepted) async {
    setState(() => _isLoading = true);

    try {
      await _requestService.respondToDoctorPrice(
        requestId: widget.requestId,
        accepted: accepted,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accepted 
                  ? 'تم قبول السعر بنجاح' 
                  : 'تم رفض السعر',
            ),
            backgroundColor: accepted ? Colors.green : Colors.orange,
          ),
        );
        widget.onResponse?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الرد على السعر: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
