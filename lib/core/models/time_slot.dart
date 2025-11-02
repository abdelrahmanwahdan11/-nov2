class TimeSlot {
  const TimeSlot({required this.start, required this.end});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  final DateTime start;
  final DateTime end;

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  Duration get duration => end.difference(start);

  TimeSlot copyWith({DateTime? start, DateTime? end}) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  bool overlaps(TimeSlot other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
}
