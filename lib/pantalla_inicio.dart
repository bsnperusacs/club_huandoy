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
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("No autenticado")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('padres')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool perfilIncompleto = true;
        String nombreMostrado = "Padre/Tutor";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          perfilIncompleto = !(data['registroCompleto'] == true);

          final nombres = data['nombres'] ?? "";
          final apellidos = data['apellidos'] ?? "";
          if ((nombres + apellidos).trim().isNotEmpty) {
            nombreMostrado = "$nombres $apellidos".trim();
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Club Deportivo Integral Huandoy'),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.feedback, color: Colors.red, size: 30),
                tooltip: 'Enviar feedback',
                onPressed: () {
                  // 🔥 ABRIR FORMULARIO DE FEEDBACK
                  Navigator.pushNamed(context, '/feedback');
                },
              ),
            ],
          ),

          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    nombreMostrado,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
                  ),
                  decoration: const BoxDecoration(color: Colors.blueAccent),
                ),

                // INICIO
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  onTap: () => Navigator.pop(context),
                ),

                // 🔥 NUEVO — ESTUDIANTES REGISTRADOS
                ListTile(
                  leading: const Icon(Icons.people_alt),
                  title: const Text('Estudiantes Registrados'),
                  onTap: () {
                    if (perfilIncompleto) {
                      _alerta(context);
                    } else {
                      Navigator.pushNamed(context, '/estudiantesRegistrados');
                    }
                  },
                ),

                // MATRÍCULA
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Matrícula'),
                  onTap: () {
                    if (perfilIncompleto) {
                      _alerta(context);
                    } else {
                      Navigator.pushNamed(context, '/matricula');
                    }
                  },
                ),

                // EVENTOS
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Eventos y Actividades'),
                  onTap: () => Navigator.pushNamed(context, '/eventos'),
                ),

                // PAGOS
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Pagos y Cuotas'),
                  onTap: () {
                    if (perfilIncompleto) {
                      _alerta(context);
                    } else {
                      Navigator.pushNamed(context, '/pagos');
                    }
                  },
                ),

                // CONVENIOS
                ListTile(
                  leading: const Icon(Icons.handshake),
                  title: const Text('Convenios'),
                  onTap: () => Navigator.pushNamed(context, '/convenios'),
                ),

                const Divider(),

                ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
              ],
            ),
          ),

          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sports_soccer, size: 80, color: Colors.blueAccent),
                    SizedBox(height: 20),
                    Text(
                      'Bienvenido al sistema del club',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              if (perfilIncompleto)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    color: Colors.orange.shade100,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 28,
                          ),
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
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/registroPadre'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Completar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
