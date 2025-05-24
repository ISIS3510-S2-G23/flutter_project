import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecosphere/views-viewmodels/waste_classifier/waste_classifier_screen.dart';

// Importaciones para los botones de comentarios y upvotes
import 'comments_button.dart';
import 'upvote_button.dart';

// Importaciones para Cloudinary (mantenidas para transformación de URLs)
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';

// Importación del repositorio y modelos
import '../../repositories/post_repository.dart';
import '../../models/post_model.dart';

// Configuración de Cloudinary - ajusta según tu configuración
const String cloudName = 'ecosphere'; // Reemplaza con tu cloud name
final cloudinary = Cloudinary.fromCloudName(cloudName: cloudName);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedChip;
  String _searchQuery = '';

  // Instancia del repositorio
  final PostsRepository _postsRepository = PostsRepository();

  // Microopt: cache simple para el filtro
  List<PostModel>? _lastPosts;
  String? _lastQuery;
  List<PostModel>? _lastFiltered;

  @override
  void initState() {
    super.initState();
    _sendTagCountsToFirebase();
  }

  Future<void> _sendTagCountsToFirebase() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      final Map<String, int> tagCounts = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['tags'] is List) {
          for (var tag in data['tags']) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('tagCounts')
          .doc('counts')
          .set(tagCounts, SetOptions(merge: true));

      if (kDebugMode) {
        print('Tag counts enviados a Firebase: $tagCounts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar los tag counts: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTagChips(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<PostModel>>(
                stream: _postsRepository.getPosts(tag: _selectedChip),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final posts = snapshot.data ?? const <PostModel>[];
                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts available'));
                  }

                  final filtered = _applySearchFilterCached(posts);

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No posts match your search'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _postCard(filtered[index]),
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* -----------------------  helpers UI  ----------------------- */

  PreferredSizeWidget _buildAppBar() => AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ecosphere forum',
              style: TextStyle(
                  color: Color(0xFF49447E),
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            Image.asset(
              'assets/images/People/WBG/person8.png',
              width: 60,
              height: 60,
            ),
          ],
        ),
      );

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Find topics',
              hintStyle: const TextStyle(color: Color(0xFF49447E)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF49447E)),
              filled: true,
              fillColor: const Color(0xFFEAEAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF49447E)),
            tooltip: 'Clasificar residuo por imagen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WasteClassifierScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagChips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Recycle', const Color(0xFFB9DCA8), const Color(0xFF64C533),
                Icons.recycling),
            _chip('Upcycle', const Color(0xFFA8B7DC), const Color(0xFF3D5CFF),
                Icons.compost),
            _chip('Transport', const Color(0xFFDCA8A8), const Color(0xFFD12E2E),
                Icons.directions_bike),
          ],
        ),
      );

  ChoiceChip _chip(String label, Color bg, Color sel, IconData icon) {
    final active = _selectedChip == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, color: Colors.white),
      selected: active,
      selectedColor: sel,
      backgroundColor: bg,
      showCheckmark: false,
      labelStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontFamily: 'Poppins'),
      onSelected: (s) => setState(() => _selectedChip = s ? label : null),
    );
  }

  // Microopt: cachea el filtro si no cambian los datos ni la búsqueda
  List<PostModel> _applySearchFilterCached(List<PostModel> posts) {
    if (_lastPosts == posts &&
        _lastQuery == _searchQuery &&
        _lastFiltered != null) {
      return _lastFiltered!;
    }
    final q = _searchQuery.toLowerCase();
    final filtered = posts.where((post) {
      final title = post.title.toLowerCase();
      final text = post.text.toLowerCase();
      return title.contains(q) || text.contains(q);
    }).toList();
    _lastPosts = posts;
    _lastQuery = _searchQuery;
    _lastFiltered = filtered;
    return filtered;
  }

  // Método auxiliar para obtener URL de la imagen
  String _getImageUrl(String assetId) {
    // Si ya es una URL completa, la devolvemos
    if (assetId.startsWith('http://') || assetId.startsWith('https://')) {
      return assetId;
    }

    // Si es un publicId de Cloudinary, construimos la URL
    try {
      final url = cloudinary
          .image(assetId)
          .transformation(Transformation()..resize(Resize.scale().width(800)))
          .toString();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error generando URL de Cloudinary: $e');
      }
      // Fallback: construir URL manualmente
      return 'https://res.cloudinary.com/$cloudName/image/upload/$assetId';
    }
  }

  /* ---------------- tarjeta individual ---------------- */

  Widget _postCard(PostModel post) {
    final tags = post.tags.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(post.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _tagRow(tags),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFFB8B8D2)),
                const SizedBox(width: 4),
                Text(post.user,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFFB8B8D2))),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.text, style: const TextStyle(fontSize: 13)),

            // Imagen con cache
            if (post.asset.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 350,
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(post.asset),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                UpvoteButton(
                  postId: post.id,
                  upvotes: post.upvotes,
                  upvotedBy: post.upvotedBy,
                ),
                const SizedBox(width: 16),
                CommentsButton(
                  postId: post.id,
                  commentsMap: post.comments,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Wrap _tagRow(String tags) {
    return Wrap(
      spacing: 4,
      children: tags.split(', ').map((t) {
        Color c;
        switch (t.toLowerCase()) {
          case 'recycle':
            c = const Color(0xFFB9DCA8);
            break;
          case 'upcycle':
            c = const Color(0xFFA8B7DC);
            break;
          case 'transport':
            c = const Color(0xFFDCA8A8);
            break;
          default:
            c = Colors.grey;
        }
        return Chip(
          label: Text(t,
              style: const TextStyle(fontSize: 10, fontFamily: 'Poppins')),
          backgroundColor: c,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
