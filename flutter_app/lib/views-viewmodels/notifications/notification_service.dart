import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_model.dart'; // Adjust path if your model is elsewhere
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For API key
import 'package:uuid/uuid.dart'; // For generating unique IDs

class NotificationService {
  // Your OpenAI API endpoint for chat completions
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // IMPORTANT: Load your API key securely, e.g., using flutter_dotenv
  // Add OPENAI_API_KEY=your_actual_key to your .env file
  final String _apiKey = dotenv.env['KEY_ECOSPHERE'] ?? 'YOUR_OPENAI_API_KEY_FALLBACK';

  final Uuid _uuid = Uuid();

  Future<List<NotificationModel>> fetchNotifications() async {
    if (_apiKey == 'YOUR_OPENAI_API_KEY_FALLBACK' || _apiKey.isEmpty) {
      print('Error: OpenAI API Key not found. Please set it in your .env file.');
      // Return empty list or throw specific error to show in UI
      // For now, returning mock data to avoid app crash if key is missing
      return _getMockNotificationsOnError();
    }

    // This is where you tell ChatGPT what kind of notifications to generate.
    // You want it to return a JSON string that can be parsed into a list of notifications.
    final String prompt = """
    Generate 1 diverse, concise, and engaging news updates suitable for app notifications.
    Each update should be fictional and general interest (e.g., recycling, transport, positive news).
    Return the updates as a valid JSON array where each object has two string keys: "title" and "body".
    The "title" should be a short, catchy headline (max 10 words).
    The "body" should be a one or two-sentence summary of the news (max 30 words).

    Example of the desired JSON output format:
    [
      {"title": "New Planet Discovery", "body": "Astronomers have discovered a new Earth-like planet in a nearby galaxy, sparking hopes for future exploration."},
      {"title": "Tech Breakthrough in AI", "body": "A new AI model can now generate realistic images from complex text descriptions with unprecedented accuracy."},
      {"title": "Global Art Initiative", "body": "Artists worldwide are collaborating on a digital art project to promote peace and understanding across cultures."}
    ]
    """;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo', // Or 'gpt-4o', 'gpt-4-turbo'
          'messages': [
            // Optional: A system message can help set the context for the AI
            // {"role": "system", "content": "You are an assistant that generates news notifications in JSON format."},
            {"role": "user", "content": prompt}
          ],
          'temperature': 0.7, // Adjust for creativity vs. determinism
          'max_tokens': 300,  // Adjust based on expected length of 3 notifications
          // For newer models, you can enforce JSON output:
          // 'response_format': { 'type': 'json_object' } // Ensure your model supports this
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes)); // Use utf8.decode for proper character handling
        
        if (responseBody['choices'] != null && responseBody['choices'].isNotEmpty) {
          String content = responseBody['choices'][0]['message']['content'];
          
          // The content might be a stringified JSON array. We need to parse it.
          // Sometimes the API might wrap the JSON in backticks or add explanations.
          // Basic cleanup:
          content = content.trim();
          if (content.startsWith('```json')) {
            content = content.substring(7);
          }
          if (content.endsWith('```')) {
            content = content.substring(0, content.length - 3);
          }
          content = content.trim();

          try {
            final List<dynamic> jsonData = json.decode(content);
            List<NotificationModel> notifications = jsonData.map((item) {
              return NotificationModel(
                id: _uuid.v4(), // Generate a unique ID
                title: item['title'] as String? ?? 'No Title',
                body: item['body'] as String? ?? 'No Body',
                timestamp: DateTime.now(), // Set current time for new notifications
              );
            }).toList();
            return notifications;
          } catch (e) {
            print('Error parsing JSON content from ChatGPT: $e');
            print('Received content: $content');
            throw Exception('Failed to parse notifications from API response.');
          }
        } else {
          print('No choices found in API response: ${response.body}');
          throw Exception('No content returned from API.');
        }
      } else {
        print('API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load notifications from server (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Fallback or rethrow
      // return _getMockNotificationsOnError(); // Optionally return mock data on error
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Helper for mock data if API key is missing or an error occurs
  List<NotificationModel> _getMockNotificationsOnError() {
    print("Falling back to mock notifications due to an error or missing API key.");
    return [
      NotificationModel(
        id: 'mock-1',
        title: 'API Key Missing or Error',
        body: 'Please check your OpenAI API key or network connection. Displaying mock data.',
        timestamp: DateTime.now(),
      ),
      NotificationModel(
        id: 'mock-2',
        title: 'Local Weather Update',
        body: 'Expect sunny skies today with a high of 25°C. Perfect day for outdoor activities!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}