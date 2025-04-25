import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditAccount extends StatefulWidget {
  const EditAccount({super.key});

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';

        // Obtener datos de Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc('user-${currentUser.email}')
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          _usernameController.text =
              userData['username'] ?? currentUser.displayName ?? '';
        } else {
          _usernameController.text = currentUser.displayName ?? '';
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading user data: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      String email = currentUser.email ?? '';

      // Actualizar displayName en Firebase Auth
      await currentUser.updateDisplayName(_usernameController.text);

      // Actualizar datos en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user-$email')
          .update({
        'username': _usernameController.text,
      });

      // Actualizar SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);

      // Mostrar toast de éxito
      Fluttertoast.showToast(
        msg: 'Profile updated successfully',
        backgroundColor: Colors.green,
      );

      // Volver a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error updating profile: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF49447E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF49447E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF49447E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : const AssetImage(
                                  'assets/images/People/WBG/person8.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF49447E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campos de formulario
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Color(0xFF858597)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF49447E)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    enabled: false, // El email no se puede editar
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF858597)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botón de guardar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF49447E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
