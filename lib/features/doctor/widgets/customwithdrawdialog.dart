// import 'package:flutter/material.dart';
//
// class WithdrawDialog extends StatefulWidget {
//   const WithdrawDialog({super.key});
//
//   @override
//   State<WithdrawDialog> createState() => _WithdrawDialogState();
// }
//
// class _WithdrawDialogState extends State<WithdrawDialog> {
//   String? _selectedMethod;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 400),
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               spreadRadius: 2,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             /// زر الإغلاق
//             Positioned(
//               left: 0,
//               top: 0,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.grey, size: 28),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//
//             /// المحتوى
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 8),
//                 const Text(
//                   "سحب الأموال",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   "اختر طريقة السحب المناسبة وأدخل البيانات المطلوبة:",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// طرق السحب
//                 Column(
//                   children: [
//                     _buildMethodOption(
//                       title: "حساب بنكي",
//                       value: "bank",
//                       color: Colors.green,
//                     ),
//                     const SizedBox(height: 12),
//                     _buildMethodOption(
//                       title: "بايبال",
//                       value: "paypal",
//                       color: Colors.blue,
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 /// المبلغ المتاح
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Text("المبلغ المتاح للسحب:",
//                         style: TextStyle(color: Colors.black87)),
//                     SizedBox(width: 6),
//                     Text(
//                       "65 ر.س",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                           fontSize: 16),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// زر التأكيد
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       elevation: 4,
//                     ).copyWith(
//                       backgroundColor: WidgetStateProperty.resolveWith<Color>(
//                             (states) {
//                           if (states.contains(WidgetState.hovered)) {
//                             return Colors.green.shade700;
//                           }
//                           return Colors.green;
//                         },
//                       ),
//                     ),
//                     onPressed: () {
//                       if (_selectedMethod == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("يرجى اختيار طريقة السحب"),
//                           ),
//                         );
//                         return;
//                       }
//                       // هنا تعمل Action السحب
//                     },
//                     child: const Text(
//                       "تأكيد السحب",
//                       style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMethodOption({
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     bool selected = _selectedMethod == value;
//
//     return InkWell(
//       onTap: () {
//         setState(() => _selectedMethod = value);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: selected ? color : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Radio<String>(
//               value: value,
//               groupValue: _selectedMethod,
//               activeColor: color,
//               onChanged: (val) {
//                 setState(() => _selectedMethod = val);
//               },
//             ),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class WithdrawDialog extends StatefulWidget {
  const WithdrawDialog({super.key});

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  String? _selectedMethod;
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _paypalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              /// زر الإغلاق
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        
              /// المحتوى
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "سحب الأموال",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "اختر طريقة السحب المناسبة وأدخل البيانات المطلوبة:",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[60], fontSize: 16),
                  ),
                  const SizedBox(height: 20),
        
                  /// طرق السحب
                  Column(
                    children: [
                      _buildMethodOption(
                        title: "حساب بنكي",
                        value: "bank",
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildMethodOption(
                        title: "PayPal",
                        value: "paypal",
                        color: Colors.blue,
                      ),
                    ],
                  ),
        
                  const SizedBox(height: 20),
        
                  /// الحقول بناءً على الاختيار
                  if (_selectedMethod == "bank") _buildBankFields(),
                  if (_selectedMethod == "paypal") _buildPaypalField(),
        
                  const SizedBox(height: 20),
        
                  /// المبلغ المتاح
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("المبلغ المتاح للسحب:",
                          style: TextStyle(color: Colors.black87)),
                      SizedBox(width: 6),
                      Text(
                        "65 ر.س",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
        
                  /// زر التأكيد
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 4,
                      ),
                      onPressed: _confirmWithdraw,
                      child: const Text(
                        "تأكيد السحب",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- خيارات السحب ----------------
  Widget _buildMethodOption({
    required String title,
    required String value,
    required Color color,
  }) {
    bool selected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedMethod = value);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 2,
          ),
          color: selected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: color,
              onChanged: (val) {
                setState(() => _selectedMethod = val);
              },
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- حقول البنك ----------------
  Widget _buildBankFields() {
    return Column(
      children: [
        _buildTextField("اسم البنك", "اسم البنك", _bankNameController),
        const SizedBox(height: 12),
        _buildTextField("رقم الحساب البنكي", "رقم الحساب", _accountNumberController),
        const SizedBox(height: 12),
        _buildTextField("رقم الآيبان (IBAN)", "SA...", _ibanController),
      ],
    );
  }

  /// ---------------- حقل PayPal ----------------
  Widget _buildPaypalField() {
    return _buildTextField("حساب PayPal", "example@email.com", _paypalController);
  }

  /// ---------------- حقل إدخال عام ----------------
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  /// ---------------- تنفيذ السحب ----------------
  void _confirmWithdraw() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار طريقة السحب")),
      );
      return;
    }

    if (_selectedMethod == "bank") {
      if (_bankNameController.text.isEmpty ||
          _accountNumberController.text.isEmpty ||
          _ibanController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إدخال بيانات البنك كاملة")),
        );
        return;
      }
      // هنا كود تنفيذ التحويل البنكي
    } else if (_selectedMethod == "paypal") {
      if (_paypalController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إدخال حساب PayPal")),
        );
        return;
      }
      // هنا كود تنفيذ التحويل عبر PayPal
    }
  }
}

