// 📁 lib/pantalla_inicio.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/widgets/menu_drawer.dart';

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

            drawer: MenuDrawer(
              nombreMostrado: nombreMostrado,
              perfilIncompleto: perfilIncompleto,
              onPerfilIncompleto: () => _alerta(context),
            ),

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
