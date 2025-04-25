import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  // Método para construir cada opción (Edit Account, Settings, Help)
  Widget _buildOption(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 1.0,
            color: Color(0xFF1F1F39),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar sin título para poder posicionar el título según Figma
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // Reducimos la altura del AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio en la parte superior para colocar el título en la posición correcta
              const SizedBox(height: 51.25),

              // Título "Account" posicionado según especificaciones de Figma
              const SizedBox(
                width: 105,
                height: 36,
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF49447E),
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.0, // line-height: 100%
                    letterSpacing: 0,
                  ),
                ),
              ),

              // Imagen centrada
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/People/WBG/person8.png',
                  width: 111,
                  height: 111,
                ),
              ),
              const SizedBox(height: 40),

              // Opciones de cuenta
              _buildOption(
                'Edit Account',
                () {
                  Navigator.pushNamed(context, '/edit-account');
                },
              ),

              _buildOption(
                'Settings and Privacy',
                () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),

              _buildOption(
                'Help',
                () {
                  Navigator.pushNamed(context, '/help');
                },
              ),

              _buildOption(
                'Log Out',
                () {
                  // Llamar a la función de logout
                  // await _logout(context);
                  Navigator.pushNamed(context, '/logout');
                },
              ),

              const SizedBox(height: 30),
              TextButton(
                onPressed: () => throw Exception(),
                child: const Text("Throw Test Exception"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
