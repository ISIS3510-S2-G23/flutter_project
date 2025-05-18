// // import 'package:flutter/material.dart';
// // import 'notification_model.dart'; // Importa el modelo

// // class Notifications extends StatefulWidget {
// //   const Notifications({super.key});

// //   @override
// //   State<Notifications> createState() => _NotificationsState();
// // }

// // class _NotificationsState extends State<Notifications> {
// //   // Datos de ejemplo - Reemplazar con la lógica de la API más tarde
// //   final List<NotificationModel> _notifications = [
// //     NotificationModel(
// //       id: '1',
// //       title: '¡Nueva característica!',
// //       body: 'Hemos lanzado una nueva función para mejorar tu experiencia.',
// //       timestamp: DateTime.now().subtract(const Duration(hours: 1)),
// //     ),
// //     NotificationModel(
// //       id: '2',
// //       title: 'Recordatorio de Mantenimiento',
// //       body: 'Mantenimiento programado para esta noche a las 2 AM.',
// //       timestamp: DateTime.now().subtract(const Duration(days: 1)),
// //     ),
// //     NotificationModel(
// //       id: '3',
// //       title: 'Noticia de Última Hora',
// //       body: 'Un evento importante acaba de ocurrir. Lee más aquí.',
// //       timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
// //     ),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         backgroundColor: Colors.white,
// //         elevation: 1, // Añade una ligera sombra
// //         title: const Text(
// //           'Notifications',
// //           style: TextStyle(
// //             color: Color(0xFF49447E),
// //             fontWeight: FontWeight.bold,
// //             fontSize: 24,
// //           ),
// //         ),
// //       ),
// //       body: _notifications.isEmpty
// //           ? const Center(
// //               child: Text(
// //                 'No tienes notificaciones.',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   color: Colors.grey,
// //                 ),
// //               ),
// //             )
// //           : ListView.builder(
// //               itemCount: _notifications.length,
// //               itemBuilder: (context, index) {
// //                 final notification = _notifications[index];
// //                 return NotificationListItem(notification: notification); // Crearemos este widget a continuación
// //               },
// //             ),
// //     );
// //   }
// // }

// // // Widget para mostrar un solo elemento de notificación (Paso 3)
// // class NotificationListItem extends StatelessWidget {
// //   final NotificationModel notification;

// //   const NotificationListItem({super.key, required this.notification});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //       elevation: 2.0,
// //       child: ListTile(
// //         leading: const Icon(Icons.notifications_active, color: Color(0xFF49447E)),
// //         title: Text(
// //           notification.title,
// //           style: const TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         subtitle: Text(notification.body),
// //         trailing: Text(
// //           // Formato simple para la hora/fecha
// //           '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
// //           style: const TextStyle(fontSize: 12, color: Colors.grey),
// //         ),
// //         onTap: () {
// //           // Acción al tocar la notificación (ej: navegar a detalles)
// //           print('Notificación tocada: ${notification.title}');
// //         },
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// // Asegúrate que la ruta al modelo sea correcta. Si moviste notification_model.dart a lib/models/
// // entonces la importación debería ser:
// import 'notification_model.dart'; // Ajusta si es necesario
// import 'notification_service.dart'; // Importa el servicio

// class Notifications extends StatefulWidget {
//   const Notifications({super.key});

