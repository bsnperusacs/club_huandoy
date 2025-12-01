import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/controladores/grupo_controller.dart';
import 'package:club_huandoy/core/modelos/grupo_model.dart';
import 'package:club_huandoy/core/modelos/horario_model.dart';
import 'package:club_huandoy/core/modelos/entrenador_model.dart';
import '../../../../core/modelos/disciplina_model.dart';

import 'admin_crear_grupo.dart';

class AdminListaGrupos extends StatelessWidget {
  final _controller = GruposController();

  AdminListaGrupos({super.key});

  // ===============================
  Stream<List<DisciplinaModel>> _cargarDisciplinas() {
    return FirebaseFirestore.instance
        .collection("disciplinas")
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DisciplinaModel.fromFirestore(d)).toList());
  }

  Stream<List<HorarioModel>> _cargarHorarios() {
    return FirebaseFirestore.instance
        .collection("horarios")
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => HorarioModel.fromFirestore(d)).toList());
  }

  Stream<List<EntrenadorModel>> _cargarEntrenadores() {
    return FirebaseFirestore.instance
        .collection("entrenadores")
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EntrenadorModel.fromFirestore(d)).toList());
  }

  DisciplinaModel _disciplinaDesconocida() {
    return DisciplinaModel(
      id: "",
      nombre: "Desconocida",
      descripcion: "",
      activo: true,
      fechaCreacion: DateTime.now(),
      categorias: [],
      precios: {}, // NUEVO!!
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grupos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCrearGrupo()),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.listarGrupos(),
        builder: (context, snapGrupos) {
          if (snapGrupos.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapGrupos.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No hay grupos registrados"));
          }

          return StreamBuilder<List<DisciplinaModel>>(
            stream: _cargarDisciplinas(),
            builder: (context, snapDisciplinas) {
              if (!snapDisciplinas.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final disciplinas = snapDisciplinas.data!;

              return StreamBuilder<List<HorarioModel>>(
                stream: _cargarHorarios(),
                builder: (context, snapHorarios) {
                  if (!snapHorarios.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final horarios = snapHorarios.data!;

                  return StreamBuilder<List<EntrenadorModel>>(
                    stream: _cargarEntrenadores(),
                    builder: (context, snapEntrenadores) {
                      if (!snapEntrenadores.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final entrenadores = snapEntrenadores.data!;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final grupo = GrupoModel.fromFirestore(docs[i]);

                          // DISCIPLINA
                          final disciplina = disciplinas.firstWhere(
                            (d) => d.id == grupo.disciplinaId,
                            orElse: () => _disciplinaDesconocida(),
                          );

                          // HORARIO
                          final horario = horarios.firstWhere(
                            (h) => h.id == grupo.horarioId,
                            orElse: () => HorarioModel(
                              id: '',
                              disciplinaId: '',
                              dias: [],
                              horaInicio: '',
                              horaFin: '',
                              lugar: '',
                              activo: true,
                              fechaCreacion: DateTime.now(),
                            ),
                          );

                          final diasTexto =
                              horario.dias.isNotEmpty ? horario.dias.join(" - ") : "Sin días";

                          // ENTRENADOR
                          final entrenador = entrenadores.firstWhere(
                            (e) => e.id == grupo.entrenadorId,
                            orElse: () => EntrenadorModel(
                              id: '',
                              nombres: 'Desconocido',
                              apellidos: '',
                              telefono: '',
                              disciplinas: [],
                              activo: true,
                              fechaCreacion: DateTime.now(),
                            ),
                          );

                          final nombreEntrenador =
                              "${entrenador.nombres} ${entrenador.apellidos}".trim();

                          return Card(
                            child: ListTile(
                              title: Text(
                                "Categoría: ${grupo.categoria}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                "Cupo: ${grupo.inscritos}/${grupo.cupoMaximo}\n"
                                "Disciplina: ${disciplina.nombre}\n"
                                "Horario: ${horario.lugar} | $diasTexto | ${horario.horaInicio}-${horario.horaFin}\n"
                                "Entrenador: $nombreEntrenador",
                              ),

                              trailing: Switch(
                                value: grupo.activo,
                                onChanged: (v) async {
                                  if (v) {
                                    await _controller.activarGrupo(grupo.id);
                                  } else {
                                    await _controller.desactivarGrupo(grupo.id);
                                  }
                                },
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AdminCrearGrupo(grupoExistente: grupo),
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
              );
            },
          );
        },
      ),
    );
  }
}
