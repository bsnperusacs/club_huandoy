// 📁 lib/pantalla_inicio.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  Future<Map<String, dynamic>?> _cargarPerfil() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    return snap.data();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("No autenticado")),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _cargarPerfil(),
      builder: (context, snapshot) {
        final cargando = !snapshot.hasData;

        bool perfilIncompleto = true;
        String nombreMostrado = "Padre/Tutor";

        if (!cargando && snapshot.data != null) {
          final data = snapshot.data!;
          perfilIncompleto = !(data['registroCompleto'] == true);

          final nombres = data['nombres'] ?? "";
          final apellidos = data['apellidos'] ?? "";
          if ((nombres + apellidos).trim().isNotEmpty) {
            nombreMostrado = "$nombres $apellidos".trim();
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF1F7F3),

          appBar: AppBar(
            backgroundColor: const Color(0xFF0F8F51), // Verde institucional
            elevation: 0,
            title: const Text(
              'Club Deportivo Integral Huandoy',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.feedback, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/feedback'),
              )
            ],
          ),

          drawer: _buildDrawer(nombreMostrado, perfilIncompleto),

          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sports_soccer,
                        size: 90, color: Color(0xFF00C8FF)), // celeste institucional
                    SizedBox(height: 20),
                    Text(
                      'Bienvenido al sistema del club',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              if (!cargando && perfilIncompleto)
                _buildTarjetaPerfilIncompleto(context),
            ],
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(String nombreMostrado, bool perfilIncompleto) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0F8F51), // verde
            ),
            accountName: Text(
              nombreMostrado,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? "",
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.green),
            ),
          ),

          _drawerItem(
            icon: Icons.home,
            text: "Inicio",
            onTap: () => Navigator.pop(context),
          ),

          _drawerItem(
            icon: Icons.people_alt,
            text: "Estudiantes Registrados",
            onTap: () {
              if (perfilIncompleto) {
                _alerta(context);
              } else {
                Navigator.pushNamed(context, '/estudiantesRegistrados');
              }
            },
          ),

          _drawerItem(
            icon: Icons.school,
            text: "Matrícula",
            onTap: () {
              if (perfilIncompleto) {
                _alerta(context);
              } else {
                Navigator.pushNamed(context, '/matricula');
              }
            },
          ),

          _drawerItem(
            icon: Icons.event,
            text: "Eventos y Actividades",
            onTap: () => Navigator.pushNamed(context, '/eventos'),
          ),

          _drawerItem(
            icon: Icons.payment,
            text: "Pagos y Cuotas",
            onTap: () {
              if (perfilIncompleto) {
                _alerta(context);
              } else {
                Navigator.pushNamed(context, '/pagos');
              }
            },
          ),

          _drawerItem(
            icon: Icons.handshake,
            text: "Convenios",
            onTap: () => Navigator.pushNamed(context, '/convenios'),
          ),

          const Spacer(),

          _drawerItem(
            icon: Icons.logout,
            text: "Cerrar sesión",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildTarjetaPerfilIncompleto(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 4),
              color: Colors.black26,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tu registro está incompleto.\nCompleta tus datos ahora.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/registroPadre"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Completar"),
            )
          ],
        ),
      ),
    );
  }

  void _alerta(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Completa tu registro para acceder.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
