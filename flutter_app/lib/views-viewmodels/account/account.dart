// // import 'package:flutter/material.dart';

// // class Account extends StatelessWidget {
// //   const Account({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         automaticallyImplyLeading: false,
// //         title: Text(
// //           'Account',
// //           style: TextStyle(
// //             color: Color(0xFF49447E),
// //             fontWeight: FontWeight.bold,
// //             fontSize: 24,
// //           ),
// //         ),
// //       ),
// //       body: Center(
// //         child: Text(
// //           'TODO',
// //           style: TextStyle(
// //             fontSize: 24,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';

// class Account extends StatelessWidget {
//   const Account({Key? key}) : super(key: key);

//   // Método para construir cada opción (Edit Account, Settings, Help)
//   Widget _buildOption(String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20.0),
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//             height: 1.0,
//             color: Color(0xFF1F1F39),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // AppBar sin título para poder posicionar el título según Figma
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         toolbarHeight: 0, // Reducimos la altura del AppBar
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 38),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Espacio en la parte superior para colocar el título en la posición correcta
//               const SizedBox(height: 51.25),
              
//               // Título "Account" posicionado según especificaciones de Figma
//               const SizedBox(
//                 width: 105,
//                 height: 36,
//                 child: Text(
//                   'Account',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF49447E),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 24,
//                     height: 1.0, // line-height: 100%
//                     letterSpacing: 0,
//                   ),
//                 ),
//               ),
              
//               // Imagen centrada
//               const SizedBox(height: 20),
//               Center(
//                 child: Image.asset(
//                   'assets/images/People/WBG/person8.png',
//                   width: 111,
//                   height: 111,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Opciones de cuenta
//               _buildOption(
//                 'Edit Account',
//                 () {
//                   // TODO: lógica para Edit Account
//                 },
//               ),

//               _buildOption(
//                 'Settings and Privacy',
//                 () {
//                   // TODO: lógica para Settings
//                 },
//               ),

//               _buildOption(
//                 'Help',
//                 () {
//                   // TODO: lógica para Help
//                 },
//               ),

//               _buildOption(
//                 'Log Out',
//                 () async {
//                   // TODO: aquí llamas a tu signout, por ejemplo:
//                   // await AuthService().signout(context: context);
//                 },
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

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

  Future<void> _logout(BuildContext context) async {
    try {
      // Mostrar diálogo de confirmación
      bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out'),
            ),
          ],
        ),
      );
      
      // Si el usuario confirma, proceder con el logout
      if (confirmLogout == true) {
        // Limpiar SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Cerrar sesión en Firebase
        await FirebaseAuth.instance.signOut();
        
        // Navegar a la pantalla de login
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
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
                () async {
                  // Llamar a la función de logout
                  await _logout(context);
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}