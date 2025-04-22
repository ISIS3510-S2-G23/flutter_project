// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:ecosphere/repositories/challenges_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTS necesarios para tomar la foto
import 'package:image_picker/image_picker.dart';
import 'package:ecosphere/services/chat_gpt_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Challenges extends StatefulWidget {
  final TabController tabController;

  const Challenges({super.key, required this.tabController});

  @override
  _ChallengesState createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  String? user;

  // ------------------------ NUEVOS CAMPOS ------------------------
  File? _selectedImage; // Donde guardaremos la foto tomada
  final ImagePicker _picker = ImagePicker(); // Instancia de image_picker
  final ChatGPTService _chatGptService =
      ChatGPTService(dotenv.env['KEY_ECOSPHERE']!); // Servicio de ChatGPT

  bool _isProcessing = false; // Para mostrar indicador de carga
  final ChallengesRepository _challengesRepository = ChallengesRepository();
  // --------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('username');
    });
  }

  // Método para resetear el estado del challenge
  void _resetChallengeState() {
    setState(() {
      _selectedImage = null;
      _isProcessing = false;
    });
  }

  // ----------------------------------------------------------------
  // MÉTODO para abrir la cámara y procesar la foto automáticamente
  // ----------------------------------------------------------------
  Future<void> _pickImageFromCamera(dynamic challenge) async {
    try {
      // Mostrar un indicador de progreso mientras se toma la foto
      setState(() {
        _isProcessing = true;
      });

      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Mostrar indicador de progreso mientras se procesa
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Processing image, please wait...'),
        //     duration: Duration(seconds: 2),
        //   ),
        // );

        // Llamamos a nuestro servicio de validación con ChatGPT
        final code = await _chatGptService.validatePhoto(_selectedImage!.path);

        // Si ChatGPT responde positivamente (code no es null)
        if (code != null) {
          // Marcar el desafío como completado automáticamente
          if (user != null) {
            await _challengesRepository.setCompletedChallenge(challenge.id, user);
            
            // Cerrar el diálogo actual
            Navigator.of(context).pop();
            
            // Mostrar el diálogo de desafío completado con un delay corto
            Future.delayed(const Duration(milliseconds: 300), () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        _buildCompletedChallenge(),
                      ],
                    ),
                  );
                },
              );
            });
          }
        } else {
          // // La imagen no cumplió con los requisitos
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: const Text(
          //       'The image does not meet the requirements. Please try again.',
          //       style: TextStyle(fontSize: 16),
          //     ),
          //     backgroundColor: Colors.red.shade700,
          //     duration: const Duration(seconds: 10),
          //   ),
          // );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Siempre terminar el procesamiento
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: StreamBuilder(
            stream: Stream.fromFuture(_challengesRepository.getChallenges())
                .asyncExpand((stream) => stream),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text('No challenges available'));
                }
              }
              var challenges = snapshot.data!.docs;
              return ListView.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  var challenge = challenges[index];

                  return FutureBuilder(
                    future: _challengesRepository.getUsersChallenges(
                        challenge.id, user),
                    builder: (context, userChallengeSnapshot) {
                      if (!userChallengeSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var userChallengeData = userChallengeSnapshot.data!;
                      bool isCompleted = userChallengeData.exists
                          ? userChallengeData['completed']
                          : false;

                      int progress = userChallengeData.exists
                          ? (userChallengeData['progress'] * 100).toInt()
                          : 0;

                      return GestureDetector(
                        onTap: () {
                          // Reseteamos el estado antes de mostrar el diálogo
                          _resetChallengeState();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          // Reseteamos el estado al cerrar el diálogo
                                          _resetChallengeState();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    if (isCompleted)
                                      _buildCompletedChallenge()
                                    else
                                      _buildRegisterVisit(challenge),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFFD3ECED)
                                        : const Color(0xFFEAEAFF),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      isCompleted
                                          ? Icons.check_circle_outline
                                          : Icons.donut_large_outlined,
                                      color: isCompleted
                                          ? const Color(0xFF03898C)
                                          : const Color(0xFF49447E),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(challenge['title']),
                                    Text(
                                      '$progress% completed',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB8B8D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // WIDGET SI EL CHALLENGE ESTÁ COMPLETADO
  // -------------------------------------------------------
  Widget _buildCompletedChallenge() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF03898C),
          size: 100,
        ),
        const SizedBox(height: 10),
        const Text(
          'You finished the challenge!',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF03898C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You can claim your reward',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF858597),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.tabController.animateTo(2); // Ir a Rewards
              Navigator.of(context).pop();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA8DADC),
          ),
          child: const Text(
            'Claim',
            style: TextStyle(
              color: Color(0xFF49447E),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  // -------------------------------------------------------
  // WIDGET SI EL CHALLENGE NO ESTÁ COMPLETADO
  // -------------------------------------------------------
  Widget _buildRegisterVisit(dynamic challenge) {
    return Column(
      children: [
        const Text(
          'Register Visit',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF49447E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Validate your challenge with a photo of ${challenge['description']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF858597),
          ),
        ),
        const SizedBox(height: 25),
        
        // Si está procesando, mostrar indicador
        _isProcessing
            ? const CircularProgressIndicator(color: Color(0xFF49447E))
            : ElevatedButton.icon(
                onPressed: () {
                  // LLAMAMOS AL MÉTODO de la cámara pasando el challenge
                  _pickImageFromCamera(challenge);
                },
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAEAFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
        
        const SizedBox(height: 15),
        const Text(
          'Take a clear photo that shows the activity',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF858597),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}