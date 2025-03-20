import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa los widgets UpvoteButton y CommentsButton
import 'upvote_button.dart';
import 'comments_button.dart';

// Si usas librerías de Cloudinary, las importas aquí
import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  final TextEditingController _searchController = TextEditingController();

  // Filtro de chips; si es null se muestran todos los posts
  String? _selectedChip;

  // Búsqueda local
  String _searchQuery = '';


  @override
  Widget build(BuildContext context) {
    // Determina el stream de posts según el chip seleccionado
    final postsStream = (_selectedChip != null)
        ? FirebaseFirestore.instance
            .collection('posts')
            .where('tags', arrayContains: _selectedChip)
            .snapshots()
        : FirebaseFirestore.instance.collection('posts').snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Forum 1',
          style: TextStyle(
            color: Color(0xFF49447E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF49447E)),
            onPressed: () {
              // Acción para ir al perfil
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF49447E)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // BARRA DE BÚSQUEDA
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Find topics',
                hintStyle: const TextStyle(color: Color(0xFF49447E)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF49447E)),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFEAEAFF),
              ),
            ),

            const SizedBox(height: 16),

            // FILA DE CHIPS (filtro)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Recycle'),
                  _buildFilterChip('Upcycle'),
                  _buildFilterChip('Transport'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LISTA DE POSTS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: postsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No posts found'));
                  }

                  // Filtrado local por búsqueda
                  final allPosts = snapshot.data!.docs;
                  final filteredPosts = allPosts.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final txt = data['text']?.toString().toLowerCase() ?? '';
                    final searchLower = _searchQuery.toLowerCase();
                    return title.contains(searchLower) || txt.contains(searchLower);
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return const Center(child: Text('No posts match your search'));
                  }

                  return ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final doc = filteredPosts[index];
                      final data = doc.data() as Map<String, dynamic>;

                      // Campos básicos
                      final title = data['title'] ?? '';
                      final user = data['user'] ?? '';
                      final text = data['text'] ?? '';
                      final tags = (data['tags'] is List)
                          ? (data['tags'] as List).join(', ')
                          : (data['tags'] ?? '');

                      // Lectura de upvotes
                      final upvotes = data['upvotes'] is int ? data['upvotes'] as int : 0;
                      final upvotedBy = data['upvotedBy'] is List ? data['upvotedBy'] as List : [];

                      // Campo asset (Cloudinary)
                      final asset = data['asset'] ?? '';

                      // Mapa de comentarios
                      // Estructura { "camilom325-7239847213": "I love recycling <3", ... }
                      final commentsMap = (data['comments'] is Map<String, dynamic>)
                          ? data['comments'] as Map<String, dynamic>
                          : {};

                      return _buildPostCard(
                        postId: doc.id,
                        title: title,
                        user: user,
                        text: text,
                        tags: tags,
                        asset: asset,
                        upvotes: upvotes,
                        upvotedBy: upvotedBy,
                        commentsMap: commentsMap.cast<String, dynamic>(), // pasamos el mapa
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ CHIP DE FILTRO ------------------
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedChip == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF49447E),
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF49447E),
          fontSize: 14,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedChip = selected ? label : null;
          });
        },
      ),
    );
  }

  // ------------------ TARJETA DE POST ------------------
  Widget _buildPostCard({
    required String postId,
    required String title,
    required String user,
    required String text,
    required String tags,
    required String asset,
    required int upvotes,
    required List upvotedBy,
    required Map<String, dynamic> commentsMap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + tags
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (tags.isNotEmpty)
                  Text(
                    tags,
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Usuario
            Text(
              'by $user',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),

            // Texto
            Text(text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            // Imagen Cloudinary (si asset no está vacío)
            if (asset.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 180,
                child: CldImageWidget(
                  publicId: asset,
                  transformation: Transformation()
                    ..resize(Resize.fill()
                      ..width(250)
                      ..height(250))
                    ..effect(Effect.sepia()), // Ajusta si deseas
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Fila con Upvote y Comments
            Row(
              children: [
                // UpvoteButton (definido en upvote_button.dart)
                UpvoteButton(
                  postId: postId,
                  upvotes: upvotes,
                  upvotedBy: upvotedBy,
                ),
                const SizedBox(width: 16),
                // CommentsButton (definido en comments_button.dart)
                // Requiere el mapa de comentarios
                CommentsButton(
                  postId: postId,
                  commentsMap: commentsMap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

