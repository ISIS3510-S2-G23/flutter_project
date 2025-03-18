// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class Home extends StatefulWidget {
// // //   const Home({Key? key}) : super(key: key);

// // //   @override
// // //   State<Home> createState() => _HomeState();
// // // }

// // // class _HomeState extends State<Home> {
// // //   int _selectedIndex = 0;
// // //   final TextEditingController _searchController = TextEditingController();

// // //   // Variable para el filtro de chips; si es null se muestran todos los posts
// // //   String? _selectedChip;

// // //   // Variable para el término de búsqueda
// // //   String _searchQuery = '';

// // //   // Función para manejar la selección de ítems en la barra de navegación
// // //   void _onItemTapped(int index) {
// // //     setState(() {
// // //       _selectedIndex = index;
// // //       // Aquí podrías navegar a otras pantallas dependiendo del index
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Determina el stream de posts según el chip seleccionado.
// // //     final postsStream = (_selectedChip != null)
// // //         ? FirebaseFirestore.instance
// // //             .collection('posts')
// // //             .where('tags', arrayContains: _selectedChip)
// // //             .snapshots()
// // //         : FirebaseFirestore.instance.collection('posts').snapshots();

// // //     return Scaffold(
// // //       // ------------------ APP BAR PERSONALIZADO ------------------
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         centerTitle: true,
// // //         title: const Text(
// // //           'Forum 1',
// // //           style: TextStyle(
// // //             color: Color(0xFF49447E),
// // //             fontSize: 20,
// // //             fontWeight: FontWeight.bold,
// // //           ),
// // //         ),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(
// // //               Icons.person,
// // //               color: Color(0xFF49447E),
// // //             ),
// // //             onPressed: () {
// // //               // Acción para ir al perfil o similar
// // //             },
// // //           ),
// // //         ],
// // //         iconTheme: const IconThemeData(color: Color(0xFF49447E)),
// // //       ),

// // //       // ------------------ CUERPO PRINCIPAL ------------------
// // //       body: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
// // //         child: Column(
// // //           children: [
// // //             const SizedBox(height: 16),

// // //             // BARRA DE BÚSQUEDA que actualiza _searchQuery en tiempo real
// // //             TextField(
// // //               controller: _searchController,
// // //               onChanged: (value) {
// // //                 setState(() {
// // //                   _searchQuery = value;
// // //                 });
// // //               },
// // //               decoration: InputDecoration(
// // //                 hintText: 'Find topics',
// // //                 hintStyle: const TextStyle(color: Color(0xFF49447E)),
// // //                 prefixIcon: const Icon(Icons.search, color: Color(0xFF49447E)),
// // //                 contentPadding: const EdgeInsets.all(12),
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(24),
// // //                   borderSide: BorderSide.none,
// // //                 ),
// // //                 filled: true,
// // //                 fillColor: const Color(0xFFEAEAFF),
// // //               ),
// // //             ),

// // //             const SizedBox(height: 16),

// // //             // FILA DE CHIPS para filtrar por tag
// // //             SingleChildScrollView(
// // //               scrollDirection: Axis.horizontal,
// // //               child: Row(
// // //                 children: [
// // //                   _buildFilterChip('Recycle'),
// // //                   _buildFilterChip('Upcycle'),
// // //                   _buildFilterChip('Transport')
// // //                 ],
// // //               ),
// // //             ),

// // //             const SizedBox(height: 16),

