import 'package:cloud_firestore/cloud_firestore.dart';

class DisciplinasController {
  final _db = FirebaseFirestore.instance;

  // ======================================================
  // CREAR DISCIPLINA CON PRECIOS
  // ======================================================
  Future<String> crearDisciplina({
    required String nombre,
    required String descripcion,
    required List<String> categorias,
    required Map<String, dynamic> precios, // <<<<<< NUEVO
  }) async {
    try {
      final doc = await _db.collection('disciplinas').add({
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'categorias': categorias,
        'precios': precios, // <<<<<< NUEVO
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception("Error al crear disciplina: $e");
    }
  }

  // ======================================================
  // EDITAR DISCIPLINA (nombre, desc, categorias, precios)
  // ======================================================
  Future<void> editarDisciplina(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('disciplinas').doc(id).update(data);
    } catch (e) {
      throw Exception("Error al editar disciplina: $e");
    }
  }

  // DESACTIVAR
  Future<void> desactivarDisciplina(String id) async {
    await _db.collection('disciplinas').doc(id).update({'activo': false});
  }

  // ACTIVAR
  Future<void> activarDisciplina(String id) async {
    await _db.collection('disciplinas').doc(id).update({'activo': true});
  }

  // LISTAR
  Stream<QuerySnapshot> listarDisciplinas() {
    return _db
        .collection('disciplinas')
        .orderBy('nombre')
        .snapshots();
  }
}
