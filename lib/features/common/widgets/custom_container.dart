import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomContainer extends StatelessWidget {
 const  CustomContainer({
    super.key,
    this.width = 300,
    this.height = 400,
    this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.iconColor,
   this.onPressed, required this.buttonColor, required this.circleAvatarIconColor,

  });
  final double width;
  final double height;
  final String? image;
  final String title;

  final String description;
  final String buttonText;
  final Color circleAvatarIconColor;
  final Color buttonColor;
  final Color iconColor;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: width, // مرنة حسب الشاشة
      height: height,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,


        children: [
          //const SizedBox(height: 40),
          Spacer(),
          CircleAvatar(
            radius: 50,
            backgroundColor: circleAvatarIconColor,
            child: image != null
                ? SvgPicture.asset(
              image!,
              color: iconColor, // Apply the iconColor
              width: 50,
              height: 50,
            )
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign:TextAlign.end,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              color:Colors.white,
              fontFamily: 'janna',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign:TextAlign.center,
            style: TextStyle(
              fontFamily: 'janna',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width * 0.8, 60),
              backgroundColor:iconColor, // لون الخلفية
              foregroundColor: Colors.white, // لون النص
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // نصف القطر (radius)
              ),
            ),
            child: Text(
              buttonText,

              style: TextStyle(fontFamily: 'janna',fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Spacer()
        ],
      ),
    );
  }
}