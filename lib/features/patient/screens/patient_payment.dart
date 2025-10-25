import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentMethod;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'cash',
      name: 'دفع نقداً',
      description: 'الدفع عند استلام الخدمة',
      icon: Icons.attach_money,
      iconColor: Colors.grey[700]!,
      backgroundColor: Colors.grey[100]!,
    ),
    PaymentMethod(
      id: 'kareemy',
      name: 'محفظة الكريمي',
      description: 'الرقم: 121457619',
      icon: Icons.credit_card,
      iconColor: Colors.blue[600]!,
      backgroundColor: Colors.blue[100]!,
    ),
    PaymentMethod(
      id: 'jeeb',
      name: 'محفظة جيب',
      description: 'رقم المحفظة: 244379',
      icon: Icons.phone_android,
      iconColor: Colors.green[600]!,
      backgroundColor: Colors.green[100]!,
    ),
    PaymentMethod(
      id: 'onecash',
      name: 'محفظة وان كاش',
      description: 'الرقم المحفظة: 103977388',
      icon: Icons.phone_android,
      iconColor: Colors.purple[600]!,
      backgroundColor: Colors.purple[100]!,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // from-red-50 equivalent
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header content
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'العودة للرئيسية',
                                style: TextStyle(
                                  fontFamily: 'Janna',
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'الدفع الإلكتروني',
                          style: TextStyle(
                            fontFamily: 'Janna',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Payment card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[100]!,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اختر طريقة الدفع',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'يمكنك شحن رصيد محفظتك باستخدام إحدى الطرق التالية',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content section
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Amount input
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المبلغ المراد شحنه (ر.س)',
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'أدخل المبلغ',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Janna',
                                            color: Colors.grey[500],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.red[500]!,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Payment methods
                                  Column(
                                    children: _paymentMethods.map((method) {
                                      return _buildPaymentMethodCard(method);
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),

                                  // Pay button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _selectedPaymentMethod != null &&
                                          _amountController.text.isNotEmpty
                                          ? () {
                                        _processPayment();
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        textStyle: TextStyle(
                                          fontFamily: 'Janna',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text('إتمام الدفع'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.red[500]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method.id;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: method.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    method.icon,
                    color: method.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: TextStyle(
                          fontFamily: 'Janna',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.description,
                        style: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Selection indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.red[500]! : Colors.grey[300]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.red[500]! : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    if (_selectedPaymentMethod != null && _amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null && amount > 0) {
        // Process payment logic
        print('Processing payment: $amount via $_selectedPaymentMethod');

        // Show success dialog or navigate
        _showPaymentSuccessDialog(amount);
      }
    }
  }

  void _showPaymentSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تم الدفع بنجاح',
          style: TextStyle(
            fontFamily: 'Janna',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'تم شحن مبلغ $amount ر.س بنجاح',
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'تم',
                style: TextStyle(
                  fontFamily: 'Janna',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}