class WaterLog {
  final String id;
  final int amount;
  final String? label;
  final DateTime timestamp;

  WaterLog({
    required this.id,
    required this.amount,
    this.label,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'label': label,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String,
      amount: json['amount'] as int,
      label: json['label'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
