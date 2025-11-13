import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Maneja mensajes en segundo plano de forma segura
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

  /// Inicializa las notificaciones de manera segura
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
      debugPrint('Token FCM del dispositivo: $token');
    } catch (e, stack) {
      debugPrint('Error al inicializar notificaciones: $e\n$stack');
    }
  }

  /// Solicita permisos (Android 13+ / iOS)
  Future<bool> requestPermissions() async {
    try {
      final settings = await _fm.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error solicitando permisos: $e');
      return false;
    }
  }

  /// Muestra una notificación local inmediata
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('Error mostrando notificación: $e');
    }
  }

  /// Programa una notificación para una hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    try {
      if (scheduledAt.isBefore(DateTime.now())) {
        throw Exception('La fecha programada está en el pasado');
      }

      final tz.TZDateTime scheduledTz = tz.TZDateTime.from(
        scheduledAt,
        tz.local,
      );

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
    } catch (e, stack) {
      debugPrint('Error programando notificación: $e\n$stack');
    }
  }

  /// Cancela una notificación por ID
  Future<void> cancelNotification(int id) async {
    try {
      await _fln.cancel(id);
    } catch (e) {
      debugPrint('Error cancelando notificación $id: $e');
    }
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAll() async {
    try {
      await _fln.cancelAll();
    } catch (e) {
      debugPrint('Error cancelando todas las notificaciones: $e');
    }
  }

  /// Obtiene el token FCM
  Future<String?> getFcmToken() async {
    try {
      return await _fm.getToken();
    } catch (e) {
      debugPrint('Error obteniendo token FCM: $e');
      return null;
    }
  }

  /// Suscripción a un tema (opcional)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fm.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error suscribiéndose a topic $topic: $e');
    }
  }

  /// Cancelar suscripción a un tema (opcional)
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fm.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error cancelando suscripción a topic $topic: $e');
    }
  }
}
