import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  // Handler para cliques em botões enquanto o app está em background
  if (response.actionId == 'stop_action') {
    NotificationService().cancelNotification(response.id ?? 0);
  } else if (response.actionId == 'snooze_action') {
    // IMPORTANTE: Inicializa Timezone no isolado de background antes de reagendar
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
  
  // Stream para avisar a interface que um alarme disparou ou foi clicado
  final StreamController<NotificationResponse> _onNotificationStream = StreamController<NotificationResponse>.broadcast();
  Stream<NotificationResponse> get onNotification => _onNotificationStream.stream;

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Detecta o fuso horário local do dispositivo
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint("🌍 Fuso Horário Detectado: $timeZoneName");
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Envia para o stream para que a interface (Dialog) possa reagir
        _onNotificationStream.add(response);

        // Quando o usuário clica em um botão da notificação ou na própria notificação
        if (response.actionId == 'stop_action') {
          cancelNotification(response.id ?? 0);
        } else if (response.actionId == 'snooze_action') {
          _handleSnooze(response);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // Solicita permissão de Notificação (janelinha popup)
    await androidPlugin?.requestNotificationsPermission();
        
    // Solicita permissão de Alarme Exato (leva para a tela de configurações)
    await androidPlugin?.requestExactAlarmsPermission();

    // No Android 14+, a permissão de Full Screen Intent é obrigatória via código
    // para que a tela de alarme apareça sobre o bloqueio em modo Release.
    await androidPlugin?.requestFullScreenIntentPermission();

    // Solicita exclusão de otimização de bateria (Crucial para Samsung S24)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // Solicita permissão para aparecer sobre outros apps (Para abrir a tela de alarme direto)
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  /// Verifica se o aplicativo está na lista de exceções de otimização de bateria
  Future<bool> isBatteryOptimizationIgnored() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  /// Verifica se a permissão de sobreposição (vital para o alarme no Android 15) está ativa.
  Future<bool> hasFullScreenPermission() async {
    return await Permission.systemAlertWindow.isGranted;
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
    final tz.TZDateTime nowTZ = tz.TZDateTime.now(tz.local);

    // Validação básica: não agenda no passado (usando fuso horário local)
    if (scheduledTZ.isBefore(nowTZ)) {
      debugPrint("❌ Erro: Tentativa de agendar alarme no passado.");
      return;
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // No Android 14+, precisamos verificar se a permissão de alarme exato ainda está ativa.
    if (androidPlugin != null) {
      final bool? isAllowed = await androidPlugin.canScheduleExactNotifications();
      if (isAllowed == false) {
        debugPrint("⚠️ Permissão de alarme exato revogada. Solicitando ao usuário...");
        await androidPlugin.requestExactAlarmsPermission();
        return; 
      }
    }

    debugPrint("🔔 Agendando alarme ($id) para: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(scheduledTZ)}");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tarefas_alarme_v4', // Novo canal para garantir reset de configurações no Android
            'Alarmes de Tarefas',
            channelDescription: 'Canal para alarmes de tarefas sobre o bloqueio',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            ongoing: true,
            autoCancel: false,
            visibility: NotificationVisibility.public,
            additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: 'Alarme de Tarefa',
            ),
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'stop_action',
                'DESLIGAR',
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'snooze_action',
                'ADIAR 5 MIN',
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'id': id,
          'title': title,
          'body': body,
        }),
      );
    } catch (e) {
      debugPrint("❌ ERRO GRAVE no agendamento: $e");
      // Se o erro for de permissão de alarme exato, tentamos agendar de forma aproximada como fallback
      if (e.toString().contains("exact_alarms")) {
        debugPrint("🔄 Tentando agendamento aproximado (Fallback)...");
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, scheduledTZ,
          const NotificationDetails(android: AndroidNotificationDetails('tarefas_alarme_v3', 'Alarmes')),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow; 
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  void _handleSnooze(NotificationResponse response) {
    handleSnoozeFromResponse(response);
  }

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
      debugPrint('Erro ao interpretar payload do alarme: $e');
    }

    // Reagenda para daqui a 5 minutos
    final DateTime snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    scheduleNotification(id, title, body, snoozeTime);
  }
}
