import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../services/auth_service.dart';

// Importa tu CustomNavBar (si está en otro archivo, por ejemplo: 
import 'CustomNavBar.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // String username = 'Usuario';

  // @override
  // void initState() {
  //   super.initState();
  //   _loadUsername();
  // }

  // // Carga el nombre de usuario de shared_preferences
  // void _loadUsername() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     username = prefs.getString('username') ?? 'Usuario';
  //   });
  // }

  // // Método para cerrar sesión
  // void _logout() async {
  //   await AuthService().signout(context: context);
  // }


  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Función para manejar la selección de ítems en la barra de navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí podrías navegar a otras pantallas dependiendo del index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ------------------ APP BAR PERSONALIZADO ------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Forum 1',
          style: TextStyle(
            color: const Color(0xFF49447E), // color #49447E
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
              // Acción para ir al perfil o algo similar
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

            // BARRA DE BÚSQUEDA
            TextField(
              controller: _searchController,
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

            // FILA DE CHIPS (scroll horizontal)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Recycling'),
                  _buildCategoryChip('Upcycling'),
                  _buildCategoryChip('Transport'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LISTA DE POSTS (ejemplo)
            Expanded(
              child: ListView(
                children: const [
                  // Tus PostCards...
                ],
              ),
            ),
          ],
        ),
      ),

      // ------------------ BARRA DE NAVEGACIÓN INFERIOR REUTILIZABLE ------------------
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // ------------------ WIDGET AUXILIAR PARA LOS CHIPS ------------------
  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}
