import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';
import 'water_provider.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storageService;
  final NotificationService _notificationService;

  SettingsNotifier(this._storageService, this._notificationService, AppSettings initialData)
      : super(initialData);

  void setReminderInterval(int hours) {
    state = state.copyWith(reminderIntervalHours: hours);
    _save();
    if (state.notificationsEnabled) {
      _notificationService.scheduleNotification(hours);
    }
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _save();
    if (enabled) {
      _notificationService.scheduleNotification(state.reminderIntervalHours);
    } else {
      _notificationService.cancelNotifications();
    }
  }

  void toggleDarkMode(bool isDarkMode) {
    state = state.copyWith(isDarkMode: isDarkMode);
    _save();
  }

  void _save() {
    _storageService.saveSettings(
      state.reminderIntervalHours,
      state.notificationsEnabled,
      state.isDarkMode,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final savedSettings = storage.getSettings();

  final initialData = AppSettings(
    reminderIntervalHours: savedSettings?['interval'] ?? 2,
    notificationsEnabled: savedSettings?['enabled'] ?? true,
    isDarkMode: savedSettings?['darkMode'] ?? false,
  );

  return SettingsNotifier(storage, notificationService, initialData);
});
