import 'package:cloud_firestore/cloud_firestore.dart';

class ProrrateoController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> calcular({
    required String disciplinaId,
    required String categoria,
    required DateTime fechaInicioClases,
  }) async {
    // 1. Obtener precio desde Firestore
    final doc = await db.collection("disciplinas").doc(disciplinaId).get();
    if (!doc.exists) {
      throw "Disciplina no encontrada";
    }

    final precios = Map<String, dynamic>.from(doc["precios"]);
    final double montoMensual =
        (precios[categoria] ?? 0).toDouble();

    final DateTime hoy = DateTime.now();

    // ======================================================
    // CASO 1: AÚN NO INICIAN CLASES → PAGA MES COMPLETO
    // ======================================================
    if (hoy.isBefore(fechaInicioClases)) {
      return {
        "montoCategoria": montoMensual,
        "montoProrrateo": 0.0,
        "montoDescuento": 0.0,
        "montoFinal": montoMensual,
        "saldoPendiente": 0.0,
      };
    }

    // ======================================================
    // CASO 2: CLASES YA INICIARON → PRORRATEO REAL
    // CICLO: fechaInicioClases → misma fecha mes siguiente
    // ======================================================

    // Fin del ciclo actual
    DateTime finCicloActual = DateTime(
      hoy.year,
      hoy.month,
      fechaInicioClases.day,
    );

    // Si ya pasó ese día este mes, el ciclo termina el próximo mes
    if (!finCicloActual.isAfter(hoy)) {
      finCicloActual = DateTime(
        hoy.year,
        hoy.month + 1,
        fechaInicioClases.day,
      );
    }

    // Inicio del ciclo actual
    final DateTime inicioCicloActual = DateTime(
      finCicloActual.year,
      finCicloActual.month - 1,
      fechaInicioClases.day,
    );

    // Días totales del ciclo
    final int diasCiclo =
        finCicloActual.difference(inicioCicloActual).inDays;

    // Días a cobrar (HOY → fin de ciclo)
    final int diasProrrateo =
        finCicloActual.difference(hoy).inDays;

    final double valorDiario = montoMensual / diasCiclo;

    final double montoProrrateo = double.parse(
      (valorDiario * diasProrrateo).toStringAsFixed(2),
    );

    // ======================================================
    // REGLA DE LOS 20 SOLES (CORRECTA)
    // NO SE ELIMINA → SE ACUMULA
    // ======================================================

    double montoFinal;
    double saldoPendiente = 0.0;

    if (montoProrrateo < 20) {
      montoFinal = montoMensual;
      saldoPendiente = montoProrrateo;
    } else {
      montoFinal = montoProrrateo;
    }

    return {
      "montoCategoria": montoMensual,
      "montoProrrateo": montoProrrateo,
      "montoDescuento": 0.0,
      "montoFinal": montoFinal,
      "saldoPendiente": saldoPendiente,
      "inicioPeriodo": hoy,
      "finPeriodo": finCicloActual,
    };
  }
}
