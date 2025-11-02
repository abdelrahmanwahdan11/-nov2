import 'enums.dart';

class Booking {
  const Booking({
    required this.id,
    required this.fieldId,
    required this.userIds,
    required this.start,
    required this.end,
    required this.price,
    required this.status,
    required this.splitPayment,
    Map<String, bool>? payments,
  }) : payments = Map.unmodifiable(payments ?? const {});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      userIds: (json['userIds'] as List<dynamic>).cast<String>(),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      price: (json['price'] as num).toDouble(),
      status: bookingStatusFromString(json['status'] as String),
      splitPayment: json['splitPayment'] as bool,
      payments: Map<String, bool>.from(json['payments'] as Map? ?? const {}),
    );
  }

  final String id;
  final String fieldId;
  final List<String> userIds;
  final DateTime start;
  final DateTime end;
  final double price;
  final BookingStatus status;
  final bool splitPayment;
  final Map<String, bool> payments;

  Duration get duration => end.difference(start);

  Booking copyWith({
    List<String>? userIds,
    BookingStatus? status,
    bool? splitPayment,
    Map<String, bool>? payments,
  }) {
    return Booking(
      id: id,
      fieldId: fieldId,
      userIds: userIds ?? this.userIds,
      start: start,
      end: end,
      price: price,
      status: status ?? this.status,
      splitPayment: splitPayment ?? this.splitPayment,
      payments: payments ?? this.payments,
    );
  }

  Booking markParticipantPaid(String userId) {
    if (!payments.containsKey(userId)) {
      return this;
    }
    final updatedPayments = Map<String, bool>.from(payments)..[userId] = true;
    final allPaid = updatedPayments.isNotEmpty && updatedPayments.values.every((paid) => paid);
    return copyWith(
      payments: updatedPayments,
      status: allPaid ? BookingStatus.confirmed : status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fieldId': fieldId,
        'userIds': userIds,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'price': price,
        'status': status.name,
        'splitPayment': splitPayment,
        'payments': payments,
      };
}
