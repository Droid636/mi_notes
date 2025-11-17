import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final fln = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'mi_notes_channel',
      'MiNotes Notificaciones',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    if (message.notification != null) {
      await fln.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        platformDetails,
      );
    }
  } catch (e, stack) {
    debugPrint('Error en background handler: $e\n$stack');
  }
}

class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  //  Canal de recordatorios
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'mi_notes_channel',
        'MiNotes Recordatorios',
        description: 'Canal para recordatorios',
        importance: Importance.high,
      );

  //  CANAL NUEVO PARA EVENTOS
  static const AndroidNotificationChannel eventChannel =
      AndroidNotificationChannel(
        'event_channel',
        'Notificaciones de Eventos',
        description: 'Canal exclusivo para eventos',
        importance: Importance.high,
      );

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initNotifications() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(tz.local.name));

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosInit = DarwinInitializationSettings();
      final settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _fln.initialize(settings);

      final android = _fln
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await android?.createNotificationChannel(_defaultChannel);
      await android?.createNotificationChannel(eventChannel); // ⭐

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((msg) {
        final notification = msg.notification;
        if (notification != null) {
          showInstantNotification(
            id: msg.hashCode,
            title: notification.title ?? 'MiNotes',
            body: notification.body ?? '',
          );
        }
      });

      _initialized = true;
      notifyListeners();

      final token = await _fm.getToken();
      debugPrint('Token FCM del dispositivo: $token');
    } catch (e, stack) {
      debugPrint('Error al inicializar notificaciones: $e\n$stack');
    }
  }

  /// Notificación inmediata
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    await _fln.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // Notificacion Push
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    final scheduledTz = tz.TZDateTime.from(scheduledAt, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload,
    );
  }

  /// Notificaciones de eventos
  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    final scheduledTz = tz.TZDateTime.from(scheduledAt, tz.local);

    final androidDetails = AndroidNotificationDetails(
      eventChannel.id,
      eventChannel.name,
      channelDescription: eventChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _fln.cancel(id);
  }

  Future<void> cancelAll() async {
    await _fln.cancelAll();
  }
}
