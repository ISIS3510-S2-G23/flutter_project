import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // Declarar _notificationsFuture como nullable o usar late con inicialización definitiva
  Future<List<NotificationModel>>? _notificationsFuture;
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;
  final Random _random = Random();
  bool _isServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    // Asegurarse de que el servicio se inicialice solo una vez
    if (!_isServiceInitialized) {
      await _notificationService.initializeService();
      _isServiceInitialized = true;
    }
    _loadNotifications(); // Carga inicial
    // _scheduleNextNotificationFetch(); // Programar la siguiente después de la carga inicial
    _notificationService.startPeriodicNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadNotifications() {
    if (!_isServiceInitialized) {
      print("Service not initialized, skipping load.");
      // Podrías querer mostrar un estado de "inicializando" o reintentar _initializeAndLoad
      return;
    }
    setState(() {
      _notificationsFuture = _notificationService.fetchNotifications();
      // Reprogramar después de que la carga (exitosa o no) se complete
      _notificationsFuture?.whenComplete(() {
        _scheduleNextNotificationFetch();
      });
    });
  }

  void _scheduleNextNotificationFetch() {
    _timer?.cancel();
    final int minDelaySeconds = 10 * 60; // 10 minutos
    final int maxDelaySeconds = 50 * 60; // 50 minutos
    final int delayInSeconds = minDelaySeconds +
        _random.nextInt(maxDelaySeconds - minDelaySeconds + 1);

    print(
        'Próxima actualización de notificaciones en $delayInSeconds segundos.');

    _timer = Timer(Duration(seconds: delayInSeconds), () {
      print('Timer activado: Recargando notificaciones...');
      _loadNotifications();
    });
  }

  // ... (El resto del widget _NotificationsState y NotificationListItem permanece igual)
  // Asegúrate de que el FutureBuilder maneje _notificationsFuture siendo null inicialmente
  // o antes de que _loadNotifications se llame la primera vez.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (código del AppBar)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF49447E)),
            onPressed: () {
              print('Refresco manual activado.');
              _loadNotifications();
            },
            tooltip: 'Refrescar notificaciones',
          ),
        ],
      ),
      body: _notificationsFuture ==
              null // Manejar el caso donde _notificationsFuture aún no se ha establecido
          ? const Center(
              child: Text(
                  "Initializing notifications...")) // O un CircularProgressIndicator
          : FutureBuilder<List<NotificationModel>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                // ... (lógica existente del FutureBuilder)
// ... (resto del código del widget build y NotificationListItem)
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isServiceInitialized) {
                  return const Center(
                      child: Text(
                          "Initializing service...")); // Estado de inicialización del servicio
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error al cargar: ${snapshot.error}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Intentar de nuevo'),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes notificaciones.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final notifications = snapshot.data!;
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationListItem(notification: notification);
                    },
                  );
                } else {
                  // Estado inicial o si _notificationsFuture es null después de la inicialización
                  return const Center(
                      child: Text('Cargando notificaciones...'));
                }
              },
            ),
    );
  }
}

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: ListTile(
        leading:
            const Icon(Icons.notifications_active, color: Color(0xFF49447E)),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification.body),
        trailing: Text(
          '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          print('Notificación tocada: ${notification.title}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Has tocado "${notification.title}"')),
          );
        },
      ),
    );
  }
}
