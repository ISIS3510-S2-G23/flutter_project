// class NotificationModel {
//   final String id;
//   final String title;
//   final String body;
//   final DateTime timestamp;

//   NotificationModel({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.timestamp,
//   });
// }

// ...existing code...
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  // Método para convertir una instancia de NotificationModel a un Map (JSON)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(), // Guardar como ISO 8601 string
      };

  // Factory constructor para crear una instancia de NotificationModel desde un Map (JSON)
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String), // Parsear desde ISO 8601 string
      );
}
