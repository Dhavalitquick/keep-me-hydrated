import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterNativeTimezoneLatest.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Request notification permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification(int intervalHours) async {
    await _notificationsPlugin.cancelAll();

    for (int i = 1; i <= 10; i++) {
      final scheduledTime =
      tz.TZDateTime.now(tz.local).add(Duration(hours: intervalHours * i));
      await _notificationsPlugin.zonedSchedule(
        i,
        'Drink Water!',
        'Time to stay hydrated. Drink some water.',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_reminder_channel',
            'Hydration Reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
