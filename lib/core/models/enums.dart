enum Level { beginner, intermediate, advanced }

enum Sport { football, basketball, padel, tennis, running }

enum EventType { street, walk, challenge }

enum TimeWindow { morning, evening }

enum BookingStatus { pending, confirmed, cancelled }

enum WalletType { credit, debit }

Level levelFromString(String value) {
  return Level.values.firstWhere((element) => element.name == value);
}

Sport sportFromString(String value) {
  return Sport.values.firstWhere((element) => element.name == value);
}

EventType eventTypeFromString(String value) {
  return EventType.values.firstWhere((element) => element.name == value);
}

TimeWindow timeWindowFromString(String value) {
  return TimeWindow.values.firstWhere((element) => element.name == value);
}

BookingStatus bookingStatusFromString(String value) {
  return BookingStatus.values.firstWhere((element) => element.name == value);
}

WalletType walletTypeFromString(String value) {
  return WalletType.values.firstWhere((element) => element.name == value);
}
