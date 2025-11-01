import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;

  void _nextStep() {
    setState(() {
      _step = (_step + 1).clamp(0, 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _OnboardingSlide(
        title: 'مرحبًا بك في ساحة',
        description: 'احجز الملاعب، انضم للتحديات، وتابع تقدمك الصحي في مكان واحد.',
      ),
      _OnboardingSlide(
        title: 'اختر أهدافك',
        description: 'حدد مستوى النشاط والمسارات المفضلة لتحصل على اقتراحات مخصصة.',
      ),
      _OnboardingSlide(
        title: 'الاذونات',
        description: 'نستخدم الموقع للتذكير بالمواعيد والإشعارات المحلية فقط.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(child: steps[_step]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _step == index ? 16 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _step == index ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step == steps.length - 1) {
                      Navigator.of(context).pop();
                    } else {
                      _nextStep();
                    }
                  },
                  child: Text(_step == steps.length - 1 ? 'ابدأ' : 'التالي'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.sports_soccer, size: 120, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(description, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
      ],
    );
  }
}
