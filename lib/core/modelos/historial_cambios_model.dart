// 📁 Ubicación: lib/roles/admin/modelos/historial_cambios_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialCambiosModel {
  final String id;
  final String estudianteId;

  final String tipo; // cambio_grupo, reinscripción, cambio_disciplina
  final Map<String, dynamic> antes;
  final Map<String, dynamic> despues;

  final DateTime fecha;
  final String realizadoPor; // adminId

  HistorialCambiosModel({
    required this.id,
    required this.estudianteId,
    required this.tipo,
    required this.antes,
    required this.despues,
    required this.fecha,
    required this.realizadoPor,
  });

  factory HistorialCambiosModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HistorialCambiosModel(
      id: doc.id,
      estudianteId: data['estudianteId'],
      tipo: data['tipo'],
      antes: Map<String, dynamic>.from(data['antes']),
      despues: Map<String, dynamic>.from(data['despues']),
      fecha: (data['fecha'] as Timestamp).toDate(),
      realizadoPor: data['realizadoPor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estudianteId': estudianteId,
      'tipo': tipo,
      'antes': antes,
      'despues': despues,
      'fecha': fecha,
      'realizadoPor': realizadoPor,
    };
  }
}
