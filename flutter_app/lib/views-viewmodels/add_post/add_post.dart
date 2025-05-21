import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosphere/repositories/posts_repository.dart';
// No necesitas importar ChatGPTService aquí si generateCaptionIsolateForCompute es autocontenido
// import 'package:ecosphere/services/chat_gpt_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Necesario para la llamada HTTP en el isolate
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiver/collection.dart';
import 'package:path_provider/path_provider.dart';

// --- INICIO DE LA FUNCIÓN DE NIVEL SUPERIOR PARA EL ISOLATE ---
// Esta función debe estar fuera de cualquier clase.
Future<String?> generateCaptionIsolateForCompute(Map<String, dynamic> args) async {
  final String? apiKey = args['apiKey'] as String?;
  final String filePath = args['filePath'] as String;
  const String visionApiUrl = 'https://api.openai.com/v1/chat/completions';

  if (apiKey == null || apiKey.isEmpty) {
    print('Isolate: OpenAI API Key is missing or empty.');
    return null; // O un mensaje de error predeterminado
  }

  try {
    final File imageFile = File(filePath);
    if (!await imageFile.exists()) {
      print('Isolate: Image file not found at $filePath');
      return "Error: Image file not found.";
    }
    final List<int> imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(visionApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o', // O 'gpt-4-vision-preview' u otro modelo con capacidad de visión
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': "Generate a short, engaging caption for this image, suitable for a social media post. Focus on themes of nature, environment, or sustainability if applicable. If not, a general positive caption. Max 30 words."
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
              }
            ]
          }
        ],
        'max_tokens': 60 // Ajusta según la longitud esperada de la respuesta
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // Usar utf8.decode para caracteres especiales
      if (data['choices'] != null && data['choices'].isNotEmpty &&
          data['choices'][0]['message'] != null &&
          data['choices'][0]['message']['content'] != null) {
        return data['choices'][0]['message']['content']?.toString().trim();
      } else {
        print('Isolate: Invalid response structure from OpenAI API: ${response.body}');
        return "Could not extract caption from API response.";
      }
    } else {
      print('Isolate: Error generating caption - Status ${response.statusCode}: ${response.body}');
      return "API error: Could not generate caption.";
    }
  } catch (e, s) {
    print('Isolate: Exception generating caption: $e');
    print('Isolate: Stacktrace: $s');
    // Considerar no enviar FirebaseCrashlytics desde el isolate directamente
    // si causa problemas, aunque errores simples deberían estar bien.
    // FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error in generateCaptionIsolateForCompute');
    return "Exception occurred while generating caption.";
  }
}
// --- FIN DE LA FUNCIÓN DE NIVEL SUPERIOR PARA EL ISOLATE ---


