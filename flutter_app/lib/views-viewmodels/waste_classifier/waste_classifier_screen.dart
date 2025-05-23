import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecosphere/services/chat_gpt_service.dart';

class WasteClassifierScreen extends StatefulWidget {
  @override
  _WasteClassifierScreenState createState() => _WasteClassifierScreenState();
}

class _WasteClassifierScreenState extends State<WasteClassifierScreen> {
  File? _image;
  bool _loading = false;
  String? _classification;

  final ImagePicker _picker = ImagePicker();
  late final ChatGPTService _chatGptService;

  final Map<String, String> _classificationCache = {};

  @override
  void initState() {
    super.initState();
    _chatGptService = ChatGPTService(dotenv.env['KEY_ECOSPHERE']!);
  }

  // Genera un hash para identificar la imagen
  Future<String> _generateHash(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes).substring(0, 50);
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _classification = null;
        _loading = true;
      });

      try {
        final hash = await _generateHash(_image!);

        // Verificamos si ya fue clasificada esta imagen
        if (_classificationCache.containsKey(hash)) {
          setState(() {
            _classification = _classificationCache[hash];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Result from cache: $_classification'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        } else {
          // Si no, a enviamos a chat
          final result = await _chatGptService.validatePhoto(_image!.path);
          final response = result ?? "We couldn't classify the item.";

          _classificationCache[hash] = response;

          setState(() {
            _classification = response;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Classification: $response'),
              backgroundColor: Colors.green[600],
            ),
          );
        }
      } catch (e) {
        setState(() {
          _classification = "An error occurred during classification.";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waste Classifier')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset(
              'assets/images/People/MORE/ImagenForTrash.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Take a photo of the object you want to discard. The system will analyze the image and tell you which type of bin it belongs to (organic, recyclable, etc.).',
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _pickImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Take Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF49447E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_classification != null && !_loading)
              Column(
                children: [
                  const Text(
                    'Result:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _classification!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF49447E),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
