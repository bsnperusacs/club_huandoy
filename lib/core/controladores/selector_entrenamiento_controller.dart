// 📁 Ubicación: lib/core/controladores/selector_entrenamiento_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// MODELOS GLOBALES (los correctos)
import 'package:club_huandoy/core/modelos/disciplina_model.dart';
import 'package:club_huandoy/core/modelos/horario_model.dart';
import 'package:club_huandoy/core/modelos/entrenador_model.dart';
import 'package:club_huandoy/core/modelos/grupo_model.dart';

class SelectorEntrenamientoController {
  // -------------------------
  // LISTAR DISCIPLINAS
  // -------------------------
  Future<List<DisciplinaModel>> obtenerDisciplinas() async {
    final snap = await FirebaseFirestore.instance
        .collection('disciplinas')
        .get();

    return snap.docs.map((d) => DisciplinaModel.fromFirestore(d)).toList();
  }

  // -------------------------
  // LISTAR CATEGORÍAS (SOLO STRINGS)
  // -------------------------
  Future<List<String>> obtenerCategorias(String disciplinaId) async {
    final snap = await FirebaseFirestore.instance
        .collection('disciplinas')
        .doc(disciplinaId)
        .get();

    final data = snap.data();
    if (data == null) return [];

    final categorias = (data['categorias'] ?? []) as List;

    return categorias.map((c) => c.toString()).toList();
  }

  // -------------------------
  // LISTAR GRUPOS POR DISCIPLINA Y CATEGORÍA
  // -------------------------
  Future<List<GrupoModel>> obtenerGrupos(
      String disciplinaId, String categoria) async {
    final snap = await FirebaseFirestore.instance
        .collection('grupos')
        .where('disciplinaId', isEqualTo: disciplinaId)
        .where('categoria', isEqualTo: categoria)
        .where('activo', isEqualTo: true)
        .get();

    return snap.docs.map((d) => GrupoModel.fromFirestore(d)).toList();
  }

  // -------------------------
  // ENTRENADOR DEL GRUPO
  // -------------------------
  Future<EntrenadorModel?> obtenerEntrenador(String entrenadorId) async {
    if (entrenadorId.isEmpty) return null;

    final doc = await FirebaseFirestore.instance
        .collection('entrenadores')
        .doc(entrenadorId)
        .get();

    if (!doc.exists) return null;

    return EntrenadorModel.fromFirestore(doc);
  }

  // -------------------------
  // HORARIO DEL GRUPO
  // -------------------------
  Future<HorarioModel?> obtenerHorario(String horarioId) async {
    if (horarioId.isEmpty) return null;

    final doc = await FirebaseFirestore.instance
        .collection('horarios')
        .doc(horarioId)
        .get();

    if (!doc.exists) return null;

    return HorarioModel.fromFirestore(doc);
  }
}
