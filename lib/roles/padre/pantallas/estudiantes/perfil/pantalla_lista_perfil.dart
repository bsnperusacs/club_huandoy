import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:club_huandoy/core/modelos/estudiante_model.dart';

class PantallaListaPerfil extends StatelessWidget {
  const PantallaListaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final String padreId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de estudiantes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('estudiantes')
            .where('padreId', isEqualTo: padreId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No tienes estudiantes registrados',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final estudiantes = snapshot.data!.docs.map((doc) {
            return Estudiante.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id, // DNI
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: estudiantes.length,
            itemBuilder: (context, index) {
              final e = estudiantes[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        e.fotoUrl.isNotEmpty ? NetworkImage(e.fotoUrl) : null,
                    child: e.fotoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text('${e.nombre} ${e.apellido}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DNI: ${e.dni}'),
                      const SizedBox(height: 4),
                    e.disciplinaId.isNotEmpty
                        ? FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('disciplinas')
                                .doc(e.disciplinaId)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text('Disciplina: No asignada');
                              }

                              final data = snapshot.data!.data() as Map<String, dynamic>;
                              final nombre = data['nombre'] ?? 'Sin nombre';

                              return Text('Disciplina: $nombre');
                            },
                          )
                        : const Text('Disciplina: No asignada'),

                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      e.activo ? 'Activo' : 'Inactivo',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        e.activo ? Colors.green : Colors.red,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/perfilEstudiante',
                      arguments: e.id, // DNI
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
