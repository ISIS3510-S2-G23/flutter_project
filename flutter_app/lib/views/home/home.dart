import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Variable para el filtro de chips; si es null se muestran todos los posts
  String? _selectedChip;

  // Variable para el término de búsqueda
  String _searchQuery = '';

  // Función para manejar la selección de ítems en la barra de navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí podrías navegar a otras pantallas dependiendo del index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determina el stream de posts según el chip seleccionado.
    final postsStream = (_selectedChip != null)
        ? FirebaseFirestore.instance
            .collection('posts')
            .where('tags', arrayContains: _selectedChip)
            .snapshots()
        : FirebaseFirestore.instance.collection('posts').snapshots();

    return Scaffold(
      // ------------------ APP BAR PERSONALIZADO ------------------
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
            icon: const Icon(
              Icons.person,
              color: Color(0xFF49447E),
            ),
            onPressed: () {
              // Acción para ir al perfil o similar
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF49447E)),
      ),

      // ------------------ CUERPO PRINCIPAL ------------------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // BARRA DE BÚSQUEDA que actualiza _searchQuery en tiempo real
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
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

            // FILA DE CHIPS para filtrar por tag
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Recycle'),
                  _buildFilterChip('Upcycle'),
                  _buildFilterChip('Transport')
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LISTA DE POSTS utilizando Firestore y aplicando el filtro de búsqueda
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
                  // Filtramos los posts según el término de búsqueda
                  final allPosts = snapshot.data!.docs;
                  final filteredPosts = allPosts.where((doc) {
                    final postData = doc.data() as Map<String, dynamic>;
                    final title = postData['title']?.toString().toLowerCase() ?? '';
                    final text = postData['text']?.toString().toLowerCase() ?? '';
                    final searchLower = _searchQuery.toLowerCase();
                    return title.contains(searchLower) || text.contains(searchLower);
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return const Center(child: Text('No posts match your search'));
                  }

                  return ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final postData = filteredPosts[index].data() as Map<String, dynamic>;
                      final title = postData['title'] ?? '';
                      final user = postData['user'] ?? '';
                      final text = postData['text'] ?? '';
                      final tags = (postData['tags'] is List)
                          ? (postData['tags'] as List).join(', ')
                          : (postData['tags'] ?? '');
                      return _buildPostCard(title, user, tags, text);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // El bottomNavigationBar se implementa externamente.
    );
  }

  // Widget auxiliar para crear un Chip de filtro
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

  // Widget auxiliar para mostrar cada post en una tarjeta,
  // con el título alineado a la izquierda y los tags a la derecha.
  Widget _buildPostCard(String title, String user, String tags, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila con título a la izquierda y tags a la derecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (tags.toString().isNotEmpty)
                  Text(
                    tags.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Usuario que publicó
            Text(
              'by $user',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            // Texto del post
            Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
