// 📁 lib/core/controladores/grupo_controller.dart
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

    final cantidad = snap.docs.length;
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
      final seccion = await _generarSeccion(disciplinaId, categoria);

      final doc = await _db.collection('grupos').add({
        'disciplinaId': disciplinaId,
        'horarioId': horarioId,
        'entrenadorId': entrenadorId,
        'categoria': categoria,
        'seccion': seccion,
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
  // 🔧 EDITAR / ACTIVAR / DESACTIVAR
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

  // ============================================================
  // 🔍 OBTENER GRUPO POR ID (SOLO LECTURA)
  // ============================================================
  Future<Map<String, dynamic>> obtenerGrupoPorId(String grupoId) async {
    final doc = await _db.collection('grupos').doc(grupoId).get();
    if (!doc.exists) throw "Grupo no existe";
    return doc.data()!;
  }

  // ============================================================
  // 🔤 NOMBRE LEGIBLE DEL GRUPO (PARA PERFIL)
  // ============================================================
  Future<String> obtenerNombreGrupo(String grupoId) async {
    final grupo = await obtenerGrupoPorId(grupoId);
    final categoria = grupo['categoria'] ?? '';
    final seccion = grupo['seccion'] ?? '';
    return "Grupo $categoria $seccion".trim();
  }
}
