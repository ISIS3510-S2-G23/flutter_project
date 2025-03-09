import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.home, // Reemplaza con tu ícono 'family_home' si lo tienes
            iconSize: 22,     // 22px de ancho aprox
            label: 'Home',
          ),

          // Points
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.location_on,
            iconSize: 24,
            label: 'Points',
          ),

          // Add post (botón especial en el medio)
          _buildAddPostItem(context),

          // Notifications
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.notifications,
            iconSize: 20,
            label: 'Notifications',
          ),

          // Account
          _buildNavItem(
            context,
            index: 4,
            icon: Icons.account_circle,
            iconSize: 24, // ~24.5 px
            label: 'Account',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ITEM DE NAVEGACIÓN NORMAL
  // -------------------------------------------------------
  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required double iconSize,
    required String label,
  }) {
    bool isSelected = (selectedIndex == index);
    // Color de ícono y texto según si está seleccionado o no
    Color color = isSelected
        ? const Color(0xFF49447E) // seleccionado
        : const Color(0xFF7D84B2); // no seleccionado

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: 60, // Ajusta según tu diseño
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // BOTÓN ESPECIAL PARA "ADD POST"
  // -------------------------------------------------------
  Widget _buildAddPostItem(BuildContext context) {
    return GestureDetector(
      onTap: () => onItemTapped(2),
      child: SizedBox(
        width: 60, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.add, // Reemplaza con tu ícono 'add_2' si lo tienes
                  size: 18,  // 18px x 18px
                  color: Color(0xFF49447E),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add post',
              style: TextStyle(
                fontSize: 14, // tamano 14 para el texto y evitar overflow
                color: Color(0xFF49447E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
