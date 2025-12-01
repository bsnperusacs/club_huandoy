// 📁 lib/roles/admin/pantallas/disciplinas/admin_lista_disciplinas.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/controladores/disciplina_controller.dart';
import '../../../../core/modelos/disciplina_model.dart';
import 'admin_crear_disciplina.dart';

class AdminListaDisciplinas extends StatelessWidget {
  final _controller = DisciplinasController();

  AdminListaDisciplinas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disciplinas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCrearDisciplina()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.listarDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No hay disciplinas registradas"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final disciplina =
                  DisciplinaModel.fromFirestore(docs[index]);

              return Card(
                child: ListTile(
                  title: Text(
                    disciplina.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(disciplina.descripcion),
                  trailing: Switch(
                    value: disciplina.activo,
                    onChanged: (value) async {
                      if (value == true) {
                        await _controller.activarDisciplina(disciplina.id);
                      } else {
                        await _controller.desactivarDisciplina(disciplina.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCrearDisciplina(
                          disciplinaExistente: disciplina,
                        ),
                      ),
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
