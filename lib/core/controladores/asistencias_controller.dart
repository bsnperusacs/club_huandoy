// 📁 Ubicación: lib/core/controladores/asistencias_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/asistencia_model.dart';
import 'package:club_huandoy/core/servicios/geocerca_service.dart';

class AsistenciasController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // REGISTRAR / ACTUALIZAR ASISTENCIA (UNA POR DÍA)
  // ============================================================
  Future<void> registrarAsistencia({
    required String estudianteId,
    required String grupoId,
    required DateTime fecha,
    required String estado,
  }) async {
    final fechaDia = DateTime(fecha.year, fecha.month, fecha.day);

    final query = await _db
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isEqualTo: fechaDia)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'estado': estado,
        'horaRegistro': DateTime.now(),
      });
      return;
    }

    final docRef = _db.collection('asistencias').doc();

    final asistencia = AsistenciaModel(
      id: docRef.id,
      estudianteId: estudianteId,
      grupoId: grupoId,
      fecha: fechaDia,
      estado: estado,
      horaRegistro: DateTime.now(),
    );

    await docRef.set(asistencia.toMap());
  }

  // ============================================================
  // LISTAR ASISTENCIAS POR ESTUDIANTE
  // ============================================================
  Stream<List<AsistenciaModel>> listarPorEstudiante(String estudianteId) {
    return _db
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AsistenciaModel.fromFirestore(d)).toList(),
        );
  }

  // ============================================================
  // LISTAR ASISTENCIAS POR GRUPO Y FECHA
  // ============================================================
  Stream<List<AsistenciaModel>> listarPorGrupoYFecha({
    required String grupoId,
    required DateTime fecha,
  }) {
    final fechaDia = DateTime(fecha.year, fecha.month, fecha.day);

    return _db
        .collection('asistencias')
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isEqualTo: fechaDia)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AsistenciaModel.fromFirestore(d)).toList(),
        );
  }

  // ============================================================
  // RESUMEN MENSUAL POR ESTUDIANTE
  // ============================================================
  Future<Map<String, int>> resumenMensual({
    required String estudianteId,
    required int year,
    required int month,
  }) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 1);

    final snap = await _db
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin)
        .get();

    int asistio = 0;
    int tardanza = 0;
    int falta = 0;

    for (final d in snap.docs) {
      final estado = d['estado'];
      if (estado == 'asistió') asistio++;
      if (estado == 'tardanza') tardanza++;
      if (estado == 'falta') falta++;
    }

    return {
      'asistio': asistio,
      'tardanza': tardanza,
      'falta': falta,
      'total': snap.docs.length,
    };
  }

  // ============================================================
  // REGISTRAR ASISTENCIA POR GEOCERCA (ALUMNO)
  // ============================================================
  Future<void> registrarPorGeocerca({
    required String estudianteId,
    required String grupoId,
    required double latCentro,
    required double lngCentro,
  }) async {
    final geocercaService = GeocercaService();

    // Validar geocerca
    final resultado = await geocercaService.validarGeocerca(
      latCentro: latCentro,
      lngCentro: lngCentro,
    );

    if (!resultado.permitido) {
      throw 'Fuera del área permitida (${resultado.distanciaMetros.toStringAsFixed(1)} m)';
    }

    // Normalizar fecha (solo día)
    final hoy = DateTime.now();
    final fechaDia = DateTime(hoy.year, hoy.month, hoy.day);

    // Verificar si ya existe asistencia hoy
    final query = await _db
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isEqualTo: fechaDia)
        .limit(1)
        .get();

    // Si existe, no permitir duplicar
    if (query.docs.isNotEmpty) {
      throw 'La asistencia de hoy ya fue registrada';
    }

    // Registrar asistencia
    await _db.collection('asistencias').add({
      'estudianteId': estudianteId,
      'grupoId': grupoId,
      'fecha': fechaDia,
      'estado': 'asistió',

      // Geocerca
      'origen': 'geocerca',
      'registradoPor': 'estudiante',
      'lat': resultado.lat,
      'lng': resultado.lng,
      'distanciaMetros': resultado.distanciaMetros,
      'geocercaValida': true,

      // Manual (no aplica)
      'entrenadorId': null,
      'entrenadorNombre': null,
      'justificacion': null,

      'horaRegistro': DateTime.now(),
    });
  }

  // ============================================================
  // REGISTRAR ASISTENCIA MANUAL (ENTRENADOR - RESPALDO)
  // ============================================================
  Future<void> registrarManualPorEntrenador({
    required String estudianteId,
    required String grupoId,
    required String estado, // asistió | tardanza | falta
    required String entrenadorId,
    required String entrenadorNombre,
    required String justificacion,
  }) async {
    if (justificacion.trim().isEmpty) {
      throw 'La justificación es obligatoria';
    }

    final hoy = DateTime.now();
    final fechaDia = DateTime(hoy.year, hoy.month, hoy.day);

    // Evitar duplicado del día
    final query = await _db
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isEqualTo: fechaDia)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      throw 'La asistencia de hoy ya fue registrada';
    }

    await _db.collection('asistencias').add({
      'estudianteId': estudianteId,
      'grupoId': grupoId,
      'fecha': fechaDia,
      'estado': estado,

      // Manual
      'origen': 'manual',
      'registradoPor': 'entrenador',
      'entrenadorId': entrenadorId,
      'entrenadorNombre': entrenadorNombre,
      'justificacion': justificacion,

      // Geocerca (no aplica)
      'lat': null,
      'lng': null,
      'distanciaMetros': null,
      'geocercaValida': false,

      'horaRegistro': DateTime.now(),
    });
  }



  // ============================================================
  // PORCENTAJE DE ASISTENCIA MENSUAL
  // ============================================================
  Future<double> porcentajeAsistenciaMensual({
    required String estudianteId,
    required int year,
    required int month,
  }) async {
    final resumen = await resumenMensual(
      estudianteId: estudianteId,
      year: year,
      month: month,
    );

    final total = resumen['total'] ?? 0;
    if (total == 0) return 0;

    final presentes =
        (resumen['asistio'] ?? 0) + (resumen['tardanza'] ?? 0);

    final porcentaje = (presentes / total) * 100;
    return double.parse(porcentaje.toStringAsFixed(2));
  }
}


