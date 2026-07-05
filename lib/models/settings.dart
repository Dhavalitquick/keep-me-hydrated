class AppSettings {
  final int reminderIntervalHours;
  final bool notificationsEnabled;
  final bool isDarkMode;

  AppSettings({
    required this.reminderIntervalHours,
    required this.notificationsEnabled,
    required this.isDarkMode,
  });

  AppSettings copyWith({
    int? reminderIntervalHours,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) {
    return AppSettings(
      reminderIntervalHours: reminderIntervalHours ?? this.reminderIntervalHours,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
