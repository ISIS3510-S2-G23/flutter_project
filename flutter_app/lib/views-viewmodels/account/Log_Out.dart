import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Limpiar SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      
      // Navegar a la pantalla de login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Manejar errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
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
          'Log Out',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF49447E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de salida
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Color(0xFFFF4B4B),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              
              // Título y mensaje
              const Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF49447E),
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF858597),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 36),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF49447E)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color(0xFF49447E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF49447E),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}