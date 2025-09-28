import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientLoginPage extends StatelessWidget {
  PatientLoginPage({super.key});
  final ValueNotifier<bool> obscureNotifier = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back to home button
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_left,
                          color: Colors.red,
                          size: 30,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'العودة للرئيسية',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 18,
                            fontFamily: 'janna',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Heart icon in circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[500]!, Colors.red[800]!],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title and description
                  Text(
                    'دخول المرضى',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      fontFamily: 'janna',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بياناتك للوصول إلى الخدمات الطبية',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontFamily: 'janna',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login form
                  Form(
                    child: Column(
                      children: [
                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'البريد الإلكتروني',
                              style: TextStyle(
                                fontFamily: 'janna',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'patient@example.com',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.red[600]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'كلمة المرور',
                              style: TextStyle(
                                fontFamily: 'janna',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<bool>(
                              valueListenable: obscureNotifier,
                              builder: (context, obscure, child) {
                                return TextFormField(
                                  obscureText: obscure,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.red[600]!,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.visibility,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        obscureNotifier.value =
                                            !obscureNotifier.value;
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle login
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'دخول',
                              style: TextStyle(fontFamily: 'janna'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Clear data button
                        TextButton(
                          onPressed: () {
                            // Clear stored data
                          },
                          child: Text(
                            'مسح البيانات المخزنة',
                            style: TextStyle(
                              fontFamily: 'janna',
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register button
                  TextButton(
                    onPressed: () {
                      // Navigate to registration
                    },
                    child: Text(
                      'لا تمتلك حساب؟ سجل الآن',
                      style: TextStyle(
                        fontFamily: 'janna',
                        color: Colors.red[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Emergency request button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'طلب طوارئ فوري',
                          style: TextStyle(
                            fontFamily: 'janna',
                            color: Colors.red[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
