import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpvoteButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Ajusta aquí tu usuario actual según la autenticación real que tengas
    final currentUser = 'UserX';

    // Verificamos si ya votó
    final hasVoted = upvotedBy.contains(currentUser);

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
            '$upvotes',
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
    final currentUser = 'UserX'; // Ajusta según tu autenticación

    try {
      final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      if (upvotedBy.contains(currentUser)) {
        // Ya había votado => remover el voto
        await docRef.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': FieldValue.arrayRemove([currentUser]),
        });
      } else {
        // No había votado => agregar el voto
        await docRef.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': FieldValue.arrayUnion([currentUser]),
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
