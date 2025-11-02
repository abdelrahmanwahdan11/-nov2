import 'package:flutter_test/flutter_test.dart';

bool canScan(DateTime start, DateTime end, DateTime check) {
  final windowStart = start.subtract(const Duration(minutes: 15));
  final windowEnd = end.add(const Duration(minutes: 15));
  return check.isAfter(windowStart) && check.isBefore(windowEnd);
}

void main() {
  test('qr check-in accepts timestamps inside ±15 minutes window', () {
    final start = DateTime(2024, 1, 1, 10);
    final end = DateTime(2024, 1, 1, 11);
    final inside = DateTime(2024, 1, 1, 9, 55);
    final outside = DateTime(2024, 1, 1, 11, 20);

    expect(canScan(start, end, inside), isTrue);
    expect(canScan(start, end, outside), isFalse);
  });
}
