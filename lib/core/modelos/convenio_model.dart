//📁 lib/core/modelos/convenio_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ConvenioModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String codigo;
  final String? imagenUrl;

  // Aplicación
  final String aplicaEn; // mensualidad, matricula, ambos
  final bool aplicaUnaVez;
  final bool permanente;

  // Descuentos
  final String tipoDescuento; // porcentaje / monto
  final double valorDescuento;

  // Condiciones de asistencia
  final bool requiereAsistencia;
  final int asistenciaMinima;
  final String penalidadSiFalla; // "25%", "normal", etc
  final bool recuperaDescuentoSiCumple;

  // Acumulación
  final bool acumulableConOtros;

  final bool activo;
  final DateTime fechaCreacion;

  ConvenioModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.codigo,
    required this.imagenUrl,
    required this.aplicaEn,
    required this.aplicaUnaVez,
    required this.permanente,
    required this.tipoDescuento,
    required this.valorDescuento,
    required this.requiereAsistencia,
    required this.asistenciaMinima,
    required this.penalidadSiFalla,
    required this.recuperaDescuentoSiCumple,
    required this.acumulableConOtros,
    required this.activo,
    required this.fechaCreacion,
  });

  factory ConvenioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConvenioModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      codigo: data['codigo'] ?? '',
      imagenUrl: data['imagenUrl'],
      aplicaEn: data['aplicaEn'] ?? 'mensualidad',
      aplicaUnaVez: data['aplicaUnaVez'] ?? false,
      permanente: data['permanente'] ?? false,
      tipoDescuento: data['tipoDescuento'] ?? 'porcentaje',
      valorDescuento: (data['valorDescuento'] ?? 0).toDouble(),
      requiereAsistencia: data['requiereAsistencia'] ?? false,
      asistenciaMinima: data['asistenciaMinima'] ?? 75,
      penalidadSiFalla: data['penalidadSiFalla'] ?? 'normal',
      recuperaDescuentoSiCumple: data['recuperaDescuentoSiCumple'] ?? false,
      acumulableConOtros: data['acumulableConOtros'] ?? false,
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'codigo': codigo,
      'imagenUrl': imagenUrl,
      'aplicaEn': aplicaEn,
      'aplicaUnaVez': aplicaUnaVez,
      'permanente': permanente,
      'tipoDescuento': tipoDescuento,
      'valorDescuento': valorDescuento,
      'requiereAsistencia': requiereAsistencia,
      'asistenciaMinima': asistenciaMinima,
      'penalidadSiFalla': penalidadSiFalla,
      'recuperaDescuentoSiCumple': recuperaDescuentoSiCumple,
      'acumulableConOtros': acumulableConOtros,
      'activo': activo,
      'fechaCreacion': FieldValue.serverTimestamp(),
    };
  }
}
