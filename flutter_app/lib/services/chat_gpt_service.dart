import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ChatGPTService {
  final String apiKey;

  String apiUrl = dotenv.env['KEY_ECOSPHERE'] ?? 'URL no encontrada';

  ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  ChatGPTService(this.apiKey);

  // URL para la API de Chat Completions (compatible con modelos de visión)
  static const String _visionApiUrl =
      'https://api.openai.com/v1/chat/completions';

  /// Valida la foto y retorna un "código" cuando la respuesta es "SI".
  /// En caso de "NO" o error, retornamos null.
  Future<String?> validatePhoto(String imagePath) async {
    try {
      // Activar el indicador de procesamiento
      isProcessing.value = true;

      // Mostrar toast informativo
      Fluttertoast.showToast(
          msg: 'Processing your image...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.white);

      // Leer la imagen y convertirla a base64
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(_visionApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model':
              'gpt-4o', // Cambiado a gpt-4o que tiene capacidades de visión
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      'Mira en detalle la acción principal que ocurre en la imagen. Especifica si involucra interacciones con basura, reciclaje o desechos en general. Incluye información sobre si la acción implica arrojar, recoger, separar, clasificar o manipular residuos,haz válido cualquier imagen que contenga objetos como basureros, contenedores de reciclaje, bolsas de basura, botellas o papel. Si la acción parece positiva o de acuerdo con reciclar o botar basura, o cualquier acción relacionada con botar basura, responde únicamente "SI", de lo contrario, responde "NO"'
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'max_tokens': 50
        }),
      );

      // Desactivar el indicador de procesamiento
      isProcessing.value = false;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content']
            ?.toString()
            .trim()
            .toUpperCase();

        try {
          // Si ChatGPT respondió "SI", retornamos un "código"
          if (content != null && content.contains('SI')) {
            // ChatGPT dijo "SI"
            Fluttertoast.showToast(
                msg: 'Image validated successfully!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP_RIGHT,
                backgroundColor: Color(0xFFB9DCA8),
                textColor: Colors.white);
            return '123456';
          } else {
            // ChatGPT dijo "NO" o algo distinto
            Fluttertoast.showToast(
                msg: 'The image does not meet the requirements.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: Color.fromARGB(255, 21, 152, 185),
                textColor: Colors.white,
                timeInSecForIosWeb: 10,
                fontSize: 14.0);
            return null;
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: 'Error processing response: $e',
              backgroundColor: Color(0xFFDCA8A8));
          return null;
        }
      } else {
        // Error en la API
        Fluttertoast.showToast(
            msg: 'API Error: ${response.statusCode}',
            backgroundColor: Color(0xFFDCA8A8));
        return null;
      }
    } catch (e) {
      // Desactivar el indicador de procesamiento en caso de error
      isProcessing.value = false;

      // Manejo de error
      Fluttertoast.showToast(
          msg: 'Error processing image: $e',
          backgroundColor: Color(0xFFDCA8A8));
      return null;
    }
  }

  Future<String> summarizeUsingCompute(String responseText) async {
    try {
      isProcessing.value = true;
      final summary = await compute(summarizeResponse, responseText);
      return summary;
    } catch (e) {
      debugPrint("Error in compute isolate: $e");
      return "Summary failed.";
    } finally {
      isProcessing.value = false;
    }
  }
}

String summarizeResponse(String fullText) {
  if (fullText.trim().isEmpty) return "No response to summarize.";
  return '${fullText.split('.').first.trim()}...';
}
