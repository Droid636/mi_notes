import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin _plugin;

  NotificationService._internal();

  factory NotificationService() => _instance;

  /// Inicializar sistema de notificaciones
  static Future<void> initialize() async {
    final service = NotificationService._instance;
    service._plugin = FlutterLocalNotificationsPlugin();

    // 🔥 INICIALIZAR TIMEZONE (LO QUE FALTABA)
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidInit = AndroidInitializationSettings('app_icon');

    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await service._plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    await service.requestNotificationPermissions();
    await service.requestAlarmsPermission();

    print('📌 Notificaciones inicializadas correctamente con timezone');
  }

  /// Solicitar permisos normales
  Future<void> requestNotificationPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      print('Permiso notificaciones Android: $granted');
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Solicitar permiso de alarmas exactas
  Future<void> requestAlarmsPermission() async {
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isDenied || status.isRestricted) {
      final result = await Permission.scheduleExactAlarm.request();

      if (!result.isGranted) {
        await openAppSettings();
      }
    }
  }

  /// Notificación instantánea
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

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Programar notificación futura
  Future<void> scheduleNotification({
    required DateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mi_notes_scheduled',
            'Scheduled Notifications',
            channelDescription: 'Recordatorios programados',
            importance: Importance.max,
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

      print("⏰ Notificación programada para: $tzDate");
    } catch (e) {
      print("❌ Error programando notificación: $e");
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    print("📨 Notificación tocada: ${response.payload}");
  }

  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse response) {
    _onNotificationResponse(response);
  }
}
