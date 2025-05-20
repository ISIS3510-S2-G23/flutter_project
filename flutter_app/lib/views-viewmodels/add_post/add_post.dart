import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosphere/repositories/posts_repository.dart';
import 'package:ecosphere/services/chat_gpt_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final ChatGPTService _chatGptService =
      ChatGPTService(dotenv.env['KEY_ECOSPHERE']!);

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
                leading: Icon(Icons.photo_library),
                title: Text('Phone gallery'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
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
    String cloudName = "dhrkcqd33";
    String uploadPreset = "ecosphere";

    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files
        .add(await http.MultipartFile.fromPath("file", imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse["secure_url"];
    }
    return null;
  }

  Future<bool> _uploadToFirebase() async {
    String title = _titleTextController.text.trim();
    String text = _textController.text.trim();

    if (title.isEmpty || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title/text cannot be empty')),
      );
      return false;
    }

    List<String> comments = [];
    List<String> tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    if (user == null) {
      FirebaseCrashlytics.instance.log("No user found in SharedPreferences");
      FirebaseCrashlytics.instance.recordError(
        Exception("User not found in SharedPreferences"),
        null,
      );
      return false;
    }

    if (_selectedImage == null) {
      await repository.uploadPosts(title, text, tags, user, comments);
      return true;
    }

    String? imageUrl = await _uploadImageToCloudinary(_selectedImage!);
    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc('post-$user-${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'title': title,
        'text': text,
        'tags': tags,
        'user': user,
        'timestamp': FieldValue.serverTimestamp(),
        'asset': imageUrl,
      });
      return true;
    }
    return false;
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
                    color: Color(0xFFD3ECED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.77,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What are you thinking today for the forum?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 18),
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
                                    decoration: InputDecoration(
                                      hintText:
                                          'An awesome title for your post',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Tell us here your green thoughts ♻️😁',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: 11,
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 18),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        children: [
                                          FilterChip(
                                            avatar: Icon(Icons.recycling,
                                                color: Colors.white),
                                            label: Text(
                                              'Recycle',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            labelStyle: TextStyle(
                                              color: _tagsController.text
                                                      .contains('Recycle')
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                            backgroundColor: Color(0xFFB9DCA8),
                                            selectedColor: Color(0xFF64C533),
                                            selected: _tagsController.text
                                                .contains('Recycle'),
                                            showCheckmark: false,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) {
                                                  _tagsController.text +=
                                                      'Recycle,';
                                                } else {
                                                  _tagsController.text =
                                                      _tagsController.text
                                                          .replaceAll(
                                                              'Recycle,', '');
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 5),
                                          FilterChip(
                                            avatar: Icon(Icons.compost,
                                                color: Colors.white),
                                            label: Text(
                                              'Upcycle',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            labelStyle: TextStyle(
                                              color: _tagsController.text
                                                      .contains('Upcycle')
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                            backgroundColor: Color(0xFFA8B7DC),
                                            selectedColor: Color(0xFF3D5CFF),
                                            selected: _tagsController.text
                                                .contains('Upcycle'),
                                            showCheckmark: false,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) {
                                                  _tagsController.text +=
                                                      'Upcycle,';
                                                } else {
                                                  _tagsController.text =
                                                      _tagsController.text
                                                          .replaceAll(
                                                              'Upcycle,', '');
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 5),
                                          FilterChip(
                                            avatar: Icon(Icons.directions_bike,
                                                color: Colors.white),
                                            label: Text(
                                              'Transport',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            labelStyle: TextStyle(
                                              color: _tagsController.text
                                                      .contains('Transport')
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                            backgroundColor: Color(0xFFDCA8A8),
                                            selectedColor: Color.fromARGB(
                                                255, 209, 46, 46),
                                            selected: _tagsController.text
                                                .contains('Transport'),
                                            showCheckmark: false,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) {
                                                  _tagsController.text +=
                                                      'Transport,';
                                                } else {
                                                  _tagsController.text =
                                                      _tagsController.text
                                                          .replaceAll(
                                                              'Transport,', '');
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          icon:
                                              Icon(Icons.add_a_photo_outlined),
                                          onPressed: () =>
                                              _showPicker(context)),
                                      _selectedImage != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle,
                                                    color: Color(0xFF03898C)),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Image uploaded',
                                                  style: TextStyle(
                                                      color: Color(0xFF03898C)),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    String suggestedText =
                                                        await _getSuggestedTextFromImage(
                                                            _selectedImage!);
                                                    if (!mounted) return;
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            'Add suggested caption?'),
                                                        content: Text(suggestedText
                                                                .isNotEmpty
                                                            ? suggestedText
                                                            : 'Could not genertae text for this image...'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('No'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              _textController
                                                                      .text =
                                                                  suggestedText;
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('Yes'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Text('Sugerir texto'),
                                                ),
                                              ],
                                            )
                                          : SizedBox(width: 10),
                                    ],
                                  )
                                ]),
                            SizedBox(height: 4.5),
                            ElevatedButton(
                                onPressed: () async {
                                  bool success = await _uploadToFirebase();
                                  if (success) {
                                    Navigator.pushNamed(context, '/index');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFA8DADC),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  minimumSize: Size(double.infinity, 50),
                                  textStyle: TextStyle(
                                      color: Color(0xFF49447E),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: Text("Post")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/index');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Icon(
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

  _getSuggestedTextFromImage(File file) async {
    return await _chatGptService.generateCaption(file);
  }
}
