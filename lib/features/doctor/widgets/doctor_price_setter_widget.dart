// Doctor Price Setter Widget - For setting price when accepting requests
import 'package:flutter/material.dart';
import '../../../services/request_service.dart';

class DoctorPriceSetterWidget extends StatefulWidget {
  final String requestId;
  final String? patientCurrency;
  final VoidCallback? onPriceSet;

  const DoctorPriceSetterWidget({
    super.key,
    required this.requestId,
    this.patientCurrency,
    this.onPriceSet,
  });

  @override
  State<DoctorPriceSetterWidget> createState() => _DoctorPriceSetterWidgetState();
}

class _DoctorPriceSetterWidgetState extends State<DoctorPriceSetterWidget> {
  final TextEditingController _priceController = TextEditingController();
  final RequestService _requestService = RequestService();
  bool _isLoading = false;
  String? _patientCurrency;

  @override
  void initState() {
    super.initState();
    _patientCurrency = widget.patientCurrency;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تحديد سعر الخدمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'يرجى تحديد السعر المناسب لهذه الخدمة الطبية:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'السعر',
              hintText: 'أدخل السعر بالعملة المحلية',
              suffixText: _patientCurrency ?? 'EGP',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('إرسال السعر'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setPrice() async {
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      _showError('يرجى إدخال السعر');
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showError('يرجى إدخال سعر صحيح أكبر من صفر');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _requestService.setPriceByDoctor(
        requestId: widget.requestId,
        price: price,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال السعر ${price.toStringAsFixed(2)} للمريض'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onPriceSet?.call();
      }
    } catch (e) {
      if (mounted) {
        _showError('خطأ في إرسال السعر: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
