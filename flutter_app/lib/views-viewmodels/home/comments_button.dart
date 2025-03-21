import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repositories/posts_repository.dart';

class CommentsButton extends StatelessWidget {
  final String postId;
  // Mapa donde cada clave es un usuario y el valor es el comentario
  // Ejemplo: { "camilom325-7239847213": "I love recycling <3" }
  final Map<String, dynamic> commentsMap;

  const CommentsButton({
    super.key,
    required this.postId,
    required this.commentsMap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Al pulsar, abrimos el diálogo centrado
      onTap: () => _showCommentsDialog(context),
      child: Icon(
        Icons.add_comment_outlined,
        size: 20, // width: 20; height: 20
        color: const Color(0xFFBBBBBC),
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
    required this.postId,
    required this.commentsMap,
  });

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();

  // Variable para guardar el nombre de usuario de SharedPreferences
  String? user;

  var postsRepository = PostsRepository();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Cargamos el nombre de usuario desde SharedPreferences
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ajusta la llave "username" si la guardaste con otro nombre
      user = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convertimos el map en una lista de {user, text} para mostrar
    final commentsList = _mapToList(widget.commentsMap);

    // Diálogo centrado con ancho ~350 y alto ~420 (para que "Post" se vea mejor)
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados de 16
      ),
      // Ajustamos ancho y alto para que quepa mejor el botón "Post"
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
        ),
        width: 350,
        height: 500,
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
                        final userKey =
                            commentsList[index]['user'] ?? 'Unknown';
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F39),
                  height: 1.0, // line-height: 100%
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Caja de texto (279x63, borderRadius=10)
            Container(
              width: 310,
              height: 63,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a comment here',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  contentPadding: const EdgeInsets.all(8),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botón "Post"
            SizedBox(
              width: 100, // Aumentamos de 88 a 100 px
              height: 28, // Aumentamos de 25 a 28 px
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF49447E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  // Puedes ajustar padding adicional si lo deseas, no lo recomiendo por ahora
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
      color: Colors.white,
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
            // Usuario y texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icono de usuario
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFFB8B8D2),
                      ),
                      SizedBox(width: 4),
                      // Nombre de usuario
                      Text(
                        user.contains('-')
                            ? user
                                .split('-')
                                .sublist(0, user.split('-').length - 1)
                                .join('-')
                            : user,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8B8D2),
                        ),
                      ),
                    ],
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

  // Cambiamos la lógica para usar el "user" de SharedPreferences en lugar de "mockUser"
  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Si user sigue siendo null, no podemos postear
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found. Please log in first.')),
      );
      return;
    }

    try {
      final docRefFuture = postsRepository.getDocByPostId(widget.postId);
      final docRef = await docRefFuture;

      // Usamos user como parte de la clave
      final uniqueKey = '$user-${DateTime.now().millisecondsSinceEpoch}';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
