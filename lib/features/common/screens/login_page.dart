// import 'package:flutter/material.dart';
//
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Dashboard')),
//       body: const Center(child: Text('Test Dashboard')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:heart_emergency/core/constants/app_strings.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/custom_container.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,   // اتجاه البداية
            end: Alignment.bottomRight, // اتجاه النهاية
            colors: [
              Color(0xFF1E3C72), // أزرق غامق
              Color(0xFF8E2DE2), // بنفسجي
              Color(0xFFED213A), // أحمر
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height:48 ),
            Text(
              "ابدأ رحلتك معنا الآن",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "اختر نوع حسابك للوصول إلى الخدمات المتاحة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            //           Row(
            //             children: [
            // CustomContainer(),
            //             ],
            //           )
            SizedBox(
              height: 500,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                children: [
                  CustomContainer(

                    title: "مريض",
                    description: "احجز موعد مع طبيب واحصل علي الرعايه الطبيه في منزلك",
                 image: "assets/images/heart.svg",
                      width: screenWidth * 0.8, height: 480, buttonText: AppStrings.loginText, iconColor:Colors.red,
                  ),
                  const SizedBox(width: 16),
                  CustomContainer(
                    image: "assets/images/stethoscope.svg",

                      width: screenWidth * 0.8, height: 480, title: 'طبيب', description: '  انضم إلى شبكة الأطباء واحصل على طلبات العلاج المنزلي', buttonText:AppStrings.loginText, iconColor:AppColor.containerButtonColor2,
                  ),
                  const SizedBox(width: 16),
                  CustomContainer(
                    
                      width: screenWidth * 0.8, height: 480, title: '', description: 'إدارة النظام والأطباء ومراقبة جميع العمليات ', buttonText: '', iconColor:AppColor.containerButtonColor3 ,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

