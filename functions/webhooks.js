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

      // Verificar pago en Mercado Pago
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

      // Extraer metadata y external_reference
      const uid = pago.metadata?.uid;
      const total = pago.metadata?.total ?? 0;
      const externalReference =
        pago.external_reference || pago.metadata?.externalReference || null;

      if (!uid || !externalReference) {
        return res.status(200).send("MISSING UID OR EXTERNAL_REFERENCE");
      }

      // Evitar reprocesar
      const pagoRef = db.collection("pagos").doc(paymentId.toString());
      const pagoSnap = await pagoRef.get();
      if (pagoSnap.exists) {
        return res.status(200).send("ALREADY PROCESSED");
      }

      // Guardar pago (CLAVE: external_reference)
      await pagoRef.set({
        uid,
        total,
        paymentId: paymentId.toString(),
        external_reference: externalReference,
        estado: "aprobado",
        creadoEn: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Leer carrito
      const carritoSnap = await db
        .collection("carritos")
        .doc(uid)
        .collection("items")
        .get();

      if (carritoSnap.empty) {
        return res.status(200).send("CARRITO EMPTY");
      }

      const batch = db.batch();

      carritoSnap.docs.forEach((doc) => {
        const item = doc.data();

        const historialRef = db.collection("historial").doc();
        batch.set(historialRef, {
          uid,
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
          external_reference: externalReference,
          fecha: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (item.estudianteId) {
          const estudianteRef = db
            .collection("estudiantes")
            .doc(item.estudianteId);

          batch.update(estudianteRef, {
            estado: "matriculado",
            matriculaPagada: true,
            fechaPago: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

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
