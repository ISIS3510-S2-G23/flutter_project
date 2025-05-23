import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecosphere/services/chat_gpt_service.dart';
import 'package:hive/hive.dart';
import 'package:ecosphere/models/classification_entry.dart';
import 'package:path/path.dart' as p;

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
        // HASH simple usando el nombre del archivo
        final String hash = p.basename(_image!.path);

        // Cargar Hive
        final box = Hive.box<ClassificationEntry>('classifications');

        // Si ya está en Hive, mostrar desde caché
        if (box.containsKey(hash)) {
          final cached = box.get(hash);
          setState(() {
            _classification = cached?.classification;
            _loading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Result from local storage: $_classification')),
          );
          return;
        }

        // Si no está, llama al API
        final result = await _chatGptService.validatePhoto(_image!.path);

        setState(() {
          _classification = result ?? "We couldn't classify the item.";
        });

        if (result != null) {
          // Guardar en Hive
          final entry = ClassificationEntry(
            hash: hash,
            classification: result,
            date: DateTime.now(),
          );
          box.put(hash, entry);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Classification: $result'),
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
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              icon: const Icon(Icons.history),
              label: const Text("View History"),
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
