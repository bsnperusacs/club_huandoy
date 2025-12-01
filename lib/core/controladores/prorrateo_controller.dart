import 'package:cloud_firestore/cloud_firestore.dart';

class ProrrateoController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /// ================================================
  /// 🔥 CALCULAR PRORRATEO REAL
  /// ================================================
  Future<Map<String, dynamic>> calcular({
    required String disciplinaId,
    required String categoria,
    required DateTime fechaInicioClases,
  }) async {
    // 1. Obtener precio desde disciplina
    final doc = await db.collection("disciplinas").doc(disciplinaId).get();
    if (!doc.exists) throw "Disciplina no encontrada.";

    final precios = Map<String, dynamic>.from(doc["precios"]);
    final double montoCategoria = (precios[categoria] ?? 0).toDouble();

    // 2. Fechas
    final hoy = DateTime.now();

    // ======================================================
    // 🔵 CASO 1: EL GRUPO TODAVÍA NO INICIA → PAGAR SOLO CATEGORÍA
    // ======================================================
    if (hoy.isBefore(fechaInicioClases)) {
      return {
        "montoCategoria": montoCategoria,
        "montoProrrateo": 0.0,
        "montoDescuento": 0.0,
        "montoFinal": montoCategoria,
      };
    }

    // ======================================================
    // 🔵 CASO 2: EL GRUPO YA INICIÓ → CALCULAR PRORRATEO
    // ======================================================

    final int diasEnMes = DateTime(hoy.year, hoy.month + 1, 0).day;
    final DateTime finMes = DateTime(hoy.year, hoy.month, diasEnMes);

    final int diasRestantes = finMes.difference(hoy).inDays;

    double prorrateo = (montoCategoria / 30) * diasRestantes;

    // ======================================================
    // 🔵 REGLA DEL MÍNIMO → SI ES MENOR A 20 SE AGREGA EL MES COMPLETO
    // ======================================================
    double montoFinal;
    if (prorrateo < 20) {
      montoFinal = prorrateo + montoCategoria;
    } else {
      montoFinal = prorrateo;
    }

    return {
      "montoCategoria": montoCategoria,
      "montoProrrateo": prorrateo,
      "montoDescuento": 0.0,
      "montoFinal": montoFinal,
    };
  }
}
