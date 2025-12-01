// 📁 Ubicación: lib/roles/admin/controladores/asistencias_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciasController {
  final _db = FirebaseFirestore.instance;

  /// 📌 Registrar asistencia
  Future<void> registrarAsistencia({
    required String estudianteId,
    required String grupoId,
    required String estado, // asistió | falta | tardanza
  }) async {
    final hoy = DateTime.now();
    final fechaSolo = DateTime(hoy.year, hoy.month, hoy.day);

    await _db.collection('asistencias').add({
      'estudianteId': estudianteId,
      'grupoId': grupoId,
      'fecha': Timestamp.fromDate(fechaSolo),
      'estado': estado,
      'horaRegistro': Timestamp.now(),
    });
  }

  /// 📌 Obtener asistencia del día por grupo
  Stream<QuerySnapshot> listarAsistenciasDeHoy(String grupoId) {
    final hoy = DateTime.now();
    final fecha = DateTime(hoy.year, hoy.month, hoy.day);

    return _db
        .collection('asistencias')
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
        .snapshots();
  }
}
