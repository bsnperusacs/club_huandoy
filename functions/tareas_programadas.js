// =========================================
//   TAREAS AUTOMÁTICAS – Cloud Functions V2
// =========================================

const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();


// =======================================================
// 🔵 REVISAR ASISTENCIAS CADA 24 HORAS
// =======================================================
exports.revisarAsistenciasMensuales = onSchedule("every 24 hours", async (event) => {
  console.log("⏳ Ejecutando revisión de asistencias...");

  const padresSnap = await db.collection("padres").get();

  for (const padre of padresSnap.docs) {
    const padreData = padre.data();

    if (!padreData.codigoConvenio) continue;

    const convSnap = await db.collection("convenios").doc(padreData.codigoConvenio).get();
    if (!convSnap.exists) continue;

    const convenio = convSnap.data();

    // Si el convenio requiere asistencia:
    if (convenio.requiereAsistencia) {
      const asistencia = padreData.asistenciaMensual ?? 100;

      if (asistencia < convenio.asistenciaMinima) {
        // BAJA descuento
        await padre.ref.update({
          descuentoAplicado: convenio.descuento / 2,
          motivoCambio: "No cumple asistencia mínima",
        });
      } else {
        // RESTAURA descuento
        await padre.ref.update({
          descuentoAplicado: convenio.descuento,
          motivoCambio: "Asistencia recuperada",
        });
      }
    }
  }

  console.log("✔ Revisión completada");
});
