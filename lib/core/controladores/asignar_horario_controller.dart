// lib/core/controladores/asignar_horario_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignacionHorarioController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> validarEstadoEstudiante(String estudianteId) async {
    final doc = await _db.collection('estudiantes').doc(estudianteId).get();
    if (!doc.exists) throw "El estudiante no existe.";

    final estado = doc.data()!['estado'] ?? 'registrado';
    if (estado == "asignado") {
      throw "Este estudiante ya tiene un horario asignado.";
    }
    if (estado == "pagado") {
      throw "Este estudiante ya completó el proceso de pago.";
    }
  }

  Future<void> validarCupos(String grupoId) async {
    final doc = await _db.collection('grupos').doc(grupoId).get();
    if (!doc.exists) throw "El grupo no existe.";

    final data = doc.data()!;
    final int cupoMax = data['cupoMaximo'] ?? 0;
    final int inscritos = data['inscritos'] ?? 0;

    if (inscritos >= cupoMax) {
      throw "El grupo ya no tiene cupos disponibles.";
    }
  }

  Future<Map<String, dynamic>> prepararAsignacion({
    required String estudianteId,
    required String disciplinaId,
    required String disciplinaNombre,
    required String categoria,
    required String grupoId,
  }) async {
    await validarEstadoEstudiante(estudianteId);
    await validarCupos(grupoId);

    // ===== GRUPO =====
    final grupoDoc = await _db.collection('grupos').doc(grupoId).get();
    if (!grupoDoc.exists) throw "El grupo no existe.";
    final grupo = grupoDoc.data()!;

    final String grupoNombre =
        "Grupo ${grupo['categoria']} ${grupo['seccion']}";

    final String horarioId = grupo['horarioId'];
    final String entrenadorId = grupo['entrenadorId'];

    // ===== HORARIO =====
    final horarioDoc =
        await _db.collection('horarios').doc(horarioId).get();
    if (!horarioDoc.exists) throw "El horario no existe.";
    final horario = horarioDoc.data()!;

    final List dias = horario['dias'] ?? [];
    final String diasTexto = dias.join(', ');
    final String horaInicio = horario['horaInicio'] ?? '';
    final String horaFin = horario['horaFin'] ?? '';
    final String lugar = horario['lugar'] ?? '';

    final String horarioNombre =
        "$diasTexto | $horaInicio - $horaFin | $lugar";

    // ===== ENTRENADOR =====
    final entrenadorDoc =
        await _db.collection('entrenadores').doc(entrenadorId).get();
    if (!entrenadorDoc.exists) throw "El entrenador no existe.";
    final entrenador = entrenadorDoc.data()!;

    final String entrenadorNombre =
        "${entrenador['nombres']} ${entrenador['apellidos']}";

    final DateTime fechaInicioClases =
        (grupo['fechaInicioClases'] as Timestamp).toDate();

    return {
      "disciplinaId": disciplinaId,
      "disciplinaNombre": disciplinaNombre,
      "categoria": categoria,

      "grupoId": grupoId,
      "grupoNombre": grupoNombre,

      "horarioId": horarioId,
      "horarioNombre": horarioNombre,

      "entrenadorId": entrenadorId,
      "entrenadorNombre": entrenadorNombre,

      "fechaInicioClases": fechaInicioClases,
    };
  }
}