class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final PostsRepository repository = PostsRepository();
  final LruMap<String, String> _suggestedTextCache = LruMap(maximumSize: 5);
  DateTime? _entryTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
  }

  @override
  void dispose() {
    // _sendBQ(); // Considera si quieres enviar esto solo al salir de la pantalla, no al cerrar el post
    _titleTextController.dispose();
    _textController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _sendBQOnExit() { // Renombrado para claridad
    if (_entryTime != null) {
      final duration = DateTime.now().difference(_entryTime!);
      SharedPreferences.getInstance().then((prefs) {
        String? user = prefs.getString('username');
        if (user != null) {
          FirebaseFirestore.instance
              .collection('timeAddPost')
              .doc('user-$user-${DateTime.now().millisecondsSinceEpoch}') // Incluir user y timestamp único
              .set({'duration_in_seconds': duration.inSeconds, 'user': user});
        }
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Phone gallery'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    String cloudName = "dhrkcqd33"; // Considera mover a .env si es sensible
    String uploadPreset = "ecosphere"; // Considera mover a .env si es sensible

    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files
        .add(await http.MultipartFile.fromPath("file", imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse["secure_url"];
      } else {
        print("Cloudinary upload error: ${response.statusCode} - ${await response.stream.bytesToString()}");
        return null;
      }
    } catch (e, s) {
      print("Exception during Cloudinary upload: $e");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "Cloudinary Upload Failed");
      return null;
    }
  }

  Future<bool> _uploadToFirebase() async {
    String title = _titleTextController.text.trim();
    String text = _textController.text.trim();

    if (title.isEmpty || text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and text cannot be empty')),
        );
      }
      return false;
    }

    List<String> tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');

    if (user == null) {
      FirebaseCrashlytics.instance.log("No user found in SharedPreferences during post upload");
      FirebaseCrashlytics.instance.recordError(
        Exception("User not found in SharedPreferences for post upload"),
        null,
        fatal: true
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User session error. Please log in again.')),
        );
      }
      return false;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image. Please try again.')),
          );
        }
        return false;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc('post-$user-${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'title': title,
        'text': text,
        'tags': tags,
        'user': user,
        'timestamp': FieldValue.serverTimestamp(),
        if (imageUrl != null) 'asset': imageUrl, // Solo añade 'asset' si hay imagen
        'comments': [], // Inicializar con lista vacía de comentarios
      });
      return true;
    } catch (e, s) {
      print("Error uploading post to Firebase: $e");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "Firebase Post Upload Failed");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3ECED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.77,
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What are you thinking today for the forum?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _titleTextController,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'An awesome title for your post',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded( // Para que el TextField de texto ocupe el espacio restante
                                    child: TextField(
                                      controller: _textController,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Tell us here your green thoughts ♻️😁',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      maxLines: null, // Permite múltiples líneas dinámicamente
                                      expands: true, // Se expande para llenar el espacio vertical
                                      keyboardType: TextInputType.multiline,
                                      textAlignVertical: TextAlignVertical.top, // Alinea el texto al inicio
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Wrap( // Usar Wrap para los FilterChip para que se ajusten
                                    spacing: 8.0, // Espacio horizontal entre chips
                                    runSpacing: 4.0, // Espacio vertical si hay múltiples líneas
                                    alignment: WrapAlignment.center,
                                    children: [
                                      FilterChip(
                                        avatar: const Icon(Icons.recycling,
                                            color: Colors.white),
                                        label: const Text(
                                          'Recycle',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        labelStyle: TextStyle(
                                          color: _tagsController.text
                                                  .contains('Recycle')
                                              ? Colors.white
                                              : Colors.black87, // Color de texto no seleccionado
                                        ),
                                        backgroundColor: _tagsController.text.contains('Recycle') ? const Color(0xFF64C533) : const Color(0xFFB9DCA8),
                                        selectedColor: const Color(0xFF64C533),
                                        selected: _tagsController.text
                                            .contains('Recycle'),
                                        showCheckmark: false,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            String currentTags = _tagsController.text;
                                            if (selected) {
                                              if (!currentTags.contains('Recycle,')) _tagsController.text += 'Recycle,';
                                            } else {
                                              _tagsController.text = currentTags.replaceAll('Recycle,', '');
                                            }
                                          });
                                        },
                                      ),
                                      FilterChip(
                                        avatar: const Icon(Icons.compost,
                                            color: Colors.white),
                                        label: const Text(
                                          'Upcycle',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        labelStyle: TextStyle(
                                          color: _tagsController.text
                                                  .contains('Upcycle')
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        backgroundColor: _tagsController.text.contains('Upcycle') ? const Color(0xFF3D5CFF) : const Color(0xFFA8B7DC),
                                        selectedColor: const Color(0xFF3D5CFF),
                                        selected: _tagsController.text
                                            .contains('Upcycle'),
                                        showCheckmark: false,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            String currentTags = _tagsController.text;
                                            if (selected) {
                                               if (!currentTags.contains('Upcycle,')) _tagsController.text += 'Upcycle,';
                                            } else {
                                              _tagsController.text = currentTags.replaceAll('Upcycle,', '');
                                            }
                                          });
                                        },
                                      ),
                                      FilterChip(
                                        avatar: const Icon(Icons.directions_bike,
                                            color: Colors.white),
                                        label: const Text(
                                          'Transport',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        labelStyle: TextStyle(
                                          color: _tagsController.text
                                                  .contains('Transport')
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        backgroundColor: _tagsController.text.contains('Transport') ? const Color.fromARGB(255, 209, 46, 46) : const Color(0xFFDCA8A8),
                                        selectedColor: const Color.fromARGB(
                                            255, 209, 46, 46),
                                        selected: _tagsController.text
                                            .contains('Transport'),
                                        showCheckmark: false,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            String currentTags = _tagsController.text;
                                            if (selected) {
                                               if (!currentTags.contains('Transport,')) _tagsController.text += 'Transport,';
                                            } else {
                                              _tagsController.text = currentTags.replaceAll('Transport,', '');
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          icon:
                                              const Icon(Icons.add_a_photo_outlined),
                                          onPressed: () =>
                                              _showPicker(context)),
                                      if (_selectedImage != null) // Usar if para mostrar condicionalmente
                                        Expanded( // Para que el Row ocupe el espacio disponible
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start, // Alinear al inicio
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Color(0xFF03898C)),
                                              const SizedBox(width: 5),
                                              const Flexible( // Para que el texto se ajuste
                                                child: Text(
                                                  'Image selected', // Cambiado para claridad
                                                  style: TextStyle(
                                                      color: Color(0xFF03898C)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (_selectedImage == null) return;
                                                  String suggestedText =
                                                      await _getSuggestedTextFromImage(
                                                          _selectedImage!);
                                                  if (mounted) { // Verificar si el widget sigue montado
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Add suggested caption?'),
                                                        content: Text(suggestedText), // Ya maneja el error en _getSuggestedTextFromImage
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text('No'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              _textController.text = suggestedText;
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text('Yes'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text('Suggest caption'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  )
                                ]),
                            const SizedBox(height: 4.5),
                            ElevatedButton(
                                onPressed: () async {
                                  bool success = await _uploadToFirebase();
                                  if (success && mounted) {
                                    _sendBQOnExit(); // Enviar BQ al salir con éxito
                                    Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false); // Limpiar stack
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA8DADC),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  minimumSize: const Size(double.infinity, 50),
                                  textStyle: const TextStyle(
                                      color: Color(0xFF49447E),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: const Text("Post")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendBQOnExit(); // Enviar BQ al presionar el botón de cerrar
                    Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false); // Limpiar stack
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white, // Fondo blanco para el botón de cerrar
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF49447E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _getSuggestedTextFromImage(File file) async {
    final key = file.path.hashCode.toString(); // Usar algo más robusto si es necesario, como el path
    
    // VIVAVOCE: cache -> hace cache fb to network, y si no, se vuelve network only
    if (_suggestedTextCache.containsKey(key)) {
      return _suggestedTextCache[key]!;
    }

    // No es necesario guardar el archivo localmente de nuevo si ya tienes el `File file`
    // final List<int> imageBytes = await file.readAsBytes();
    // final File savedFile = await saveFileLocally(imageBytes, key);

    // VIVAVOCE: compute -> uso de un nuevo thread ISOLATE
    // Llama a la nueva función de nivel superior
    final String? result = await compute(generateCaptionIsolateForCompute, {
      'apiKey': dotenv.env['KEY_ECOSPHERE'], // Asegúrate que esta es tu clave de API de OpenAI
      'filePath': file.path, // Usar el path del archivo original
    });

    final String caption = result ?? "Could not generate caption for this image.";
    // VIVAVOCE: LRU cache -> uso de cache para no generar de nuevo el caption si ya se había generado
    _suggestedTextCache[key] = caption;
    return caption;
  }

  // La función saveFileLocally puede que ya no sea necesaria aquí si solo la usabas para el isolate
  // y ahora pasas el path directamente. Si la usas para otra cosa, mantenla.
  // Future<File> saveFileLocally(List<int> bytes, String filename) async {
  //   // VIVAVOCE: Local storage -> uso de local storge PathUtils para guardar las imágenes
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/$filename');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }
}