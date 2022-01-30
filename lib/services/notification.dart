import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: AndroidNotificationDetails(
    'ir.iamnonroot.pomodoro', //Required for Android 8.0 or after
    'Pomodoro', //Required for Android 8.0 or after
    'Pomodoro push notification', //Required for Android 8.0 or after
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'triker',
    channelShowBadge: true,
  ),
);

Future<void> initialize() async {
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    }
  });
}

Future<void> show({
  required int id,
  required String title,
  required String subtitle,
  int minute = 1,
}) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    subtitle,
    tz.TZDateTime.now(tz.local).add(
      Duration(minutes: minute),
    ),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> delete() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.deleteNotificationChannel('ir.iamnonroot.pomodoro');
}
