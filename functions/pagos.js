// functions/pagos.js

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { MercadoPagoConfig, Preference } = require("mercadopago");

const MP_ACCESS_TOKEN = defineSecret("MP_ACCESS_TOKEN");

exports.crearPago = onRequest(
  {
    secrets: [MP_ACCESS_TOKEN],
    cors: true,
    timeoutSeconds: 60,
  },
  async (req, res) => {
    try {
      const { estudianteId, monto, descripcion } = req.body;
      const uid = req.headers.uid; // SE MANTIENE: YA LO ENVÍA FLUTTER

      if (!uid || !estudianteId || !monto || monto <= 0) {
        return res.status(400).json({ error: "DATOS INVALIDOS" });
      }

      const client = new MercadoPagoConfig({
        accessToken: MP_ACCESS_TOKEN.value(),
      });

      const preference = new Preference(client);

      const result = await preference.create({
        body: {
          items: [
            {
              title: descripcion || "Pago Club Huandoy",
              quantity: 1,
              currency_id: "PEN",
              unit_price: Number(monto),
            },
          ],
          metadata: {
            uid: uid,              // 🔧 EXPLÍCITO
            estudianteId: estudianteId,
            total: Number(monto),
          },
          notification_url:
            "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/mpWebhook",
        },
      });

      return res.status(200).json({
        init_point: result.init_point,
      });
    } catch (e) {
      console.error("❌ CREAR PAGO ERROR", e);
      return res.status(500).json({ error: "ERROR CREAR PAGO" });
    }
  }
);
