// functions/webhooks.js

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

const MP_ACCESS_TOKEN = defineSecret("MP_ACCESS_TOKEN");

exports.mpWebhook = onRequest(
  { secrets: [MP_ACCESS_TOKEN] },
  async (req, res) => {
    try {
      const paymentId = req.body?.data?.id;
      if (!paymentId) {
        return res.status(200).send("NO PAYMENT ID");
      }

      // 🔐 Verificar pago real en Mercado Pago
      const mpRes = await fetch(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        {
          headers: {
            Authorization: `Bearer ${MP_ACCESS_TOKEN.value()}`,
          },
        }
      );

      const pago = await mpRes.json();
      if (pago.status !== "approved") {
        return res.status(200).send("NOT APPROVED");
      }

      const { uid, total } = pago.metadata || {};
      if (!uid) {
        return res.status(200).send("METADATA UID MISSING");
      }

      // 🔁 Evitar reprocesar el mismo pago
      const pagoRef = db.collection("pagos").doc(paymentId.toString());
      const pagoSnap = await pagoRef.get();
      if (pagoSnap.exists) {
        return res.status(200).send("ALREADY PROCESSED");
      }

      // 💾 Guardar pago (resumen)
      await pagoRef.set({
        uid,
        total,
        paymentId,
        estado: "aprobado",
        creadoEn: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 📦 Leer carrito COMPLETO
      const carritoSnap = await db
        .collection("carritos")
        .doc(uid)
        .collection("items")
        .get();

      if (carritoSnap.empty) {
        return res.status(200).send("CARRITO EMPTY");
      }

      const batch = db.batch();

      // 🧾 HISTORIAL DETALLADO (1 DOC POR ITEM)
      carritoSnap.docs.forEach((doc) => {
        const item = doc.data();

        const historialRef = db.collection("historial").doc();

        batch.set(historialRef, {
          uid: uid,
          padreId: item.padreId || uid,
          estudianteId: item.estudianteId || null,
          nombreCompleto: item.nombreCompleto || "",
          tipoItem: item.tipoItem || "",
          categoria: item.categoria || "",
          disciplinaNombre: item.disciplinaNombre || "",
          grupoId: item.grupoId || "",
          horarioTexto: item.horarioTexto || "",
          itemId: item.itemId || doc.id,

          montoCategoria: item.montoCategoria || 0,
          montoProrrateo: item.montoProrrateo || 0,
          montoDescuento: item.montoDescuento || 0,
          montoFinal: item.montoFinal || 0,

          paymentId: paymentId.toString(),
          fecha: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 🧹 Marcar para borrar item del carrito
        batch.delete(doc.ref);
      });

      await batch.commit();

      return res.status(200).send("OK");
    } catch (e) {
      console.error("❌ WEBHOOK ERROR", e);
      return res.status(500).send("ERROR");
    }
  }
);
