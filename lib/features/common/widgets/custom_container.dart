import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';

class CustomContainer extends StatelessWidget {
 const  CustomContainer({
    super.key,
    this.width = 300,
    this.height = 400,
    this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.iconColor, this.onPressed,

  });
  final double width;
  final double height;
  final String? image;
  final String title;

  final String description;
  final String buttonText;
  final Color iconColor;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // مرنة حسب الشاشة
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 50,
            backgroundColor: iconColor,
            child:SvgPicture.asset(image!),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColor.textContainerColor,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor:iconColor, // لون الخلفية
              foregroundColor: Colors.white, // لون النص
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // نصف القطر (radius)
              ),
            ),
            child: Text(
              buttonText,

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
