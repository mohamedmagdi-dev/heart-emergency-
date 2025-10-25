import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heart_emergency/core/cache/shared_pref_cache.dart';
import 'package:heart_emergency/core/utils/helpers.dart';
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
                      imagePath: AppImages.welcomeLogo,
                      textOne:'مرحبا بك في تطبيقنا',
                      textTwo:'نقدم خدمة طبية متكاملة بأعلى معايير الجودة والأمان',
                    ),
                    CardOfImageText(
                      imagePath: AppImages.map,
                      textOne: 'تحديد موقع دقيق',
                      textTwo:
                      'نظام متطور لتحديد موقعك بدقة وإرسال أقرب طبيب إليك',
                    ),
                    CardOfImageText(
                      imagePath: AppImages.shield,
                      textOne: 'أطباء معتمدون',
                      textTwo: 'جميع الأطباء حاصلون على شهادات معتمدة ورخص مزاولة صالحة',
                    ),
                    CardOfImageText(
                      imagePath: AppImages.timer,
                      textOne: 'استجابة سريعة',
                      textTwo: 'وقت استجابة أقل من 15 دقيقة في معظم المناطق',
                    ),
                    CardOfImageText(
                      imagePath: AppImages.wallet,
                      textOne: 'محفظة إلكترونية',
                      textTwo:
                      'نظام دفع آمن ومحفظة إلكترونية لسهولة المعاملات',
                    ),CardOfImageText(
                      imagePath: AppImages.users,
                      textOne: 'دعم 24/7',
                      textTwo:
                      'فريق دعم فني متاح على مدار الساعة لمساعدتك',
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
                          color: Color(0xFF00008B),
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
                      if (_currentPage == 5) {
                        SharedPreference.saveBool("isFirst", false);
                        context.go('/login');
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
                      _currentPage == 5 ? 'Finsh' : 'next',
                      style: const TextStyle(
                        color: Color(0xFF00008B),
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
