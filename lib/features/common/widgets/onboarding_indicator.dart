import 'package:flutter/material.dart';

class IndcatorWidget extends StatelessWidget {
  const IndcatorWidget({super.key, required this.activeIndex});
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        6,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Container(
            width: activeIndex == index ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: Color(activeIndex == index ? 0xFF00008B : 0xFF707070),
            ),
          ),
        ),
      ),
    );
  }
}
