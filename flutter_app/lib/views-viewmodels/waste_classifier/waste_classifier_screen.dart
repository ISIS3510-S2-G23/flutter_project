import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    _chatGptService = ChatGPTService(dotenv.env['KEY_ECOSPHERE']!);
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
        final result = await _chatGptService
            .validatePhoto(_image!.path); // Usa tu servicio

        setState(() {
          _classification = result ?? "No se pudo clasificar el residuo.";
        });
      } catch (e) {
        setState(() {
          _classification = "Error: ${e.toString()}";
        });
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
      appBar: AppBar(title: const Text('Clasificador de Residuos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar Foto"),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 250,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_classification != null && !_loading)
              Text(
                'Clasificación del residuo:\n$_classification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
