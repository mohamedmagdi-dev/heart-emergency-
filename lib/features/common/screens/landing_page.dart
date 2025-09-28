import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heart_emergency/core/utils/helpers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/onboarding_cards.dart';
import '../widgets/onboarding_indicator.dart';



PageController _pageController = PageController();

int _currentPage = 0;


class LandingPage extends StatefulWidget {
   const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.037,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox( height: 200 ,child: Image.asset(AppImages.logo)),
              Expanded(
                child: PageView(
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  controller: _pageController,
                  children: const [
                    CardOfImageText(
                      imagePath: AppImages.logo,
                      textOne:'مرحبا بك في تطبيقنا',
                      textTwo:'من قلب الطوارئ',
                    ),
                    CardOfImageText(
                      imagePath: 'assets/images/onboarding/mosque.png',
                      textOne: 'Welcome To Islami',
                      textTwo:
                      'We Are Very Excited To Have You In Our Community',
                    ),
                    CardOfImageText(
                      imagePath: 'assets/images/onboarding/quran.png',
                      textOne: 'Reading the Quran',
                      textTwo: 'Read, and your Lord is the Most Generous',
                    ),
                    CardOfImageText(
                      imagePath: 'assets/images/onboarding/seb7a.png',
                      textOne: 'Bearish',
                      textTwo: 'Praise the name of your Lord, the Most High',
                    ),
                    CardOfImageText(
                      imagePath: 'assets/images/onboarding/microphone.png',
                      textOne: 'Holy Quran Radio',
                      textTwo:
                      'You can listen to the Holy Quran Radio through the application for free and easily',
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _currentPage != 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: () {
                        if (_currentPage == 0) return;
                        setState(() {
                          _pageController.previousPage(
                            duration: Durations.medium1,
                            curve: Curves.easeIn,
                          );
                        });
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFFE2BE7F),
                          fontFamily: 'Janna',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  IndcatorWidget(activeIndex: _currentPage),

                  TextButton(
                    onPressed: () {
                      if (_currentPage == 4) {
                        context.go('/test');
                        return;
                      }
                      setState(() {
                        _pageController.nextPage(
                          duration: Durations.medium1,
                          curve: Curves.easeIn,
                        );
                      });
                    },
                    child: Text(
                      _currentPage == 4 ? 'Finsh' : 'next',
                      style: const TextStyle(
                        color: Color(0xFFE2BE7F),
                        fontFamily: 'Janna',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
}
