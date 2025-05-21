import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey =
      dotenv.env['KEY_ECOSPHERE'] ?? 'YOUR_OPENAI_API_KEY_FALLBACK';
  final Uuid _uuid = Uuid();

  List<NotificationModel> _notificationsCache = [];
  static const String _storageFileName = 'notifications_cache.json';
  static const int _maxCacheSize = 100;
  bool _isInitialized = false;

  // Método para inicializar el servicio (cargar desde archivo)
  Future<void> initializeService() async {
    if (_isInitialized) return;
    await _loadNotificationsFromFile();
    _isInitialized = true;
    print(
        "NotificationService initialized. Cache size: ${_notificationsCache.length}");
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$_storageFileName');
  }

  Future<void> _loadNotificationsFromFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(contents);
          _notificationsCache = jsonData
              .map((item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          // Asegurar orden y límite
          _notificationsCache.sort((a, b) =>
              b.timestamp.compareTo(a.timestamp)); // Más nuevas primero
          if (_notificationsCache.length > _maxCacheSize) {
            _notificationsCache = _notificationsCache.sublist(0, _maxCacheSize);
          }
        }
        print(
            "Notifications loaded from file. Count: ${_notificationsCache.length}");
      } else {
        print(
            "Notification cache file does not exist. Starting with empty cache.");
      }
    } catch (e) {
      print('Error loading notifications from file: $e');
      _notificationsCache = []; // Empezar con caché vacía en caso de error
    }
  }

  Future<void> _saveNotificationsToFile() async {
    try {
      final file = await _localFile;
      // Convertir la lista de NotificationModel a una lista de Mapas (JSON)
      final List<Map<String, dynamic>> jsonData = _notificationsCache
          .map((notification) => notification.toJson())
          .toList();
      await file.writeAsString(json.encode(jsonData));
      print(
          "Notifications saved to file. Count: ${_notificationsCache.length}");
    } catch (e) {
      print('Error saving notifications to file: $e');
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    if (!_isInitialized) {
      // Esto no debería pasar si initializeService se llama correctamente
      print(
          "Warning: fetchNotifications called before service initialization.");
      await initializeService();
    }

    if (_apiKey == 'YOUR_OPENAI_API_KEY_FALLBACK' || _apiKey.isEmpty) {
      print('Error: OpenAI API Key not found. Using cached/mock data.');
      if (_notificationsCache.isNotEmpty) {
        return List.from(_notificationsCache); // Devuelve una copia de la caché
      }
      return _getMockNotificationsOnError(); // O mock si la caché está vacía
    }

    final String prompt = """
    Generate 1 diverse, concise, and engaging news updates suitable for app notifications.
    Each update should be fictional and general interest (e.g., recycling, transport, positive news).
    Return the updates as a valid JSON array where each object has two string keys: "title" and "body".
    The "title" should be a short, catchy headline (max 10 words).
    The "body" should be a one or two-sentence summary of the news (max 30 words).

    Example of the desired JSON output format:
    [
      {"title": "New Urban Mobility Solution", "body": "Eco-friendly electric scooters are now available city-wide, aiming to reduce traffic congestion and pollution."}
    ]
    """; // Ajustado para pedir 1 y con ejemplo de 1

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {"role": "user", "content": prompt}
          ],
          'temperature': 0.8, // Un poco más de creatividad
          'max_tokens': 150, // Ajustado para 1-2 notificaciones
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody['choices'] != null &&
            responseBody['choices'].isNotEmpty) {
          String content = responseBody['choices'][0]['message']['content'];
          content = content.trim();
          if (content.startsWith('```json')) content = content.substring(7);
          if (content.endsWith('```'))
            content = content.substring(0, content.length - 3);
          content = content.trim();

          final List<dynamic> newJsonData = json.decode(content);
          List<NotificationModel> newApiNotifications = newJsonData.map((item) {
            return NotificationModel(
              id: _uuid.v4(),
              title: item['title'] as String? ?? 'No Title',
              body: item['body'] as String? ?? 'No Body',
              timestamp: DateTime.now(),
            );
          }).toList();

          // Agregar nuevas notificaciones al inicio de la caché
          _notificationsCache.insertAll(0, newApiNotifications);
          // Ordenar por fecha (más nuevas primero)
          _notificationsCache
              .sort((a, b) => b.timestamp.compareTo(a.timestamp));
          // Limitar al tamaño máximo
          if (_notificationsCache.length > _maxCacheSize) {
            _notificationsCache = _notificationsCache.sublist(0, _maxCacheSize);
          }
          await _saveNotificationsToFile(); // Guardar la caché actualizada
          print(
              "Fetched new notifications. Cache size: ${_notificationsCache.length}");
          return List.from(_notificationsCache); // Devuelve una copia
        } else {
          throw Exception('No content returned from API.');
        }
      } else {
        print('API Error: ${response.statusCode}, Body: ${response.body}');
        // Si la API falla, pero tenemos caché, devolvemos la caché
        if (_notificationsCache.isNotEmpty) {
          print("API error, returning cached notifications.");
          return List.from(_notificationsCache);
        }
        throw Exception(
            'Failed to load notifications from server (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching or processing notifications: $e');
      // Si cualquier cosa falla, pero tenemos caché, devolvemos la caché
      if (_notificationsCache.isNotEmpty) {
        print("General error, returning cached notifications.");
        return List.from(_notificationsCache);
      }
      // Si no hay caché y hay error, devolvemos mock o lanzamos la excepción
      // return _getMockNotificationsOnError();
      throw Exception('Failed to fetch notifications: $e. No cache available.');
    }
  }

  List<NotificationModel> _getMockNotificationsOnError() {
    print(
        "Falling back to mock notifications due to an error or missing API key/cache.");
    return [
      NotificationModel(
        id: 'mock-1',
        title: 'Service Unavailable',
        body: 'Could not fetch new updates. Displaying placeholder content.',
        timestamp: DateTime.now(),
      ),
      NotificationModel(
        id: 'mock-2',
        title: 'Tip of the Day',
        body:
            'Remember to stay hydrated and take short breaks if working long hours!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// Inicia el ciclo de notificaciones periódicas cada 5 minutos.
  /// Llama a esto una sola vez después de inicializar el servicio.
  Future<void> startPeriodicNotifications() async {
    // Genera la primera notificación inmediatamente
    await fetchNotifications();

    // Luego, cada 5 minutos
    while (true) {
      await Future.delayed(const Duration(minutes: 5));
      await fetchNotifications();
    }
  }
}