// // //             // LISTA DE POSTS utilizando Firestore y aplicando el filtro de búsqueda
// // //             Expanded(
// // //               child: StreamBuilder<QuerySnapshot>(
// // //                 stream: postsStream,
// // //                 builder: (context, snapshot) {
// // //                   if (snapshot.hasError) {
// // //                     return Center(child: Text('Error: ${snapshot.error}'));
// // //                   }
// // //                   if (snapshot.connectionState == ConnectionState.waiting) {
// // //                     return const Center(child: CircularProgressIndicator());
// // //                   }
// // //                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //                     return const Center(child: Text('No posts found'));
// // //                   }
// // //                   // Filtramos los posts según el término de búsqueda
// // //                   final allPosts = snapshot.data!.docs;
// // //                   final filteredPosts = allPosts.where((doc) {
// // //                     final postData = doc.data() as Map<String, dynamic>;
// // //                     final title = postData['title']?.toString().toLowerCase() ?? '';
// // //                     final text = postData['text']?.toString().toLowerCase() ?? '';
// // //                     final searchLower = _searchQuery.toLowerCase();
// // //                     return title.contains(searchLower) || text.contains(searchLower);
// // //                   }).toList();

// // //                   if (filteredPosts.isEmpty) {
// // //                     return const Center(child: Text('No posts match your search'));
// // //                   }

// // //                   return ListView.builder(
// // //                     itemCount: filteredPosts.length,
// // //                     itemBuilder: (context, index) {
// // //                       final postData = filteredPosts[index].data() as Map<String, dynamic>;
// // //                       final title = postData['title'] ?? '';
// // //                       final user = postData['user'] ?? '';
// // //                       final text = postData['text'] ?? '';
// // //                       final tags = (postData['tags'] is List)
// // //                           ? (postData['tags'] as List).join(', ')
// // //                           : (postData['tags'] ?? '');
// // //                       return _buildPostCard(title, user, tags, text);
// // //                     },
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //       // El bottomNavigationBar se implementa externamente.
// // //     );
// // //   }

