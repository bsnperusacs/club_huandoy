// 📁 lib/roles/admin/controladores/entrenador_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EntrenadoresController {
  final _db = FirebaseFirestore.instance;

  // ============================
  // CREAR ENTRENADOR
  // ============================
  Future<String> crearEntrenador({
    required String nombres,
    required String apellidos,
    required String telefono,
    required List<String> disciplinas,
  }) async {
    try {
      final doc = await _db.collection('entrenadores').add({
        'nombres': nombres.trim(),
        'apellidos': apellidos.trim(),
        'telefono': telefono.trim(),
        'disciplinas': disciplinas,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception("Error al crear entrenador: $e");
    }
  }

  // ============================
  // EDITAR ENTRENADOR
  // ============================
  Future<void> editarEntrenador(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('entrenadores').doc(id).update(data);
    } catch (e) {
      throw Exception("Error al editar entrenador: $e");
    }
  }

  // ============================
  // ACTIVAR / DESACTIVAR
  // ============================
  Future<void> desactivarEntrenador(String id) async {
    await _db.collection('entrenadores').doc(id).update({'activo': false});
  }

  Future<void> activarEntrenador(String id) async {
    await _db.collection('entrenadores').doc(id).update({'activo': true});
  }

  // ============================
  // LISTAR ENTRENADORES
  // ============================
  Stream<QuerySnapshot> listarEntrenadores() {
    return _db
        .collection('entrenadores')
        .orderBy('nombres')
        .snapshots();
  }
}
