// 📁 lib/roles/admin/controladores/horario_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HorariosController {
  final _db = FirebaseFirestore.instance;

  Future<String> crearHorario({
    required String disciplinaId,
    required List<String> dias,
    required String horaInicio,
    required String horaFin,
    required String lugar,
  }) async {
    try {
      final doc = await _db.collection('horarios').add({
        'disciplinaId': disciplinaId,
        'dias': dias,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'lugar': lugar,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      return doc.id;
    } catch (e) {
      throw Exception("Error al crear horario: $e");
    }
  }

  Future<void> editarHorario(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('horarios').doc(id).update(data);
    } catch (e) {
      throw Exception("Error al editar horario: $e");
    }
  }

  Future<void> desactivarHorario(String id) async {
    await _db.collection('horarios').doc(id).update({'activo': false});
  }

  Future<void> activarHorario(String id) async {
    await _db.collection('horarios').doc(id).update({'activo': true});
  }

  Stream<QuerySnapshot> listarHorarios() {
    return _db.collection('horarios').orderBy('horaInicio').snapshots();
  }
}
