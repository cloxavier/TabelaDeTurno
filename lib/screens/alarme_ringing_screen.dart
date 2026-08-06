import 'package:flutter/material.dart';
import '../notification_service.dart';

class AlarmeRingingScreen extends StatelessWidget {
  final String title;
  final String description;
  final int notificationId;

  const AlarmeRingingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fundo escuro para foco
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.alarm_on, color: Colors.orange, size: 100),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                description,
                style: const TextStyle(color: Colors.grey, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _actionButton(
                    label: "DESLIGAR ALARME",
                    color: Colors.orange,
                    onPressed: () {
                      NotificationService().cancelNotification(notificationId);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 15),
                  _actionButton(
                    label: "ADIAR 5 MINUTOS",
                    color: Colors.white.withValues(alpha: 0.1),
                    textColor: Colors.white,
                    onPressed: () {
                      // Reagenda usando a lógica do serviço
                      NotificationService().cancelNotification(notificationId);
                      
                      // Reagenda para daqui a 5 minutos
                      final DateTime snoozeTime = DateTime.now().add(const Duration(minutes: 5));
                      NotificationService().scheduleNotification(notificationId, title, description, snoozeTime);
                      
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required String label, required Color color, required VoidCallback onPressed, Color textColor = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
