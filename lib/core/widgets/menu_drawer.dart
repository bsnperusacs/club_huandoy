import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuDrawer extends StatelessWidget {
  final String nombreMostrado;
  final bool perfilIncompleto;
  final VoidCallback onPerfilIncompleto;

  const MenuDrawer({
    super.key,
    required this.nombreMostrado,
    required this.perfilIncompleto,
    required this.onPerfilIncompleto,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _header(),

          _item(
            context,
            icon: Icons.home,
            text: "Inicio",
            onTap: () => Navigator.pop(context),
          ),

          _grupo(
            icon: Icons.school,
            text: "Estudiantes",
            children: [
              _subItem(
                context,
                icon: Icons.person_add,
                text: "Matricular",
                onTap: () => _go(context, '/matricula'),
              ),
              _subItem(
                context,
                icon: Icons.schedule,
                text: "Asignar horario",
                onTap: () => _go(context, '/estudiantesRegistrados'),
              ),
              _subItem(
                context,
                icon: Icons.person,
                text: "Perfil del estudiante",
                onTap: () => _go(context, '/perfilEstudiante'),
              ),
            ],
          ),

          _item(
            context,
            icon: Icons.emoji_events,
            text: "Torneos",
            onTap: () => _go(context, '/torneos'),
          ),

          _grupo(
            icon: Icons.history,
            text: "Historial",
            children: [
              _subItem(
                context,
                icon: Icons.payment,
                text: "Pagos",
                onTap: () => _go(context, '/historialPagos'),
              ),
              _subItem(
                context,
                icon: Icons.shopping_bag,
                text: "Compras",
                onTap: () => _go(context, '/historialCompras'),
              ),
              _subItem(
                context,
                icon: Icons.check_circle,
                text: "Asistencia",
                onTap: () => _go(context, '/asistencia'),
              ),
            ],
          ),

          _item(
            context,
            icon: Icons.store,
            text: "Tienda del Club",
            onTap: () => _go(context, '/tiendaClub'),
          ),

          _item(
            context,
            icon: Icons.support_agent,
            text: "Soporte y Ayuda",
            onTap: () => _go(context, '/soporte'),
          ),

          const Spacer(),

          _item(
            context,
            icon: Icons.logout,
            text: "Cerrar sesión",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // ======================
  // HELPERS
  // ======================

  Widget _header() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Color(0xFF0F8F51)),
      accountName: Text(nombreMostrado),
      accountEmail:
          Text(FirebaseAuth.instance.currentUser?.email ?? ""),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.green),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      // 🔒 Mantiene bloqueo SOLO en items grandes si el perfil está incompleto
      onTap: perfilIncompleto ? onPerfilIncompleto : onTap,
    );
  }

  Widget _grupo({
    required IconData icon,
    required String text,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: children,
    );
  }

  Widget _subItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40),
      leading: Icon(icon, size: 20),
      title: Text(text),
      // ✅ SIN BLOQUEO: los subitems SIEMPRE navegan
      onTap: onTap,
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context); // cierra drawer
    Navigator.pushNamed(context, route);
  }
}
