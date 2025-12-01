// 📁 Ubicación: lib/roles/admin/modelos/asistencia_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaModel {
  final String id;
  final String estudianteId;
  final String grupoId;
  final DateTime fecha;
  final String estado; // asistió | falta | tardanza
  final DateTime horaRegistro;

  AsistenciaModel({
    required this.id,
    required this.estudianteId,
    required this.grupoId,
    required this.fecha,
    required this.estado,
    required this.horaRegistro,
  });

  factory AsistenciaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AsistenciaModel(
      id: doc.id,
      estudianteId: data['estudianteId'],
      grupoId: data['grupoId'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      estado: data['estado'],
      horaRegistro: (data['horaRegistro'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estudianteId': estudianteId,
      'grupoId': grupoId,
      'fecha': fecha,
      'estado': estado,
      'horaRegistro': horaRegistro,
    };
  }
}
