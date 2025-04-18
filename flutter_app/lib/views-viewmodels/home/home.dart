import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa los widgets UpvoteButton y CommentsButton
import '../../repositories/posts_repository.dart';
import 'upvote_button.dart';
import 'comments_button.dart';

// Si usas librerías de Cloudinary, las importas aquí
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
  final PostsRepository repository = PostsRepository();

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
        toolbarHeight: 110,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      'Ecosphere forum',
                      style: TextStyle(
                        color: Color(0xFF49447E),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/images/People/WBG/person8.png',
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // BARRA DE BÚSQUEDA
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Find topics',
                  hintStyle: const TextStyle(color: Color(0xFF49447E)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF49447E)),
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
                    _buildFilterChip('Recycle', Color(0xFFB9DCA8),
                        Color(0xFF64C533), Icons.recycling),
                    _buildFilterChip('Upcycle', Color(0xFFA8B7DC),
                        Color(0xFF3D5CFF), Icons.compost),
                    _buildFilterChip(
                        'Transport',
                        Color(0xFFDCA8A8),
                        Color.fromARGB(255, 209, 46, 46),
                        Icons.directions_bike),
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
                      final title =
                          data['title']?.toString().toLowerCase() ?? '';
                      final txt = data['text']?.toString().toLowerCase() ?? '';
                      final searchLower = _searchQuery.toLowerCase();
                      return title.contains(searchLower) ||
                          txt.contains(searchLower);
                    }).toList();

                    if (filteredPosts.isEmpty) {
                      return const Center(
                          child: Text('No posts match your search'));
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
                        final upvotes =
                            data['upvotes'] is int ? data['upvotes'] as int : 0;
                        final upvotedBy = data['upvotedBy'] is List
                            ? data['upvotedBy'] as List
                            : [];

                        // Campo asset (Cloudinary)
                        final asset = data['asset'] ?? '';

                        // Mapa de comentarios
                        // Estructura { "camilom325-7239847213": "I love recycling <3", ... }
                        final commentsMap =
                            (data['comments'] is Map<String, dynamic>)
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
                          commentsMap: commentsMap
                              .cast<String, dynamic>(), // pasamos el mapa
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ CHIP DE FILTRO ------------------
  Widget _buildFilterChip(
      String label, Color bgColor, Color selectedColor, IconData icon) {
    final isSelected = _selectedChip == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(icon, color: Colors.white),
        selected: isSelected,
        selectedColor: selectedColor,
        backgroundColor: bgColor,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Poppins',
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
      color: Colors.white,
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 4.0,
                    children: tags.split(', ').map((tag) {
                      Color chipColor;
                      switch (tag.toLowerCase()) {
                        case 'recycle':
                          chipColor = Color(0xFFB9DCA8);
                          break;
                        case 'upcycle':
                          chipColor = Color(0xFFA8B7DC);
                          break;
                        case 'transport':
                          chipColor = Color(0xFFDCA8A8);
                          break;
                        default:
                          chipColor = Colors.grey;
                      }
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: 'Poppins'),
                        ),
                        backgroundColor: chipColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide.none,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                      );
                    }).toList(),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Usuario
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Color(0xFFB8B8D2)),
                const SizedBox(width: 4),
                Text(
                  user,
                  style: TextStyle(fontSize: 13, color: Color(0xFFB8B8D2)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Texto
            Text(text, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),

            // Imagen Cloudinary (si asset no está vacío)
            if (asset.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 350,
                child: CldImageWidget(
                    publicId: asset,
                    transformation: Transformation()
                      ..resize(Resize.auto())
                      ..addTransformation("r_max")),
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
