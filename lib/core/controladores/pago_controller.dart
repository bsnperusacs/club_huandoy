// 📁 Ubicación: lib/core/controladores/pago_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PagoController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  // ============================================================
  // 🔵 1. GENERAR INIT POINT (MercadoPago)
  // ============================================================
  Future<String?> generarInitPoint({
    required String estudianteId,
    required num montoFinal,
    required String descripcion,
  }) async {
    try {
      final callable = functions.httpsCallable("generarLinkPago");

      final result = await callable.call({
        "estudianteId": estudianteId,
        "monto": montoFinal,
        "descripcion": descripcion,
      });

      return result.data["init_point"];
    } catch (e) {
      print("❌ generarInitPoint ERROR: $e");
      return null;
    }
  }

  // ============================================================
  // 🔵 2. REGISTRAR PAGO CONFIRMADO
  // ============================================================
  Future<void> registrarPago({
    required String estudianteId,
    required String grupoId,
    required Map datos,
  }) async {
    final doc = db.collection("pagos").doc();

    try {
      await doc.set({
        "id": doc.id,
        "fecha": FieldValue.serverTimestamp(),
        "estado": "pagado",
        "estudianteId": estudianteId,
        "grupoId": grupoId,

        // MONTOS
        "montoCategoria": datos["montoCategoria"],
        "montoProrrateo": datos["montoProrrateo"],
        "montoDescuento": datos["montoDescuento"],
        "montoFinal": datos["montoFinal"],

        // descripción (opcional)
        "descripcion": datos["descripcion"] ?? "",
      });

      // Actualizar estado del estudiante
      await db.collection("estudiantes").doc(estudianteId).update({
        "estado": "pagado",
        "grupoId": grupoId,
      });

    } catch (e) {
      print("❌ registrarPago ERROR: $e");
      rethrow;
    }
  }

  // ============================================================
  // 🔵 3. LISTAR PAGOS (ADMIN)
  // ============================================================
  Stream<QuerySnapshot> listarPagos() {
    return db
        .collection("pagos")
        .orderBy("fecha", descending: true)
        .snapshots();
  }

  // ============================================================
  // 🔵 4. LISTAR PAGOS POR ESTUDIANTE
  // ============================================================
  Stream<QuerySnapshot> pagosPorEstudiante(String id) {
    return db
        .collection("pagos")
        .where("estudianteId", isEqualTo: id)
        .orderBy("fecha", descending: true)
        .snapshots();
  }

  // ============================================================
  // 🔵 5. LISTAR PAGOS POR GRUPO
  // ============================================================
  Stream<QuerySnapshot> pagosPorGrupo(String grupoId) {
    return db
        .collection("pagos")
        .where("grupoId", isEqualTo: grupoId)
        .orderBy("fecha", descending: true)
        .snapshots();
  }
}
