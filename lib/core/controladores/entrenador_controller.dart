// 📁 lib/core/controladores/entrenador_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EntrenadoresController {
  final _db = FirebaseFirestore.instance;

  // ============================
  // CREAR ENTRENADOR (DNI = ID)
  // ============================
  Future<void> crearEntrenador({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required List<String> disciplinas,
  }) async {
    try {
      await _db.collection('entrenadores').doc(dni).set({
        'dni': dni,
        'nombres': nombres.trim(),
        'apellidos': apellidos.trim(),
        'telefono': telefono.trim(),
        'disciplinas': disciplinas,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al crear entrenador: $e");
    }
  }

  // ============================
  // EDITAR ENTRENADOR
  // ============================
  Future<void> editarEntrenador(
    String dni,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('entrenadores').doc(dni).update(data);
    } catch (e) {
      throw Exception("Error al editar entrenador: $e");
    }
  }

  // ============================
  // ACTIVAR / DESACTIVAR
  // ============================
  Future<void> desactivarEntrenador(String dni) async {
    await _db.collection('entrenadores').doc(dni).update({'activo': false});
  }

  Future<void> activarEntrenador(String dni) async {
    await _db.collection('entrenadores').doc(dni).update({'activo': true});
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

  // ============================
  // OBTENER ENTRENADOR POR DNI
  // ============================
  Future<Map<String, dynamic>> obtenerEntrenadorPorDni(String dni) async {
    final doc = await _db.collection('entrenadores').doc(dni).get();
    if (!doc.exists) throw "Entrenador no existe";
    return doc.data()!;
  }

  // ============================
  // NOMBRE COMPLETO
  // ============================
  Future<String> obtenerNombreEntrenador(String dni) async {
    final e = await obtenerEntrenadorPorDni(dni);
    return "${e['nombres']} ${e['apellidos']}".trim();
  }
}
