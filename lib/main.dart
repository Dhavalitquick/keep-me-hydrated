import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/water_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.init();

    final settings = ref.read(settingsProvider);
    if (settings.notificationsEnabled) {
      notificationService.scheduleNotification(settings.reminderIntervalHours);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Keep Me Hydrated',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
