import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_motion.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  late final List<_OnboardingSlide> _slides;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _slides = const [
      _OnboardingSlide(
        imageUrl: 'https://images.unsplash.com/photo-1518600506278-4e8ef466b810',
        titleAr: 'احجز ملعبك بسهولة',
        titleEn: 'Book fields easily',
      ),
      _OnboardingSlide(
        imageUrl: 'https://images.unsplash.com/photo-1517963628607-235ccdd5476e',
        titleAr: 'تحديات وتمارين شارع',
        titleEn: 'Challenges & Street Workouts',
      ),
      _OnboardingSlide(
        imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
        titleAr: 'مسارات مشي موقّتة',
        titleEn: 'Timed walk routes',
      ),
      _OnboardingSlide(
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
        titleAr: 'حساب صحي وقصص محترفين',
        titleEn: 'Health profile & pro stories',
      ),
    ];
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % _slides.length;
      final duration = AppMotion.duration(context, const Duration(milliseconds: 600));
      _controller.animateToPage(
        next,
        duration: duration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final langCode = l10n.languageCode;

    final heroFadeDuration = AppMotion.duration(context, const Duration(milliseconds: 600));
    final controlsFadeDuration = AppMotion.duration(context, const Duration(milliseconds: 400));
    final skipFadeDuration = AppMotion.duration(context, const Duration(milliseconds: 500));

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              final title = langCode == 'ar' ? slide.titleAr : slide.titleEn;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    slide.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: title,
                  ),
                  Container(decoration: const BoxDecoration(gradient: AppGradients.imageOverlay)),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 160,
                    child: Text(
                      title,
                      style: textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: heroFadeDuration)
                        .slideY(begin: 0.3, end: 0),
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 24,
            left: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      width: index == _currentIndex ? 28 : 12,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentIndex
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.t('get_started'),
                  onPressed: () async {
                    await AppStore.instance.markOnboardingDone();
                    if (!mounted) return;
                    AppRouter.instance.setRoot('/auth');
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await AppStore.instance.markOnboardingDone();
                    await AppStore.instance.setAuthenticated(false);
                    if (!mounted) return;
                    AppRouter.instance.setRoot('/home');
                  },
                  child: Text(l10n.t('continue_guest')),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: controlsFadeDuration)
                .slideY(begin: 0.2, end: 0),
          ),
          Positioned(
            top: 56,
            right: 24,
            child: TextButton(
              onPressed: () async {
                await AppStore.instance.markOnboardingDone();
                if (!mounted) return;
                AppRouter.instance.setRoot('/auth');
              },
              child: Text(l10n.t('continue')), // skip to auth
            ),
          )
              .animate()
              .fadeIn(duration: skipFadeDuration)
              .slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.imageUrl,
    required this.titleAr,
    required this.titleEn,
  });

  final String imageUrl;
  final String titleAr;
  final String titleEn;
}
