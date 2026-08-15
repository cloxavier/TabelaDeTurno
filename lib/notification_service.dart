import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.actionId == 'stop_action') {
    NotificationService().cancelNotification(response.id ?? 0);
  } else if (response.actionId == 'snooze_action') {
    tz.initializeTimeZones();
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    NotificationService().handleSnoozeFromResponse(response);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final StreamController<NotificationResponse> _onNotificationStream = StreamController<NotificationResponse>.broadcast();
  Stream<NotificationResponse> get onNotification => _onNotificationStream.stream;

  Future<void> init() async {
    tz.initializeTimeZones();
    
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint("⚠️ Erro de Timezone no emulador/sistema: $e. Aplicando fallback.");
    }
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationStream.add(response);
        if (response.actionId == 'stop_action') {
          cancelNotification(response.id ?? 0);
        } else if (response.actionId == 'snooze_action') {
          _handleSnooze(response);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> requestSpecialPermissions() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestFullScreenIntentPermission();

    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  Future<bool> isBatteryOptimizationIgnored() async => await Permission.ignoreBatteryOptimizations.isGranted;
  Future<bool> hasFullScreenPermission() async => await Permission.systemAlertWindow.isGranted;

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? isAllowed = await androidPlugin.canScheduleExactNotifications();
      if (isAllowed == false) {
        await androidPlugin.requestExactAlarmsPermission();
        return; 
      }
    }

    final String payload = jsonEncode({'id': id, 'title': title, 'body': body});

    final androidDetails = AndroidNotificationDetails(
      'tarefas_alarme_v11', 
      'Escala: Alarmes de Tarefas',
      channelDescription: 'Alarmes críticos de alta prioridade',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      additionalFlags: Int32List.fromList(<int>[4]), 
      category: AndroidNotificationCategory.call,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      styleInformation: BigTextStyleInformation(body, contentTitle: title, summaryText: 'Alarme Ativo'),
      actions: _buildActions(),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZ,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint("❌ Fallback para agendamento inexato: $e");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZ,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  List<AndroidNotificationAction> _buildActions() {
    return <AndroidNotificationAction>[
      const AndroidNotificationAction('stop_action', 'DESLIGAR', cancelNotification: true),
      const AndroidNotificationAction('snooze_action', 'ADIAR 5 MIN'),
    ];
  }

  Future<void> cancelNotification(int id) async => await flutterLocalNotificationsPlugin.cancel(id: id);

  void _handleSnooze(NotificationResponse response) => handleSnoozeFromResponse(response);

  void handleSnoozeFromResponse(NotificationResponse response) {
    final int id = response.id ?? 0;
    cancelNotification(id);
    String title = 'Tarefa';
    String body = 'Lembrete';
    try {
      final data = jsonDecode(response.payload ?? '{}');
      title = data['title'] ?? 'Tarefa';
      body = data['body'] ?? 'Lembrete';
    } catch (e) {
      debugPrint('Erro no payload do snooze: $e');
    }
    final DateTime snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    scheduleNotification(id, title, body, snoozeTime);
  }
}
