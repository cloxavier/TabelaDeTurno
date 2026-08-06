import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../notification_service.dart';

class NotificacoesConfigScreen extends StatefulWidget {
  const NotificacoesConfigScreen({super.key});

  @override
  State<NotificacoesConfigScreen> createState() => _NotificacoesConfigScreenState();
}

class _NotificacoesConfigScreenState extends State<NotificacoesConfigScreen> with WidgetsBindingObserver {
  bool _isOptimized = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    bool ignored = await NotificationService().isBatteryOptimizationIgnored();
    setState(() {
      _isOptimized = !ignored;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificações e Pontualidade"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.timer_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Garantia de Pontualidade",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              "Para que você nunca perca o horário de suas tarefas e trocas, o Tabela de Turno precisa operar sem as restrições automáticas de economia de energia do Android.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isOptimized ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: _isOptimized ? Colors.orange : Colors.green,
                          size: 30,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOptimized ? "Modo Otimizado Ativo" : "Pontualidade Protegida",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                _isOptimized 
                                  ? "Seus alarmes podem sofrer atrasos pelo sistema." 
                                  : "O sistema Android não irá restringir seus avisos.",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Configuração Manual:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Se preferir economizar bateria máxima, você pode ativar a otimização, mas lembre-se que isso pode silenciar notificações importantes.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings_applications),
              label: const Text("CONFIGURAÇÕES DO SISTEMA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            if (_isOptimized)
              TextButton(
                onPressed: () async {
                  await Permission.ignoreBatteryOptimizations.request();
                  _checkStatus();
                },
                child: const Text("SOLICITAR PROTEÇÃO AGORA"),
              ),
          ],
        ),
      ),
    );
  }
}
