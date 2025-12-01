// 📁 Ubicación: lib/roles/admin/modelos/horario_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HorarioModel {
  final String id;
  final String disciplinaId;
  final List<String> dias;
  final String horaInicio;
  final String horaFin;
  final String lugar;
  final bool activo;
  final DateTime fechaCreacion;

  HorarioModel({
    required this.id,
    required this.disciplinaId,
    required this.dias,
    required this.horaInicio,
    required this.horaFin,
    required this.lugar,
    required this.activo,
    required this.fechaCreacion,
  });

  factory HorarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HorarioModel(
      id: doc.id,
      disciplinaId: data['disciplinaId'] ?? '',
      dias: List<String>.from(data['dias'] ?? []),
      horaInicio: data['horaInicio'] ?? '',
      horaFin: data['horaFin'] ?? '',
      lugar: data['lugar'] ?? '',
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'disciplinaId': disciplinaId,
      'dias': dias,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'lugar': lugar,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
    };
  }
}
