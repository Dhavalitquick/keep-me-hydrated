import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_data.dart';
import '../models/water_log.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

class WaterNotifier extends StateNotifier<WaterData> {
  final StorageService _storageService;
  final AudioService _audioService;

  WaterNotifier(this._storageService, this._audioService, WaterData initialData)
      : super(initialData);

  Future<void> addWater(int amount, {String? label}) async {
    _checkAndResetDay();
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      label: label,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(logs: [...state.logs, log]);
    _storageService.saveWaterData(state);
    await _audioService.playWaterSound();
  }

  void removeLog(String id) {
    state = state.copyWith(logs: state.logs.where((l) => l.id != id).toList());
    _storageService.saveWaterData(state);
  }

  void setDailyGoal(int goal) {
    state = state.copyWith(dailyGoal: goal);
    _storageService.saveWaterData(state);
  }

  void resetToday() {
    state = state.copyWith(logs: [], date: DateTime.now());
    _storageService.saveWaterData(state);
  }

  void checkAndResetDay() => _checkAndResetDay();

  void _checkAndResetDay() {
    final now = DateTime.now();
    if (state.date.day != now.day || state.date.month != now.month || state.date.year != now.year) {
      // Save current day to history if it has data
      if (state.logs.isNotEmpty) {
        final history = _storageService.getHistory();
        _storageService.saveHistory([...history, state]);
      }
      
      // Reset for new day
      state = WaterData(
        dailyGoal: state.dailyGoal,
        logs: [],
        date: now,
      );
      _storageService.saveWaterData(state);
    }
  }
}

final waterProvider = StateNotifierProvider<WaterNotifier, WaterData>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  final savedData = storage.getWaterData();
  
  final now = DateTime.now();
  final initialData = savedData ?? WaterData(dailyGoal: 2000, logs: [], date: now);
  
  final notifier = WaterNotifier(storage, audio, initialData);
  // Immediate check on initialization
  Future.microtask(() => notifier.checkAndResetDay());
  return notifier;
});

final waterHistoryProvider = Provider<List<WaterData>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getHistory().reversed.toList();
});