// // //   // Widget auxiliar para crear un Chip de filtro
// // //   Widget _buildFilterChip(String label) {
// // //     final isSelected = _selectedChip == label;
// // //     return Padding(
// // //       padding: const EdgeInsets.only(right: 8.0),
// // //       child: ChoiceChip(
// // //         label: Text(label),
// // //         selected: isSelected,
// // //         selectedColor: const Color(0xFF49447E),
// // //         backgroundColor: Colors.grey.shade200,
// // //         labelStyle: TextStyle(
// // //           color: isSelected ? Colors.white : const Color(0xFF49447E),
// // //           fontSize: 14,
// // //         ),
// // //         onSelected: (selected) {
// // //           setState(() {
// // //             _selectedChip = selected ? label : null;
// // //           });
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // Widget auxiliar para mostrar cada post en una tarjeta,
// // //   // con el título alineado a la izquierda y los tags a la derecha.
// // //   Widget _buildPostCard(String title, String user, String tags, String text) {
// // //     return Card(
// // //       margin: const EdgeInsets.only(bottom: 16),
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(12),
// // //       ),
// // //       elevation: 2,
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             // Fila con título a la izquierda y tags a la derecha
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Text(
// // //                     title,
// // //                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                   ),
// // //                 ),
// // //                 if (tags.toString().isNotEmpty)
// // //                   Text(
// // //                     tags.toString(),
// // //                     style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
// // //                   ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 4),
// // //             // Usuario que publicó
// // //             Text(
// // //               'by $user',
// // //               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
// // //             ),
// // //             const SizedBox(height: 8),
// // //             // Texto del post
// // //             Text(
// // //               text,
// // //               style: const TextStyle(fontSize: 14),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:cloudinary_url_gen/cloudinary.dart';
// // import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
// // import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
// // import 'package:cloudinary_url_gen/transformation/transformation.dart';
// // import 'package:cloudinary_flutter/image/cld_image.dart';
// // import 'package:cloudinary_flutter/cloudinary_context.dart';
// // import 'upvote_button.dart';

// // class Home extends StatefulWidget {
// //   const Home({Key? key}) : super(key: key);

// //   @override
// //   State<Home> createState() => _HomeState();
// // }

// // class _HomeState extends State<Home> {
// //   int _selectedIndex = 0;
// //   final TextEditingController _searchController = TextEditingController();

// //   // Variable para el filtro de chips; si es null se muestran todos los posts
// //   String? _selectedChip;

// //   // Variable para el término de búsqueda
// //   String _searchQuery = '';

// //   // Función para manejar la selección de ítems en la barra de navegación
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //       // Aquí podrías navegar a otras pantallas dependiendo del index
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Determina el stream de posts según el chip seleccionado.
// //     final postsStream = (_selectedChip != null)
// //         ? FirebaseFirestore.instance
// //             .collection('posts')
// //             .where('tags', arrayContains: _selectedChip)
// //             .snapshots()
// //         : FirebaseFirestore.instance.collection('posts').snapshots();

// //     return Scaffold(
// //       // ------------------ APP BAR PERSONALIZADO ------------------
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         title: const Text(
// //           'Forum 1',
// //           style: TextStyle(
// //             color: Color(0xFF49447E),
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(
// //               Icons.person,
// //               color: Color(0xFF49447E),
// //             ),
// //             onPressed: () {
// //               // Acción para ir al perfil o similar
// //             },
// //           ),
// //         ],
// //         iconTheme: const IconThemeData(color: Color(0xFF49447E)),
// //       ),

// //       // ------------------ CUERPO PRINCIPAL ------------------
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 16),

// //             // BARRA DE BÚSQUEDA que actualiza _searchQuery en tiempo real
// //             TextField(
// //               controller: _searchController,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _searchQuery = value;
// //                 });
// //               },
// //               decoration: InputDecoration(
// //                 hintText: 'Find topics',
// //                 hintStyle: const TextStyle(color: Color(0xFF49447E)),
// //                 prefixIcon: const Icon(Icons.search, color: Color(0xFF49447E)),
// //                 contentPadding: const EdgeInsets.all(12),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(24),
// //                   borderSide: BorderSide.none,
// //                 ),
// //                 filled: true,
// //                 fillColor: const Color(0xFFEAEAFF),
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             // FILA DE CHIPS para filtrar por tag
// //             SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Row(
// //                 children: [
// //                   _buildFilterChip('Recycle'),
// //                   _buildFilterChip('Upcycle'),
// //                   _buildFilterChip('Transport')
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             // LISTA DE POSTS utilizando Firestore y aplicando el filtro de búsqueda
// //             Expanded(
// //               child: StreamBuilder<QuerySnapshot>(
// //                 stream: postsStream,
// //                 builder: (context, snapshot) {
// //                   if (snapshot.hasError) {
// //                     return Center(child: Text('Error: ${snapshot.error}'));
// //                   }
// //                   if (snapshot.connectionState == ConnectionState.waiting) {
// //                     return const Center(child: CircularProgressIndicator());
// //                   }
// //                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                     return const Center(child: Text('No posts found'));
// //                   }

// //                   // Filtramos los posts según el término de búsqueda
// //                   final allPosts = snapshot.data!.docs;
// //                   final filteredPosts = allPosts.where((doc) {
// //                     final postData = doc.data() as Map<String, dynamic>;
// //                     final title = postData['title']?.toString().toLowerCase() ?? '';
// //                     final text = postData['text']?.toString().toLowerCase() ?? '';
// //                     final searchLower = _searchQuery.toLowerCase();
// //                     return title.contains(searchLower) || text.contains(searchLower);
// //                   }).toList();

// //                   if (filteredPosts.isEmpty) {
// //                     return const Center(child: Text('No posts match your search'));
// //                   }

// //                   return ListView.builder(
// //                     itemCount: filteredPosts.length,
// //                     itemBuilder: (context, index) {
// //                       final postData = filteredPosts[index].data() as Map<String, dynamic>;

// //                       final title = postData['title'] ?? '';
// //                       final user = postData['user'] ?? '';
// //                       final text = postData['text'] ?? '';
// //                       final tags = (postData['tags'] is List)
// //                           ? (postData['tags'] as List).join(', ')
// //                           : (postData['tags'] ?? '');

// //                       // <-- Recuperamos el campo asset para la imagen
// //                       final asset = postData['asset'] ?? '';

// //                       return _buildPostCard(title, user, tags, text, asset);
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       // El bottomNavigationBar se implementa externamente.
// //     );
// //   }

// //   // Widget auxiliar para crear un Chip de filtro
// //   Widget _buildFilterChip(String label) {
// //     final isSelected = _selectedChip == label;
// //     return Padding(
// //       padding: const EdgeInsets.only(right: 8.0),
// //       child: ChoiceChip(
// //         label: Text(label),
// //         selected: isSelected,
// //         selectedColor: const Color(0xFF49447E),
// //         backgroundColor: Colors.grey.shade200,
// //         labelStyle: TextStyle(
// //           color: isSelected ? Colors.white : const Color(0xFF49447E),
// //           fontSize: 14,
// //         ),
// //         onSelected: (selected) {
// //           setState(() {
// //             _selectedChip = selected ? label : null;
// //           });
// //         },
// //       ),
// //     );
// //   }

// //   // Widget auxiliar para mostrar cada post en una tarjeta,
// //   // con el título alineado a la izquierda, los tags a la derecha y la imagen (asset) arriba o abajo.
// //   Widget _buildPostCard(String title, String user, String tags, String text, String asset) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       elevation: 2,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Fila con título a la izquierda y tags a la derecha
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     title,
// //                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //                 if (tags.toString().isNotEmpty)
// //                   Text(
// //                     tags.toString(),
// //                     style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
// //                   ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             // Usuario que publicó
// //             Text(
// //               'by $user',
// //               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
// //             ),
// //             const SizedBox(height: 8),
// //             // Texto del post
// //             Text(
// //               text,
// //               style: const TextStyle(fontSize: 14),
// //             ),
// //             // Si el campo asset no está vacío, mostramos la imagen
// //             if (asset.isNotEmpty) ...[
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 180,
// //                 child: CldImageWidget(
// //                   // Usa el campo asset como publicId (o URL) de Cloudinary
// //                   publicId: asset,
// //                   transformation: Transformation()
// //                     ..resize(Resize.fill()
// //                       ..width(250)
// //                       ..height(250))
// //                     ..effect(Effect.sepia()),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Importa tu archivo con el widget UpvoteButton
// import 'upvote_button.dart';

// // Librerías de Cloudinary si las necesitas:
// import 'package:cloudinary_url_gen/cloudinary.dart';
// import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
// import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
// import 'package:cloudinary_url_gen/transformation/transformation.dart';
// import 'package:cloudinary_flutter/image/cld_image.dart';
// import 'package:cloudinary_flutter/cloudinary_context.dart';

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   int _selectedIndex = 0;
//   final TextEditingController _searchController = TextEditingController();

//   // Filtro de chips; si es null se muestran todos los posts
//   String? _selectedChip;

//   // Búsqueda local
//   String _searchQuery = '';

//   // Maneja la selección de ítems en el BottomNav (si lo usas)
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // Aquí podrías navegar a otras pantallas...
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Stream según el chip seleccionado
//     final postsStream = (_selectedChip != null)
//         ? FirebaseFirestore.instance
//             .collection('posts')
//             .where('tags', arrayContains: _selectedChip)
//             .snapshots()
//         : FirebaseFirestore.instance.collection('posts').snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Forum 1',
//           style: TextStyle(
//             color: Color(0xFF49447E),
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person, color: Color(0xFF49447E)),
//             onPressed: () {
//               // Acción para ir al perfil o algo similar
//             },
//           ),
//         ],
//         iconTheme: const IconThemeData(color: Color(0xFF49447E)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 16),

//             // ------------------ BARRA DE BÚSQUEDA ------------------
//             TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() => _searchQuery = value);
//               },
//               decoration: InputDecoration(
//                 hintText: 'Find topics',
//                 hintStyle: const TextStyle(color: Color(0xFF49447E)),
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF49447E)),
//                 contentPadding: const EdgeInsets.all(12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFEAEAFF),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ------------------ FILA DE CHIPS ------------------
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterChip('Recycle'),
//                   _buildFilterChip('Upcycle'),
//                   _buildFilterChip('Transport'),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ------------------ LISTA DE POSTS ------------------
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: postsStream,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('No posts found'));
//                   }

