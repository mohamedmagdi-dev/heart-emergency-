import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heart_emergency/core/constants/app_colors.dart';
import 'package:heart_emergency/core/constants/app_strings.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, // اتجاه البداية
            end: Alignment.bottomRight, // اتجاه النهاية
            colors: [
              AppColor.lightPrimary,
              AppColor.lightSecondary,
              AppColor.lightError,
            ],
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              "ابدأ رحلتك معنا الآن",
              style: TextStyle(
                fontFamily: 'janna',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.lightOnPrimary,
              ),
            ),
            Text(
              "اختر نوع حسابك للوصول إلى الخدمات المتاحة",
              style: TextStyle(
                fontFamily: 'janna',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColor.lightOnPrimary,
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 600,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                children: [
                  CustomContainer(
                    circleAvatarIconColor: AppColor.circleAvatarColor1,
                    buttonColor: Colors.red,
                    title: "مريض",
                    description:
                        "احجز موعد مع طبيب واحصل علي الرعايه الطبيه في منزلك",
                    image: "assets/images/heart.svg",
                    width: screenWidth * 0.8,
                    height: 480,
                    buttonText: AppStrings.loginText,
                    iconColor: Colors.red,
                    onPressed: () {
                      context.push('/patient/login');
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PatientLoginPage(),));
                    },
                  ),
                  const SizedBox(width: 16),
                  CustomContainer(
                    circleAvatarIconColor: AppColor.circleAvatarColor2,
                    buttonColor: Colors.red,
                    title: "طبيب",
                    description:
                        "انضم إلى شبكة الأطباء واحصل على طلبات العلاج المنزلي",
                    image: "assets/images/stethoscope.svg",
                    width: screenWidth * 0.8,
                    height: 480,
                    buttonText: AppStrings.loginText,
                    iconColor: AppColor.containerButtonColor2,
                    onPressed: () {
                      context.push('/doctor/login');
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorLoginPage(),));
                    },
                  ),
                  const SizedBox(width: 16),
                  CustomContainer(
                    circleAvatarIconColor: AppColor.circleAvatarColor3,
                    buttonColor: Colors.red,
                    title: "مدير",
                    description: "إدارة النظام والأطباء ومراقبة جميع العمليات",
                    image: "assets/images/shield.svg",
                    width: screenWidth * 0.8,
                    height: 480,
                    buttonText: "لوحة التحكم",
                    iconColor: AppColor.containerButtonColor3,
                    onPressed: () {
                      context.push('/admin/login');
                    },
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
