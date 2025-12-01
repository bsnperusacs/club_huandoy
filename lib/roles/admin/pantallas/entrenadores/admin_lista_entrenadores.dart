// 📁 lib/roles/admin/pantallas/entrenadores/admin_lista_entrenadores.dart

import 'package:club_huandoy/core/modelos/entrenador_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/controladores/entrenador_controller.dart';
import '../../../../core/modelos/disciplina_model.dart';
import 'admin_crear_entrenador.dart';

class AdminListaEntrenadores extends StatelessWidget {
  final _controller = EntrenadoresController();

  AdminListaEntrenadores({super.key});

  // =============================
  // 🔍 OBTENER DISCIPLINAS
  // =============================
  Stream<List<DisciplinaModel>> _cargarDisciplinas() {
    return FirebaseFirestore.instance
        .collection("disciplinas")
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DisciplinaModel.fromFirestore(d)).toList());
  }

  DisciplinaModel _disciplinaDesconocida() {
    return DisciplinaModel(
      id: "",
      nombre: "Desconocida",
      descripcion: "",
      activo: true,
      fechaCreacion: DateTime.now(),
      categorias: [],
      precios: {}, // ← IMPORTANTE
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrenadores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCrearEntrenador()),
              );
            },
          )
        ],
      ),

      // =============================
      //   🔥 STREAM PRINCIPAL
      // =============================
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.listarEntrenadores(),
        builder: (context, snapEntrenadores) {
          if (snapEntrenadores.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entrenadoresDocs = snapEntrenadores.data?.docs ?? [];

          if (entrenadoresDocs.isEmpty) {
            return const Center(child: Text("No hay entrenadores registrados"));
          }

          return StreamBuilder<List<DisciplinaModel>>(
            stream: _cargarDisciplinas(),
            builder: (context, snapDisciplinas) {
              if (!snapDisciplinas.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final listaDisciplinas = snapDisciplinas.data!;

              return ListView.builder(
                itemCount: entrenadoresDocs.length,
                itemBuilder: (_, index) {
                  final entrenador =
                      EntrenadorModel.fromFirestore(entrenadoresDocs[index]);

                  // ===========================================
                  //  🔧 IDs → Nombres
                  // ===========================================
                  final nombresDisciplinas =
                      entrenador.disciplinas.map((idDisciplina) {
                    final disc = listaDisciplinas.firstWhere(
                      (d) => d.id == idDisciplina,
                      orElse: () => _disciplinaDesconocida(),
                    );
                    return disc.nombre;
                  }).toList();

                  return Card(
                    child: ListTile(
                      title: Text(
                        "${entrenador.nombres} ${entrenador.apellidos}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Teléfono: ${entrenador.telefono}"),
                          const SizedBox(height: 4),
                          Text(
                            "Disciplinas: ${nombresDisciplinas.join(', ')}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey),
                          ),
                        ],
                      ),

                      trailing: Switch(
                        value: entrenador.activo,
                        onChanged: (valor) async {
                          if (valor) {
                            await _controller.activarEntrenador(entrenador.id);
                          } else {
                            await _controller.desactivarEntrenador(entrenador.id);
                          }
                        },
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminCrearEntrenador(
                              entrenadorExistente: entrenador,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
