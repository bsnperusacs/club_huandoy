// UBICACIÓN: lib/roles/padre/pantallas/estudiantes_registrados.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';

import 'pantalla_asignar_horario.dart';

class EstudiantesRegistrados extends StatefulWidget {
  const EstudiantesRegistrados({super.key});

  @override
  State<EstudiantesRegistrados> createState() => _EstudiantesRegistradosState();
}

class _EstudiantesRegistradosState extends State<EstudiantesRegistrados> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final carrito = Provider.of<CarritoAsignacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estudiantes Registrados"),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, "/carritoHorario");
                },
              ),

              // BADGE ROJO
              if (carrito.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      carrito.items.length.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          )
        ],
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

              final enCarrito = carrito.contieneEstudiante(est.id);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: est.fotoUrl.isNotEmpty
                        ? NetworkImage(est.fotoUrl)
                        : null,
                    child:
                        est.fotoUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),

                  title: Text(
                    "${est.nombre} ${est.apellido}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    est.estado == "registrado"
                        ? "Sin horario asignado"
                        : "Horario asignado",
                  ),

                  trailing: ElevatedButton(
                    onPressed: est.estado != "registrado"
                        ? null // YA ASIGNADO
                        : enCarrito
                            ? null // YA EN CARRITO
                            : () async {
                                final resultado = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PantallaAsignarHorario(
                                      estudiante: est,
                                    ),
                                  ),
                                );

                                if (resultado == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Asignación agregada al carrito"),
                                    ),
                                  );
                                  setState(() {});
                                }
                              },

                    child: Text(
                      est.estado != "registrado"
                          ? "ASIGNADO"
                          : enCarrito
                              ? "EN CARRITO"
                              : "ASIGNAR",
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
