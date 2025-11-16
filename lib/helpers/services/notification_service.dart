import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
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

    // Pedir permisos normales
    await service.requestNotificationPermissions();
    // Pedir permiso de alarmas exactas
    await service.requestAlarmsPermission();

    print('Notificaciones inicializadas correctamente');
  }

  /// Solicitar permisos normales de notificaciones
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
      print('Permiso notificaciones iOS solicitado');
    }
  }

  /// Solicitar permiso para alarmas exactas
  Future<void> requestAlarmsPermission() async {
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isDenied || status.isRestricted) {
      print("Pidiendo permiso SCHEDULE_EXACT_ALARM...");

      final result = await Permission.scheduleExactAlarm.request();

      print("Resultado permiso alarmas: $result");

      if (!result.isGranted) {
        print("No se otorgó permiso. Abriendo configuración...");
        await openAppSettings();
      }
    } else {
      print("Permiso de alarmas ya otorgado");
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
      await _plugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
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

      print("Notificación programada para $scheduledDate");
    } catch (e) {
      print("Error al programar notificación: $e");
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    print("Notificación tocada: ${response.payload}");
  }

  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse response) {
    _onNotificationResponse(response);
  }
}
