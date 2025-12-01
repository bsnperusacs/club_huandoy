// 📁 Ubicación: lib/roles/admin/modelos/pago_registro_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PagoRegistro {
  final String id;
  final String estudianteId;
  final double monto;
  final String concepto; // mensualidad, matricula, prorrateo
  final DateTime fecha;
  final String metodo; // mercadoPago, efectivo, etc
  final String? idPagoMp;

  PagoRegistro({
    required this.id,
    required this.estudianteId,
    required this.monto,
    required this.concepto,
    required this.fecha,
    required this.metodo,
    this.idPagoMp,
  });

  factory PagoRegistro.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PagoRegistro(
      id: doc.id,
      estudianteId: data['estudianteId'],
      monto: (data['monto'] ?? 0).toDouble(),
      concepto: data['concepto'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      metodo: data['metodo'] ?? '',
      idPagoMp: data['idPagoMp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estudianteId': estudianteId,
      'monto': monto,
      'concepto': concepto,
      'fecha': Timestamp.fromDate(fecha),
      'metodo': metodo,
      'idPagoMp': idPagoMp,
    };
  }
}
