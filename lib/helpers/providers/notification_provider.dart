import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Maneja mensajes en segundo plano
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Proveedor de notificaciones (locales y Firebase)
class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'mi_notes_channel',
        'MiNotes Notificaciones',
        description: 'Canal principal de notificaciones de MiNotes',
        importance: Importance.defaultImportance,
      );

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Inicializa las notificaciones
  Future<void> initNotifications() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(tz.local.name));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(settings);

    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Escucha mensajes cuando la app está abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
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
    print('Token FCM del dispositivo: $token');
  }

  /// Solicita permisos (Android 13+ / iOS)
  Future<bool> requestPermissions() async {
    final settings = await _fm.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Muestra una notificación local inmediata
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

    final platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _fln.show(id, title, body, platform, payload: payload);
  }

  /// Programa una notificación para una hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) {
      throw Exception('La fecha programada está en el pasado');
    }

    final tz.TZDateTime scheduledTz = tz.TZDateTime.from(scheduledAt, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  /// Cancela una notificación por ID
  Future<void> cancelNotification(int id) async {
    await _fln.cancel(id);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAll() async {
    await _fln.cancelAll();
  }

  /// Obtiene el token FCM
  Future<String?> getFcmToken() => _fm.getToken();

  /// Suscripción a un tema (opcional)
  Future<void> subscribeToTopic(String topic) => _fm.subscribeToTopic(topic);

  /// Cancelar suscripción a un tema (opcional)
  Future<void> unsubscribeFromTopic(String topic) =>
      _fm.unsubscribeFromTopic(topic);
}
