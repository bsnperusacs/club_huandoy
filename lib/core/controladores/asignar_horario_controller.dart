import 'package:cloud_firestore/cloud_firestore.dart';

class AsignacionHorarioController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// =====================================================
  /// 🔍 VALIDAR SI EL ESTUDIANTE YA TIENE ESTADO ASIGNADO
  /// =====================================================
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

  /// =====================================================
  /// 🔍 VALIDAR CUPOS DEL GRUPO (según tu estructura real)
  /// =====================================================
  Future<void> validarCupos(String grupoId) async {
    final doc = await _db.collection('grupos').doc(grupoId).get();

    if (!doc.exists) throw "El grupo no existe.";

    final data = doc.data()!;
    final int cupoMax = data['cupoMaximo'] ?? 0; // <-- así está en tu Firestore
    final int inscritos = data['inscritos'] ?? 0;

    if (inscritos >= cupoMax) {
      throw "El grupo ya no tiene cupos disponibles.";
    }
  }

  /// =====================================================
  /// 🔍 VALIDACIÓN DE EDAD (opcional por ahora)
  /// =====================================================
  Future<void> validarEdad(String estudianteId, String categoria) async {
    // pendiente – no requerido ahora
    return;
  }

  /// =====================================================
  /// 🎯 OBTENER INFORMACIÓN COMPLETA DEL GRUPO
  /// =====================================================
  Future<Map<String, dynamic>> obtenerGrupo(String grupoId) async {
    final doc = await _db.collection('grupos').doc(grupoId).get();
    if (!doc.exists) throw "El grupo no existe.";
    return doc.data()!;
  }

  /// =====================================================
  /// 🎯 OBTENER INFORMACIÓN DE LA DISCIPLINA (para precio)
  /// =====================================================
  Future<Map<String, dynamic>> obtenerDisciplina(String disciplinaId) async {
    final doc = await _db.collection('disciplinas').doc(disciplinaId).get();
    if (!doc.exists) throw "La disciplina no existe.";
    return doc.data()!;
  }

  /// =====================================================
  /// 🎯 PROCESO PRINCIPAL — SOLO PREPARA DATOS
  /// =====================================================
  Future<Map<String, dynamic>> prepararAsignacion({
    required String estudianteId,
    required String disciplinaId,
    required String categoria,
    required String grupoId,
  }) async {
    // 1. Validaciones
    await validarEstadoEstudiante(estudianteId);
    await validarCupos(grupoId);
    await validarEdad(estudianteId, categoria);

    // 2. Carga de datos del grupo
    final grupo = await obtenerGrupo(grupoId);

    final String horarioId = grupo['horarioId'];
    final String entrenadorId = grupo['entrenadorId'];
    final DateTime fechaInicioClases =
        (grupo['fechaInicioClases'] as Timestamp).toDate();

    // 3. Cargar disciplina (precio por categoría)
    final disciplina = await obtenerDisciplina(disciplinaId);
    final Map precios = disciplina['precios'] ?? {};
    final double montoCategoria = (precios[categoria] ?? 0).toDouble();

    // 4. Devolver información consolidada (NO guarda nada)
    return {
      "disciplinaId": disciplinaId,
      "categoriaId": categoria,
      "grupoId": grupoId,
      "horarioId": horarioId,
      "entrenadorId": entrenadorId,
      "fechaInicioClases": fechaInicioClases,
      "montoCategoria": montoCategoria,
    };
  }
}
