// lib/helpers/providers/notification_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Handler para mensajes en background (debe ser top-level).
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Si quieres, procesa datos aquí (registro, analytics, etc.)
  // Por ejemplo: print('Background message: ${message.messageId}');
}

/// NotificationProvider
/// - initNotifications()  -> inicializa local + firebase messaging
/// - requestPermissions() -> pide permisos (iOS / Android 13+)
/// - showInstantNotification(...) -> muestra notificación inmediata
/// - scheduleNotification(...) -> programa notificación local (usa timezone)
/// - cancelNotification(id) / cancelAll()
class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  // Opciones de canal (Android)
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'mi_notes_channel', // id
        'MiNotes Notificaciones', // title
        description: 'Canal principal de notificaciones de MiNotes',
        importance: Importance.defaultImportance,
      );

  bool _initialized = false;
  bool get initialized => _initialized;

  NotificationProvider();

  /// Inicializa flutter_local_notifications y Firebase Messaging.
  /// Llama a requestPermissions() si lo deseas después.
  Future<void> initNotifications() async {
    if (_initialized) return;

    // Inicializar timezone (necesario para zoned scheduling)
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(tz.local.name));
    } catch (e) {
      // Si falla timezone, zoned schedule puede fallar; manejar según necesidad
      // print('Timezone init error: $e');
    }

    // Inicialización de flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification puede añadirse si se requiere
    );

    final settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Manejar acción de tap en notificación local
        // response.payload contiene datos si los enviaste
      },
    );

    // Crear canal Android
    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    // Registrar handler background de Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Listeners para mensajes en primer plano / app abierta desde notificación
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      // Mostrar local notification si quieres
      final notification = msg.notification;
      if (notification != null) {
        showInstantNotification(
          id: msg.hashCode,
          title: notification.title ?? 'MiNotes',
          body: notification.body ?? '',
          payload: msg.data.isNotEmpty ? msg.data.toString() : null,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      // Manejar navegación cuando el usuario abre la app desde la notificación
      // Puedes exponer un stream o callback si necesitas navegación global
    });

    _initialized = true;
    notifyListeners();
  }

  /// Solicita permisos (iOS / Android 13+). Devuelve true si están permitidos.
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _fm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } else {
      // Android: solo en Android 13+ hay permisos runtime para notificaciones.
      final settings = await _fm.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
  }

  /// Muestra una notificación local inmediata.
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
      ticker: 'ticker',
    );

    final iosDetails = DarwinNotificationDetails();

    final platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _fln.show(id, title, body, platform, payload: payload);
  }

  /// Programa una notificación local para una fecha/hora (usa timezone).
  /// id debe ser único (int).
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    try {
      print('📋 Intentando programar notificación:');
      print('   - ID: $id');
      print('   - Título: $title');
      print('   - Fecha programada: $scheduledAt');
      print('   - Ahora: ${DateTime.now()}');

      // Verificar que la hora esté en el futuro
      if (scheduledAt.isBefore(DateTime.now())) {
        print('⚠️ ADVERTENCIA: La fecha está en el pasado.');
        throw Exception('La fecha programada está en el pasado');
      }

      // Convertir DateTime a tz.TZDateTime usando timezone local
      final tz.TZDateTime scheduledTz = tz.TZDateTime.from(
        scheduledAt,
        tz.local,
      );

      print('   - Convertido a TZ: $scheduledTz');

      final androidDetails = AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // zonedSchedule requiere timezone package inicializada
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

      print('✅ Notificación programada exitosamente para: $scheduledTz');
    } catch (e) {
      print('❌ Error al programar notificación: $e');
      rethrow;
    }
  }

  /// Cancela una notificación por id
  Future<void> cancelNotification(int id) async {
    await _fln.cancel(id);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAll() async {
    await _fln.cancelAll();
  }

  /// Obtiene token FCM (por si quieres subirlo al usuario en Firestore)
  Future<String?> getFcmToken() => _fm.getToken();

  /// Opcional: suscribirse a un topic
  Future<void> subscribeToTopic(String topic) => _fm.subscribeToTopic(topic);

  /// Opcional: desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) =>
      _fm.unsubscribeFromTopic(topic);
}
