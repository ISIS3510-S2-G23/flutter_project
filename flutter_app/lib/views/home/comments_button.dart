import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsButton extends StatelessWidget {
  final String postId;
  // Mapa donde cada clave es un usuario y el valor es el comentario
  // Ejemplo: { "camilom325-7239847213": "I love recycling <3" }
  final Map<String, dynamic> commentsMap;

  const CommentsButton({
    Key? key,
    required this.postId,
    required this.commentsMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Al pulsar, abrimos el diálogo centrado
      onTap: () => _showCommentsDialog(context),
      child: Icon(
        Icons.add_comment,
        size: 20,              // width: 20; height: 20
        color: const Color(0xFF1C1B1F),  // siempre #1C1B1F
      ),
    );
  }

  void _showCommentsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // cierra al pulsar fuera
      builder: (_) => _CommentsDialog(
        postId: postId,
        commentsMap: commentsMap,
      ),
    );
  }
}

// ----------------------------------------------------
// Diálogo centrado que muestra y edita los comentarios
// ----------------------------------------------------
class _CommentsDialog extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> commentsMap;

  const _CommentsDialog({
    Key? key,
    required this.postId,
    required this.commentsMap,
  }) : super(key: key);

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Convertimos el map en una lista de {user, text} para mostrar
    final commentsList = _mapToList(widget.commentsMap);

    // Diálogo centrado con ancho ~350 y alto ~420 (para que "Post" se vea mejor)
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Ajustamos ancho y alto para que quepa mejor el botón "Post"
      child: Container(
        width: 350,   // Ajustado a 350
        height: 420,  // Ajustado a 420
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ícono de cerrar en esquina sup. derecha
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF49447E)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Lista de comentarios
            Expanded(
              child: commentsList.isEmpty
                  ? const Center(child: Text('No comments yet'))
                  : ListView.builder(
                      itemCount: commentsList.length,
                      itemBuilder: (context, index) {
                        final userKey = commentsList[index]['user'] ?? 'Unknown';
                        final text = commentsList[index]['text'] ?? '';
                        return _buildCommentCard(userKey, text);
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Título: Type your comment for this post
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type your comment for this post',
                style: TextStyle(
                  // font-family: Inter
                  // font-weight: 500
                  // font-size: 12
                  // line-height: 100%
                  // color #1F1F39
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F1F39),
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Caja de texto (279x63, borderRadius=10)
            Container(
              width: 279,
              height: 63,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a comment... :)',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  contentPadding: const EdgeInsets.all(8),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botón "Post"
            SizedBox(
              width: 100,  // Aumentamos de 88 a 100 px
              height: 28,  // Aumentamos de 25 a 28 px
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF49447E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  // Puedes ajustar padding adicional si lo deseas, no lo recomeindo por ahora
                  // padding-top: 10, etc. => Ajusta si deseas, se ve mal 
                  // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  
                ),
                onPressed: _postComment,
                child: const Text(
                  'Post',
                  style: TextStyle(
                    // layout width=25, height=28
                    // font-size=12
                    // color #FFFFFF
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para convertir el map en una lista de {user, text}
  List<Map<String, String>> _mapToList(Map<String, dynamic> map) {
    // Estructura: { "camilom325-7239847213": "I love recycling <3", ... }
    // Queremos => [ { user: "camilom325-7239847213", text: "I love recycling <3" }, ... ]
    final List<Map<String, String>> list = [];
    map.forEach((key, value) {
      list.add({'user': key, 'text': value.toString()});
    });
    return list;
  }

  // Card de cada comentario
  Widget _buildCommentCard(String user, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de persona
            const Icon(
              Icons.person,
              size: 16,
              color: Color(0xFF49447E),
            ),
            const SizedBox(width: 6),
            // Usuario y texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF49447E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = 'mockUser'; // Ajusta al usuario actual real
    try {
      final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      // Para este ejemplo, sobrescribimos la clave "user+timestamp" o algo similar
      final uniqueKey = '$currentUser-${DateTime.now().millisecondsSinceEpoch}';

      // Copiamos el map actual
      final updatedMap = Map<String, dynamic>.from(widget.commentsMap);
      // Agregamos o sobrescribimos
      updatedMap[uniqueKey] = text;

      // Actualizamos Firestore
      await docRef.update({'comments': updatedMap});
      
      setState(() {
        widget.commentsMap[uniqueKey] = text;
      });

      _commentController.clear();
    } catch (e) {
      debugPrint('Error posting comment: $e');
    }
  }
}
