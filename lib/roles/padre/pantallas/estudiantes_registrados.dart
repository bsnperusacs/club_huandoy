import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/modelos/estudiante_model.dart';
import 'pantalla_asignar_horario.dart'; // 👈 IMPORT CORRECTO

class EstudiantesRegistrados extends StatefulWidget {
  const EstudiantesRegistrados({super.key});

  @override
  State<EstudiantesRegistrados> createState() =>
      _EstudiantesRegistradosState();
}

class _EstudiantesRegistradosState extends State<EstudiantesRegistrados> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estudiantes Registrados"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("estudiantes")
            .where("padreId", isEqualTo: uid)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No tienes estudiantes registrados"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final est = Estudiante.fromMap(
                docs[i].data() as Map<String, dynamic>,
                docs[i].id,
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  // 🔵 FOTO DEL ESTUDIANTE
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        est.fotoUrl.isNotEmpty ? NetworkImage(est.fotoUrl) : null,
                    child: est.fotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),

                  // 🔵 NOMBRE
                  title: Text(
                    "${est.nombre} ${est.apellido}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // 🔵 ESTADO
                  subtitle: Text(
                    est.estado == "registrado"
                        ? "Estado: Registrado"
                        : est.estado == "asignado"
                            ? "Estado: Asignado\nGrupo: ${est.grupoId}"
                            : "Estado: Pagado",
                  ),

                  // 🔵 BOTÓN ASIGNAR / CAMBIAR
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final asignado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AsignarHorario(estudiante: est),
                        ),
                      );

                      // 👇 SI LA ASIGNACIÓN FUE EXITOSA
                      if (asignado == true) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Horario asignado correctamente"),
                            ),
                          );
                        }
                        setState(() {});
                      }
                    },
                    child: Text(
                      est.estado == "registrado" ? "ASIGNAR" : "CAMBIAR",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
