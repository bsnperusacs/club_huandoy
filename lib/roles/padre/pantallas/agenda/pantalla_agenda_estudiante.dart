// 📁 Ubicación: lib/roles/padre/pantallas/agenda/pantalla_agenda_estudiante.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/modelos/estudiante_model.dart';
import '../asistencia/pantalla_marcar_asistencia.dart';

class PantallaAgendaEstudiante extends StatelessWidget {
  final Estudiante estudiante;

  const PantallaAgendaEstudiante({
    super.key,
    required this.estudiante,
  });

  @override
  Widget build(BuildContext context) {
    if (estudiante.horarioId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('El estudiante no tiene horario asignado'),
        ),
      );
    }

    final hoy = DateTime.now();
    final diaHoy = _nombreDia(hoy.weekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda / Horario'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('horarios')
            .doc(estudiante.horarioId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.data!.exists) {
            return const Center(child: Text('Horario no encontrado'));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final List dias = data['dias'] ?? [];
          final horaInicio = data['horaInicio'] ?? '';
          final horaFin = data['horaFin'] ?? '';
          final lugar = data['lugar'] ?? '';

          final esHoy = dias.contains(diaHoy);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ================= HOY =================
              _titulo('Hoy'),
              Card(
                child: ListTile(
                  title: Text(estudiante.grupoNombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🕒 $horaInicio - $horaFin'),
                      if (lugar.isNotEmpty) Text('📍 $lugar'),
                    ],
                  ),
                  trailing: esHoy
                      ? ElevatedButton(
                          child: const Text('Marcar asistencia'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PantallaMarcarAsistencia(
                                  estudianteId: estudiante.id,
                                  grupoId: estudiante.grupoId,
                                  // ⚠️ COORDENADAS REALES DEL CENTRO
                                  latCentro: -9.123456,
                                  lngCentro: -77.123456,
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No hay clase hoy'),
                ),
              ),

              const SizedBox(height: 24),

              // ================= PRÓXIMAS =================
              _titulo('Próximas clases'),
              ...dias.map((d) {
                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(estudiante.grupoNombre),
                  subtitle: Text('$d • $horaInicio - $horaFin'),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _nombreDia(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