//                   // Filtramos por búsqueda local
//                   final allPosts = snapshot.data!.docs;
//                   final filteredPosts = allPosts.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final title = data['title']?.toString().toLowerCase() ?? '';
//                     final text = data['text']?.toString().toLowerCase() ?? '';
//                     final searchLower = _searchQuery.toLowerCase();
//                     return title.contains(searchLower) || text.contains(searchLower);
//                   }).toList();

//                   if (filteredPosts.isEmpty) {
//                     return const Center(child: Text('No posts match your search'));
//                   }

//                   return ListView.builder(
//                     itemCount: filteredPosts.length,
//                     itemBuilder: (context, index) {
//                       final doc = filteredPosts[index];
//                       final data = doc.data() as Map<String, dynamic>;

//                       final title = data['title'] ?? '';
//                       final user = data['user'] ?? '';
//                       final text = data['text'] ?? '';

//                       // tags como List => string
//                       final tags = (data['tags'] is List)
//                           ? (data['tags'] as List).join(', ')
//                           : (data['tags'] ?? '');

//                       // upvotes (int) y upvotedBy (List)
//                       final upvotes = data['upvotes'] is int ? data['upvotes'] as int : 0;
//                       final upvotedBy = data['upvotedBy'] is List ? data['upvotedBy'] as List : [];

