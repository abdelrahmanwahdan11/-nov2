import 'enums.dart';

class WalletTx {
  const WalletTx({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.note,
  });

  factory WalletTx.fromJson(Map<String, dynamic> json) {
    return WalletTx(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: walletTypeFromString(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  final String id;
  final String userId;
  final double amount;
  final WalletType type;
  final DateTime createdAt;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };
}
