import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../../core/widgets/text_button.dart';
import '../../../auth_feature/presentation/pages/login_screen.dart';
import '../../data/models/onboarding_item_model.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController boardController = PageController();
  bool isLast = false;

  final List<BoardingModel> boarding = [
    BoardingModel(
      image: 'assets/images/onboarding/onboarding1.PNG',
      title: 'إدارة مخزونك بذكاء',
      body: 'تابع كميات الأدوية وتواريخ الصلاحية بكل سهولة وفي مكان واحد',
    ),
    BoardingModel(
      image: 'assets/images/onboarding/onboarding2.jfif',
      title: 'مبيعات سريعة ودقيقة',
      body: 'نظام POS متطور لعمل فواتيرك وخدمة عملائك بأسرع وقت ممكن',
    ),
    BoardingModel(
      image: 'assets/images/onboarding/onboarding3.jfif',
      title: 'تنبيهات فورية',
      body: 'احصل على إشعارات بالأدوية التي قاربت على الانتهاء أو نفاد الكمية',
    ),
  ];

  void submit() {
    CacheHelper.saveData(key: 'onBoarding', value: true).then((value) {
      if (value) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim, secondAnim) => const LoginScreen(),
            transitionsBuilder: (context, anim, secondAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          CustomTextButton(
            text: "تخطي",
            textColor: AppColors.primary,
            fontSize: 16,
            onPressed: submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: boardController,
                physics: const BouncingScrollPhysics(),
                itemCount: boarding.length,
                onPageChanged: (index) {
                  setState(() => isLast = index == boarding.length - 1);
                },
                itemBuilder: (context, index) => _buildBoardingItem(boarding[index]),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                SmoothPageIndicator(
                  controller: boardController,
                  count: boarding.length,
                  effect: const ExpandingDotsEffect(
                    dotColor: Colors.grey,
                    activeDotColor: AppColors.primary,
                    dotHeight: 10,
                    expansionFactor: 4,
                    dotWidth: 10,
                    spacing: 5.0,
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () {
                    if (isLast) {
                      submit();
                    } else {
                      boardController.nextPage(
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.fastLinearToSlowEaseIn,
                      );
                    }
                  },
                  child: Icon(
                    isLast ? Icons.check : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingItem(BoardingModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              model.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          model.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          model.body,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
