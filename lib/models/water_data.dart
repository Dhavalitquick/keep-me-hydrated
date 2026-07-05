import 'water_log.dart';

class WaterData {
  final int dailyGoal;
  final List<WaterLog> logs;
  final DateTime date;

  WaterData({
    required this.dailyGoal,
    required this.logs,
    required this.date,
  });

  int get consumedAmount => logs.fold(0, (sum, item) => sum + item.amount);

  WaterData copyWith({
    int? dailyGoal,
    List<WaterLog>? logs,
    DateTime? date,
  }) {
    return WaterData(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      logs: logs ?? this.logs,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'logs': logs.map((l) => l.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory WaterData.fromJson(Map<String, dynamic> json) {
    return WaterData(
      dailyGoal: json['dailyGoal'] as int? ?? 2000,
      logs: (json['logs'] as List?)?.map((l) => WaterLog.fromJson(l)).toList() ?? [],
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }
}
