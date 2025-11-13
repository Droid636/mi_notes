import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService._internal();

  factory NotificationService() => _instance;

  /// ✅ Inicializa el sistema de notificaciones
  static Future<void> initialize() async {
    final service = NotificationService._instance;
    service._flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await service._flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    // ✅ Solicitar permisos en Android 13+
    await service.requestNotificationPermissions();

    print('✅ Notificaciones inicializadas correctamente');
  }

  /// ✅ Solicita permisos (Android 13+ e iOS)
  Future<void> requestNotificationPermissions() async {
    // Android 13+
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      print('🔔 Permiso de notificaciones en Android: $granted');
    }

    // iOS
    final iosImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('🍏 Permiso de notificaciones solicitado en iOS');
    }
  }

  /// ✅ Mostrar notificación instantánea
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mi_notes_channel',
      'Mi Notes Notifications',
      channelDescription: 'Notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// ✅ Programar notificación futura
  Future<void> scheduleNotification({
    required DateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecond,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mi_notes_scheduled',
            'Scheduled Notifications',
            channelDescription: 'Recordatorios programados',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      print('✅ Notificación programada para: $scheduledDate');
    } catch (e) {
      print('❌ Error al programar notificación: $e');
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    print('📩 Notificación recibida: ${response.payload}');
  }

  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse response) {
    _onNotificationResponse(response);
  }
}