//   @override
//   State<Notifications> createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   late Future<List<NotificationModel>> _notificationsFuture;
//   final NotificationService _notificationService = NotificationService();

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   void _loadNotifications() {
//     setState(() {
//       _notificationsFuture = _notificationService.fetchNotifications();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             color: Color(0xFF49447E),
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Color(0xFF49447E)),
//             onPressed: _loadNotifications,
//             tooltip: 'Refrescar notificaciones',
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<NotificationModel>>(
//         future: _notificationsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: _loadNotifications,
//                     child: const Text('Intentar de nuevo'),
//                   )
//                 ],
//               ),
//             );
//           } else if (snapshot.hasData && snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No tienes notificaciones.',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey,
//                 ),
//               ),
//             );
//           } else if (snapshot.hasData) {
//             final notifications = snapshot.data!;
//             return ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 return NotificationListItem(notification: notification);
//               },
//             );
//           } else {
//             // Estado inesperado
//             return const Center(child: Text('Algo salió mal.'));
//           }
//         },
//       ),
//     );
//   }
// }

// // Widget para mostrar un solo elemento de notificación
// class NotificationListItem extends StatelessWidget {
//   final NotificationModel notification;

//   const NotificationListItem({super.key, required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       elevation: 2.0,
//       child: ListTile(
//         leading: const Icon(Icons.notifications_active, color: Color(0xFF49447E)),
//         title: Text(
//           notification.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(notification.body),
//         trailing: Text(
//           // Formato simple para la hora/fecha
//           '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//         onTap: () {
//           // Acción al tocar la notificación (ej: navegar a detalles)
//           print('Notificación tocada: ${notification.title}');
//           // Podrías mostrar un SnackBar, navegar a otra pantalla, etc.
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Has tocado "${notification.title}"')),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:async'; // Para Timer
import 'dart:math'; // Para Random
import 'package:flutter/material.dart';
import 'notification_model.dart'; // Ajusta si es necesario
import 'notification_service.dart'; // Importa el servicio

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scheduleNextNotificationFetch();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el timer cuando el widget se destruye
    super.dispose();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.fetchNotifications();
      // Una vez que se completa la carga (exitosa o no), programamos la siguiente
      _notificationsFuture.whenComplete(() {
        _scheduleNextNotificationFetch();
      });
    });
  }

  void _scheduleNextNotificationFetch() {
    _timer?.cancel(); // Cancela cualquier timer anterior

    // Genera un retraso aleatorio entre 10 minutos (600 segundos) y 50 minutos (3000 segundos)
    // (10 * 60) = 600 segundos
    // (50 * 60) = 3000 segundos
    // El rango para nextInt es [0, max - min], luego sumamos min.
    // Entonces, para [600, 3000], max-min = 2400. nextInt(2401) da [0, 2400].
    // Sumamos 600 para obtener [600, 3000].
    final int minDelaySeconds = 1 * 6;
    final int maxDelaySeconds = 5 * 6;
    final int delayInSeconds = minDelaySeconds + _random.nextInt(maxDelaySeconds - minDelaySeconds + 1);
    
    print('Próxima actualización de notificaciones en $delayInSeconds segundos.');

    _timer = Timer(Duration(seconds: delayInSeconds), () {
      print('Timer activado: Recargando notificaciones...');
      _loadNotifications();
      // No es necesario llamar a _scheduleNextNotificationFetch aquí directamente,
      // ya que _loadNotifications() lo hará en su .whenComplete()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF49447E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF49447E)),
            onPressed: () {
                print('Refresco manual activado.');
                _loadNotifications(); // Esto también reprogramará el timer a través de .whenComplete
            },
            tooltip: 'Refrescar notificaciones',
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Asegúrate de que _scheduleNextNotificationFetch se llame incluso en caso de error
            // para que la app intente recuperarse después del intervalo.
            // _loadNotifications ya lo maneja a través de .whenComplete()
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error al cargar: ${snapshot.error}', textAlign: TextAlign.center),
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
            return const Center(child: Text('Algo salió mal.'));
          }
        },
      ),
    );
  }
}

// ... El resto de tu código (NotificationListItem) permanece igual ...
// Widget para mostrar un solo elemento de notificación
class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: ListTile(
        leading: const Icon(Icons.notifications_active, color: Color(0xFF49447E)),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification.body),
        trailing: Text(
          // Formato simple para la hora/fecha
          '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          // Acción al tocar la notificación (ej: navegar a detalles)
          print('Notificación tocada: ${notification.title}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Has tocado "${notification.title}"')),
          );
        },
      ),
    );
  }
}