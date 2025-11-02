import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

bool withinHundredMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  double toRad(double value) => value * pi / 180;
  final dLat = toRad(lat2 - lat1);
  final dLon = toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) + cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = earthRadius * c;
  return distance <= 100;
}

void main() {
  test('gps check-in validates 100m radius', () {
    final venueLat = 24.7136;
    final venueLon = 46.6753;
    final nearby = withinHundredMeters(venueLat, venueLon, 24.7140, 46.6758);
    final far = withinHundredMeters(venueLat, venueLon, 24.7200, 46.6900);

    expect(nearby, isTrue);
    expect(far, isFalse);
  });
}
