// 📁 Ubicación: lib/roles/admin/modelos/disciplinas_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DisciplinaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;
  final DateTime fechaCreacion;

  final List<String> categorias;

  /// Precios por categoría → { "Sub 8": 100, "Sub 12": 150 }
  final Map<String, dynamic> precios;

  DisciplinaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.fechaCreacion,
    required this.categorias,
    required this.precios,
  });

  factory DisciplinaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DisciplinaModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categorias: List<String>.from(data['categorias'] ?? []),
      precios: Map<String, dynamic>.from(data['precios'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
      'categorias': categorias,
      'precios': precios,
    };
  }
}
