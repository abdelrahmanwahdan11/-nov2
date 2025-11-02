class Strings {
  static const _data = <String, Map<String, String>>{
    'ar': {
      'app_title': 'ساحة',
      'home': 'الرئيسية',
      'explore': 'استكشاف',
      'events': 'الفعاليات',
      'booking': 'الحجز',
      'health': 'الصحة',
      'stories': 'القصص',
      'inbox': 'الرسائل',
      'wallet': 'المحفظة',
      'profile': 'حسابي',
      'create': 'إنشاء',
      'book_now': 'احجز الآن',
      'join': 'انضم',
      'pay': 'ادفع',
      'toggle_theme': 'الوضع الداكن',
      'toggle_locale': 'English',
      'welcome': 'مرحبًا بعودتك',
      'wallet_balance': 'رصيد المحفظة',
      'empty_notifications': 'لا توجد إشعارات بعد',
      'no_results': 'لا توجد نتائج',
    },
    'en': {
      'app_title': 'Saha',
      'home': 'Home',
      'explore': 'Explore',
      'events': 'Events',
      'booking': 'Booking',
      'health': 'Health',
      'stories': 'Stories',
      'inbox': 'Inbox',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'create': 'Create',
      'book_now': 'Book Now',
      'join': 'Join',
      'pay': 'Pay',
      'toggle_theme': 'Dark mode',
      'toggle_locale': 'العربية',
      'welcome': 'Welcome back',
      'wallet_balance': 'Wallet balance',
      'empty_notifications': 'No notifications yet',
      'no_results': 'No results',
    },
  };

  static String of(String locale, String key) {
    return _data[locale]?[key] ?? key;
  }
}
