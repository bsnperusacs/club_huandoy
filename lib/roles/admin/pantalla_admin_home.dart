// 📁 Ubicación: lib/roles/admin/pantallas/pantalla_admin_home.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaAdminHome extends StatelessWidget {
  const PantallaAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: _buildAdminDrawer(context),

      // ============================
      // 🔥 TARJETAS PRINCIPALES
      // ============================
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(18),
        childAspectRatio: 1.1,
        children: [
          _item(context, Icons.fitness_center, "Disciplinas", "/adminDisciplinas"),
          _item(context, Icons.person, "Entrenadores", "/adminEntrenadores"),
          _item(context, Icons.schedule, "Horarios", "/adminHorarios"),
          _item(context, Icons.groups, "Grupos", "/adminGrupos"),

          // ============================
          // 🟣 NUEVO MÓDULO: CONVENIOS
          // ============================
          _item(context, Icons.card_giftcard, "Convenios", "/adminConvenios"),
        ],
      ),
    );
  }

  // ============================================================
  // 📦 CREAR TARJETA DEL GRID
  // ============================================================
  Widget _item(BuildContext context, IconData icon, String titulo, String ruta) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ruta),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📂 MENÚ LATERAL (DRAWER)
  // ============================================================
  Drawer _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Administrador"),
            accountEmail: Text("admin@club.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.admin_panel_settings, size: 40),
            ),
            decoration: BoxDecoration(color: Colors.blueAccent),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Panel Principal"),
            onTap: () => Navigator.pushReplacementNamed(context, "/adminHome"),
          ),

          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text("Disciplinas"),
            onTap: () => Navigator.pushNamed(context, "/adminDisciplinas"),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Entrenadores"),
            onTap: () => Navigator.pushNamed(context, "/adminEntrenadores"),
          ),

          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Horarios"),
            onTap: () => Navigator.pushNamed(context, "/adminHorarios"),
          ),

          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text("Grupos"),
            onTap: () => Navigator.pushNamed(context, "/adminGrupos"),
          ),

          // ============================
          // 🟣 NUEVO: CONVENIOS
          // ============================
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text("Convenios"),
            onTap: () => Navigator.pushNamed(context, "/adminConvenios"),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
    );
  }
}
