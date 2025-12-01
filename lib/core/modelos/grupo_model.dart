// 📁 Ubicación: lib/core/modelos/grupo_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GrupoModel {
  final String id;
  final String disciplinaId;
  final String horarioId;
  final String entrenadorId;
  final String categoria;
  final String seccion;
  final int cupoMaximo;
  final int inscritos;
  final bool activo;
  final DateTime fechaInicioClases;
  final DateTime fechaCreacion;

  GrupoModel({
    required this.id,
    required this.disciplinaId,
    required this.horarioId,
    required this.entrenadorId,
    required this.categoria,
    required this.seccion,
    required this.cupoMaximo,
    required this.inscritos,
    required this.activo,
    required this.fechaInicioClases,
    required this.fechaCreacion,
  });

  // ------------------------------
  // FROM FIRESTORE
  // ------------------------------
  factory GrupoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GrupoModel(
      id: doc.id,
      disciplinaId: data['disciplinaId'] ?? '',
      horarioId: data['horarioId'] ?? '',
      entrenadorId: data['entrenadorId'] ?? '',
      categoria: data['categoria'] ?? '',
      seccion: data['seccion'] ?? 'A',
      cupoMaximo: (data['cupoMaximo'] ?? 0),
      inscritos: (data['inscritos'] ?? 0),
      activo: data['activo'] ?? true,
      fechaInicioClases:
          (data['fechaInicioClases'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ------------------------------
  // TO MAP
  // ------------------------------
  Map<String, dynamic> toMap() {
    return {
      'disciplinaId': disciplinaId,
      'horarioId': horarioId,
      'entrenadorId': entrenadorId,
      'categoria': categoria,
      'seccion': seccion,
      'cupoMaximo': cupoMaximo,
      'inscritos': inscritos,
      'activo': activo,
      'fechaInicioClases': fechaInicioClases,
      'fechaCreacion': fechaCreacion,
    };
  }

  // ------------------------------
  // COPIA MODIFICADA
  // ------------------------------
  GrupoModel copyWith({
    String? disciplinaId,
    String? horarioId,
    String? entrenadorId,
    String? categoria,
    String? seccion,
    int? cupoMaximo,
    int? inscritos,
    bool? activo,
    DateTime? fechaInicioClases,
  }) {
    return GrupoModel(
      id: id,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      horarioId: horarioId ?? this.horarioId,
      entrenadorId: entrenadorId ?? this.entrenadorId,
      categoria: categoria ?? this.categoria,
      seccion: seccion ?? this.seccion,
      cupoMaximo: cupoMaximo ?? this.cupoMaximo,
      inscritos: inscritos ?? this.inscritos,
      activo: activo ?? this.activo,
      fechaInicioClases: fechaInicioClases ?? this.fechaInicioClases,
      fechaCreacion: fechaCreacion,
    );
  }

  // ------------------------------
  // Nombre amigable para UI
  // ------------------------------
  String get nombreUI => "Grupo $categoria – Sección $seccion";
}
