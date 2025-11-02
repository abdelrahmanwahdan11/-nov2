import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations._(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationDelegate();

  static const Map<String, String> _strings = {
    'app_title': 'ساحة',
    'nav_home': 'الرئيسية',
    'nav_explore': 'استكشاف',
    'nav_create': 'إنشاء',
    'nav_inbox': 'الرسائل',
    'nav_profile': 'حسابي',
    'cta_book_now': 'احجز الآن',
    'cta_join': 'انضم',
    'cta_pay': 'ادفع',
    'filters': 'فلاتر',
    'requirements': 'المتطلبات',
    'level': 'المستوى',
    'price': 'السعر',
    'capacity': 'السعة',
    'location': 'الموقع',
    'time': 'الوقت',
    'health': 'الصحة',
    'stories': 'القصص',
    'wallet': 'المحفظة',
    'checkin': 'تأكيد الحضور',
    'no_results': 'لا توجد نتائج',
    'seed_loaded': 'تم تحميل بيانات التجربة',
    'split_payment': 'تقسيم الدفع',
    'morning': 'الصباح',
    'evening': 'المساء',
  };

  String translate(String key) => _strings[key] ?? key;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations._(Localizations.localeOf(context));
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations._(locale);
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
