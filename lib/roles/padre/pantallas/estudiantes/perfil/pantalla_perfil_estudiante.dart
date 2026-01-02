// 📁 Ubicación: lib/roles/padre/pantallas/estudiantes/perfil/pantalla_perfil_estudiante.dart

import 'package:club_huandoy/core/controladores/asistencias_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';
import 'package:intl/intl.dart';
import '../../agenda/pantalla_agenda_estudiante.dart';


class PantallaPerfilEstudiante extends StatelessWidget {
  const PantallaPerfilEstudiante({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // 🔒 Blindaje total
    if (args == null || args is! String || args.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del estudiante')),
        body: const Center(
          child: Text(
            'No se recibió el identificador del estudiante',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final String estudianteId = args;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del estudiante')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('estudiantes')
            .doc(estudianteId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró información del estudiante'),
            );
          }

          final estudiante = Estudiante.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= FOTO =================
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: estudiante.fotoUrl.isNotEmpty
                        ? NetworkImage(estudiante.fotoUrl)
                        : null,
                    child: estudiante.fotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // ================= NOMBRE =================
                Center(
                  child: Text(
                    '${estudiante.nombre} ${estudiante.apellido}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Center(child: Text('DNI: ${estudiante.dni}')),

                const SizedBox(height: 24),

                // ================= INFORMACIÓN PERSONAL =================
                _titulo('Información personal'),
                _fila(
                  'Fecha nacimiento',
                  estudiante.fechaNacimiento != null
                      ? estudiante.fechaNacimiento!
                          .toIso8601String()
                          .split('T')
                          .first
                      : '-',
                ),
                _fila('Género', estudiante.genero),
                _fila('Celular', estudiante.celular),

                const SizedBox(height: 24),

                // ================= INFORMACIÓN DEPORTIVA =================
                _titulo('Información deportiva'),
                _fila(
                  'Disciplina',
                  estudiante.disciplinaNombre.isNotEmpty
                      ? estudiante.disciplinaNombre
                      : 'No asignada',
                ),
                _fila(
                  'Categoría',
                  estudiante.categoria.isNotEmpty
                      ? estudiante.categoria
                      : 'No asignada',
                ),
                _fila(
                  'Grupo',
                  estudiante.grupoNombre.isNotEmpty
                      ? estudiante.grupoNombre
                      : '-',
                ),
                _fila(
                  'Horario',
                  estudiante.horarioNombre.isNotEmpty
                      ? estudiante.horarioNombre
                      : '-',
                ),
                _fila(
                  'Entrenador',
                  estudiante.entrenadorNombre.isNotEmpty
                      ? estudiante.entrenadorNombre
                      : '-',
                ),

                const SizedBox(height: 24),

                // ================= MATRÍCULA =================
                _titulo('Matrícula'),
                _fila('Estado', estudiante.estado),
                _fila(
                  'Pagada',
                  estudiante.matriculaPagada ? 'Sí' : 'No',
                ),

                const SizedBox(height: 24),

               // ================= ASISTENCIA =================
                _titulo('Asistencia'),
                StreamBuilder(
                  stream: AsistenciasController()
                      .listarPorEstudiante(estudiante.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Sin registros de asistencia'),
                      );
                    }

                    final asistencias = snapshot.data!;

                    return Column(
                      children: asistencias.map((a) {
                        final fechaTexto =
                            DateFormat('dd/MM/yyyy').format(a.fecha);

                        Color color;
                        switch (a.estado) {
                          case 'asistió':
                            color = Colors.green;
                            break;
                          case 'tardanza':
                            color = Colors.orange;
                            break;
                          default:
                            color = Colors.red;
                        }

                        return ListTile(
                          leading: Icon(Icons.event_available, color: color),
                          title: Text(fechaTexto),
                          trailing: Text(
                            a.estado.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Ver agenda / marcar asistencia'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaAgendaEstudiante(
                                estudiante: estudiante,
                              ),
                            ),
                          );
                        },
                      ),
              // ================= RESUMEN MENSUAL =================
              _titulo('Resumen mensual'),

              FutureBuilder<double>(
                future: AsistenciasController().porcentajeAsistenciaMensual(
                  estudianteId: estudiante.id,
                  year: DateTime.now().year,
                  month: DateTime.now().month - 1 == 0
                      ? 12
                      : DateTime.now().month - 1,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No hay datos del mes anterior'),
                    );
                  }

                  final porcentaje = snapshot.data!;
                  final cumple = porcentaje >= 75;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asistencia del mes anterior',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${porcentaje.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: cumple ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              Icon(
                                cumple ? Icons.check_circle : Icons.cancel,
                                color: cumple ? Colors.green : Colors.red,
                                size: 36,
                              )
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            cumple
                                ? '✔ Cumple requisito para mantener el descuento'
                                : '✖ No cumple el mínimo de 75% de asistencia',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cumple ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),


const SizedBox(height: 24),





                // ================= PAGOS =================
                _titulo('Pagos'),
                const Text('Sin registros'),

                const SizedBox(height: 24),

                // ================= DOCUMENTOS =================
                _titulo('Documentos'),
                const EnDesarrolloWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== HELPERS =====================

  Widget _titulo(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
      ],
    );
  }

  Widget _fila(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110, // ancho fijo para el label
          child: Text(label),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            (value == null || value.isEmpty) ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}

}
