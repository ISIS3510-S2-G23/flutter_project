// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UpvoteButton extends StatelessWidget {
//   final String postId;
//   final int upvotes;
//   final List upvotedBy;

//   const UpvoteButton({
//     Key? key,
//     required this.postId,
//     required this.upvotes,
//     required this.upvotedBy,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Ajusta aquí tu usuario actual según la autenticación real que tengas
//     final currentUser = 'UserX';

//     // Verificamos si ya votó
//     final hasVoted = upvotedBy.contains(currentUser);

//     // Color del ícono: #1C1B1F si no ha votado, #38F745 si sí lo hizo
//     final iconColor = hasVoted
//         ? const Color(0xFF38F745)
//         : const Color(0xFF1C1B1F); // Opacidad 1.0 (puedes ajustar)

//     return InkWell(
//       onTap: () => _toggleUpvote(context),
//       child: Row(
//         children: [
//           Icon(
//             Icons.arrow_circle_up,
//             size: 20,       // width y height de 20
//             color: iconColor,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             '$upvotes',
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF49447E),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Lógica para alternar upvote / quitar upvote
//   Future<void> _toggleUpvote(BuildContext context) async {
//     final currentUser = 'UserX'; // Ajusta según tu autenticación

//     try {
//       final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);

//       if (upvotedBy.contains(currentUser)) {
//         // Ya había votado => remover el voto
//         await docRef.update({
//           'upvotes': FieldValue.increment(-1),
//           'upvotedBy': FieldValue.arrayRemove([currentUser]),
//         });
//       } else {
//         // No había votado => agregar el voto
//         await docRef.update({
//           'upvotes': FieldValue.increment(1),
//           'upvotedBy': FieldValue.arrayUnion([currentUser]),
//         });
//       }
//     } catch (e) {
//       debugPrint('Error toggling upvote: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error toggling upvote')),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpvoteButton extends StatefulWidget {
  final String postId;
  final int upvotes;
  final List upvotedBy;

  const UpvoteButton({
    Key? key,
    required this.postId,
    required this.upvotes,
    required this.upvotedBy,
  }) : super(key: key);

  @override
  State<UpvoteButton> createState() => _UpvoteButtonState();
}

// Converitmos en StatefulWidget para cargar el usuario de SharedPreferences
class _UpvoteButtonState extends State<UpvoteButton> {
  // Ajusta aquí tu usuario actual según la autenticación real que tengas
  String? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Cargamos el nombre de usuario desde SharedPreferences
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('username'); // Cambia la llave si usas otra
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si el usuario ya votó
    // si user es null, asumimos que no (no se logueó)
    final hasVoted = user != null && widget.upvotedBy.contains(user);

    // Color del ícono: #1C1B1F si no ha votado, #38F745 si sí lo hizo
    final iconColor = hasVoted
        ? const Color(0xFF38F745)
        : const Color(0xFF1C1B1F); // Opacidad 1.0 (puedes ajustar)

    return InkWell(
      onTap: () => _toggleUpvote(context),
      child: Row(
        children: [
          Icon(
            Icons.arrow_circle_up,
            size: 20,       // width y height de 20
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.upvotes}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF49447E),
            ),
          ),
        ],
      ),
    );
  }

  // Lógica para alternar upvote / quitar upvote
  Future<void> _toggleUpvote(BuildContext context) async {
    // Si user sigue siendo null, significa que no hay usuario logueado
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found. Please log in first.')),
      );
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      if (widget.upvotedBy.contains(user)) {
        // Ya había votado => remover el voto
        await docRef.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': FieldValue.arrayRemove([user]),
        });
      } else {
        // No había votado => agregar el voto
        await docRef.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': FieldValue.arrayUnion([user]),
        });
      }
    } catch (e) {
      debugPrint('Error toggling upvote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error toggling upvote')),
      );
    }
  }
}
