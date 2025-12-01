// 📁 Ubicación: lib/roles/admin/modelos/pago_admin_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PagoAdminModel {
  final String id;
  final String estudianteId;
  final String grupoId;

  final double montoCategoria;
  final double montoProrrateo;
  final double montoDescuento;
  final double montoFinal;

  final String descripcion;
  final String idPagoMp;

  final DateTime fechaPago;

  PagoAdminModel({
    required this.id,
    required this.estudianteId,
    required this.grupoId,
    required this.montoCategoria,
    required this.montoProrrateo,
    required this.montoDescuento,
    required this.montoFinal,
    required this.descripcion,
    required this.idPagoMp,
    required this.fechaPago,
  });

  factory PagoAdminModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return PagoAdminModel(
      id: doc.id,
      estudianteId: d['estudianteId'],
      grupoId: d['grupoId'],
      montoCategoria: (d['montoCategoria']).toDouble(),
      montoProrrateo: (d['montoProrrateo']).toDouble(),
      montoDescuento: (d['montoDescuento']).toDouble(),
      montoFinal: (d['montoFinal']).toDouble(),
      descripcion: d['descripcion'],
      idPagoMp: d['idPagoMp'],
      fechaPago: (d['fechaPago'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estudianteId': estudianteId,
      'grupoId': grupoId,
      'montoCategoria': montoCategoria,
      'montoProrrateo': montoProrrateo,
      'montoDescuento': montoDescuento,
      'montoFinal': montoFinal,
      'descripcion': descripcion,
      'idPagoMp': idPagoMp,
      'fechaPago': fechaPago,
    };
  }
}
