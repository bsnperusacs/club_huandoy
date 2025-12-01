// 📁 Ubicación: lib/core/modelos/entrenador_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EntrenadorModel {
  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? fotoUrl;
  final List<String> disciplinas;
  final bool activo;
  final DateTime fechaCreacion;

  EntrenadorModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.disciplinas,
    required this.activo,
    required this.fechaCreacion,
    this.fotoUrl,
  });

  // ---------------------------------
  // FROM FIRESTORE
  // ---------------------------------
  factory EntrenadorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EntrenadorModel(
      id: doc.id,
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      telefono: data['telefono'] ?? '',
      fotoUrl: data['fotoUrl'],
      disciplinas: List<String>.from(data['disciplinas'] ?? []),
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ---------------------------------
  // TO MAP
  // ---------------------------------
  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'disciplinas': disciplinas,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
    };
  }

  // ---------------------------------
  // AYUDA UI
  // ---------------------------------
  String get nombreCompleto => "$nombres $apellidos";
}
