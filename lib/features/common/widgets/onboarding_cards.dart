import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardOfImageText extends StatelessWidget {
  const CardOfImageText({
    super.key,
    required this.imagePath,
    required this.textOne,
    this.textTwo,
  });

  final String imagePath, textOne ;
  final String? textTwo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox( height: 300 ,child: Image.asset(imagePath , fit: BoxFit.cover,)),
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                ((textTwo ?? '').isEmpty ? 0.085 : 0.042),
          ),
          Text(
            textOne,
            // textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Janna',
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          if ((textTwo ?? '').isNotEmpty) ...[
            SizedBox(height: MediaQuery.of(context).size.height * 0.042),
            Text(
              textTwo!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'Janna',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
