// 📁 Ubicación: lib/roles/admin/controladores/historial_cambios_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/modelos/historial_cambios_model.dart';

class HistorialCambiosController {
  final _db = FirebaseFirestore.instance;

  /// 📌 Registrar cambio
  Future<void> registrarCambio(HistorialCambiosModel cambio) async {
    await _db
        .collection('historial_cambios')
        .doc(cambio.id)
        .set(cambio.toMap());
  }

  /// 📌 Historial por estudiante
  Stream<QuerySnapshot> obtenerHistorial(String estudianteId) {
    return _db
        .collection('historial_cambios')
        .where('estudianteId', isEqualTo: estudianteId)
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}