//                       // asset para la imagen (Cloudinary)
//                       final asset = data['asset'] ?? '';

//                       return _buildPostCard(
//                         postId: doc.id,
//                         title: title,
//                         user: user,
//                         text: text,
//                         tags: tags,
//                         asset: asset,
//                         upvotes: upvotes,
//                         upvotedBy: upvotedBy,
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------ CHIPS ------------------
//   Widget _buildFilterChip(String label) {
//     final isSelected = _selectedChip == label;
//     return Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: isSelected,
//         selectedColor: const Color(0xFF49447E),
//         backgroundColor: Colors.grey.shade200,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : const Color(0xFF49447E),
//           fontSize: 14,
//         ),
//         onSelected: (selected) {
//           setState(() {
//             _selectedChip = selected ? label : null;
//           });
//         },
//       ),
//     );
//   }

//   // ------------------ CREAR TARJETA DE POST ------------------
//   Widget _buildPostCard({
//     required String postId,
//     required String title,
//     required String user,
//     required String text,
//     required String tags,
//     required String asset,
//     required int upvotes,
//     required List upvotedBy,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Fila con título a la izq y tags a la der
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 if (tags.isNotEmpty)
//                   Text(
//                     tags,
//                     style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             // Usuario
//             Text(
//               'by $user',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 8),

//             // Texto
//             Text(text, style: const TextStyle(fontSize: 14)),
//             const SizedBox(height: 8),

//             // Imagen (Cloudinary) si 'asset' no está vacío
//             if (asset.isNotEmpty) ...[
//               SizedBox(
//                 width: double.infinity,
//                 height: 180,
//                 child: CldImageWidget(
//                   publicId: asset,
//                   transformation: Transformation()
//                     ..resize(Resize.fill()
//                       ..width(250)
//                       ..height(250))
//                     ..effect(Effect.sepia()), // Ajusta si deseas
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],

//             // Fila con el UpvoteButton
//             Row(
//               children: [
//                 // UpvoteButton importado
//                 UpvoteButton(
//                   postId: postId,
//                   upvotes: upvotes,
//                   upvotedBy: upvotedBy,
//                 ),
//                 // ... Si en un futuro agregas CommentsButton, lo colocarías aquí ...
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa los widgets UpvoteButton y CommentsButton
import 'upvote_button.dart';
import 'comments_button.dart';

// Si usas librerías de Cloudinary, las importas aquí
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Filtro de chips; si es null se muestran todos los posts
  String? _selectedChip;

  // Búsqueda local
  String _searchQuery = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí podrías navegar a otras pantallas
    });
  }

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

