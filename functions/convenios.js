// =========================================
//     CONVENIOS – Cloud Functions V2
// =========================================

const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// =========================================
// 🔵 VALIDAR CONVENIO
// =========================================
exports.validarConvenio = onRequest(async (req, res) => {
  try {
    const { codigo } = req.body;

    if (!codigo) {
      return res.status(400).json({ error: "Código vacío." });
    }

    const snap = await db
      .collection("convenios")
      .where("codigo", "==", codigo.toUpperCase())
      .where("activo", "==", true)
      .limit(1)
      .get();

    if (snap.empty) {
      return res
        .status(404)
        .json({ valido: false, mensaje: "Código no existe" });
    }

    const data = snap.docs[0].data();

    return res.json({
      valido: true,

      // CAMPOS ACTUALIZADOS SEGÚN TU MODELO DE FLUTTER
      titulo: data.titulo,
      descripcion: data.descripcion,
      codigo: data.codigo,

      tipoDescuento: data.tipoDescuento,            // porcentaje / monto
      valorDescuento: data.valorDescuento,          // número
      aplicaEn: data.aplicaEn,                      // mensualidad / matricula / ambos

      requiereAsistencia: data.requiereAsistencia ?? false,
      asistenciaMinima: data.asistenciaMinima ?? 75,
      penalidadSiFalla: data.penalidadSiFalla ?? "normal",
      recuperaDescuentoSiCumple: data.recuperaDescuentoSiCumple ?? false,

      acumulableConOtros: data.acumulableConOtros ?? false,
      aplicaUnaVez: data.aplicaUnaVez ?? false,
      permanente: data.permanente ?? false,

      imagenUrl: data.imagenUrl ?? null,
    });
  } catch (e) {
    console.error("❌ Error validar convenio:", e);
    return res.status(500).json({ error: "Error interno." });
  }
});
