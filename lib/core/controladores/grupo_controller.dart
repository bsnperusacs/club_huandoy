// 📁 lib/roles/admin/controladores/grupo_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GruposController {
  final _db = FirebaseFirestore.instance;

  // ============================================================
  // 🔥 LETRAS DE SECCIÓN (A, B, C...)
  // ============================================================
  String _seccionDesdeIndex(int index) {
    const letras = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (index < letras.length) {
      return letras[index];
    }
    // si pasara Z, generar AA, AB... pero por ahora no lo necesitas
    return "Z";
  }

  // ============================================================
  // 🔥 OBTENER LA SIGUIENTE SECCIÓN PARA ESTA CATEGORÍA
  // ============================================================
  Future<String> _generarSeccion(String disciplinaId, String categoria) async {
    final snap = await _db
        .collection('grupos')
        .where('disciplinaId', isEqualTo: disciplinaId)
        .where('categoria', isEqualTo: categoria)
        .get();

    final cantidad = snap.docs.length; // 0 → A, 1 → B, 2 → C...
    return _seccionDesdeIndex(cantidad);
  }

  // ============================================================
  // 🔥 CREAR GRUPO CON SECCIÓN AUTOMÁTICA
  // ============================================================
  Future<String> crearGrupo({
    required String disciplinaId,
    required String horarioId,
    required String entrenadorId,
    required String categoria,
    required int cupoMaximo,
    required DateTime fechaInicioClases,
  }) async {
    try {
      // → Calcular sección automática
      final seccion = await _generarSeccion(disciplinaId, categoria);

      final doc = await _db.collection('grupos').add({
        'disciplinaId': disciplinaId,
        'horarioId': horarioId,
        'entrenadorId': entrenadorId,
        'categoria': categoria,
        'seccion': seccion,                // 🔥 NUEVO
        'cupoMaximo': cupoMaximo,
        'inscritos': 0,
        'activo': true,
        'fechaInicioClases': Timestamp.fromDate(fechaInicioClases),
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      return doc.id;

    } catch (e) {
      throw Exception("Error al crear grupo: $e");
    }
  }

  // ============================================================
  // 🔧 EDITAR GRUPO (NO CAMBIO SECCIÓN EXISTENTE)
  // ============================================================
  Future<void> editarGrupo(String id, Map<String, dynamic> data) async {
    await _db.collection('grupos').doc(id).update(data);
  }

  Future<void> desactivarGrupo(String id) async {
    await _db.collection('grupos').doc(id).update({'activo': false});
  }

  Future<void> activarGrupo(String id) async {
    await _db.collection('grupos').doc(id).update({'activo': true});
  }

  Stream<QuerySnapshot> listarGrupos() {
    return _db.collection('grupos').snapshots();
  }
}
