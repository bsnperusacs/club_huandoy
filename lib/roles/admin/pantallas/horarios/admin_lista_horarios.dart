// 📁 lib/roles/admin/pantallas/horarios/admin_lista_horarios.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/controladores/horario_controller.dart';
import '../../../../core/modelos/horario_model.dart';
import 'admin_crear_horario.dart';

class AdminListaHorarios extends StatelessWidget {
  final _controller = HorariosController();

  AdminListaHorarios({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Horarios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminCrearHorario(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.listarHorarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No hay horarios registrados"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final horario = HorarioModel.fromFirestore(docs[i]);

              return Card(
                child: ListTile(
                  title: Text("${horario.horaInicio} - ${horario.horaFin}"),
                  subtitle: Text(
                    "${horario.dias.join(", ")}\nLugar: ${horario.lugar}",
                  ),
                  trailing: Switch(
                    value: horario.activo,
                    onChanged: (v) async {
                      if (v) {
                        await _controller.activarHorario(horario.id);
                      } else {
                        await _controller.desactivarHorario(horario.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCrearHorario(
                          horarioExistente: horario,
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
