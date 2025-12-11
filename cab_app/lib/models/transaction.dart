class Transaction {
  final String id;
  final String type; // 'trip_earning', 'trip_fee', 'topup'
  final double amount;
  final DateTime timestamp;
  final String? tripId;
  final String? description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.tripId,
    this.description,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      tripId: map['tripId'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'tripId': tripId,
      'description': description,
    };
  }
}