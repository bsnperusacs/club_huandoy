// =========================================
//     PAGOS – Cloud Functions V2
// =========================================

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const mercadopago = require("mercadopago");

// 🔐 SECRET DE FIREBASE
const MP_ACCESS_TOKEN = defineSecret("MP_ACCESS_TOKEN");


// =========================================
// 🔵 CREAR PAGO (CHECKOUT)
// =========================================
exports.crearPago = onRequest(
  {
    secrets: [MP_ACCESS_TOKEN], // << NECESARIO para usar secrets
    cors: true,
    timeoutSeconds: 60,
  },
  async (req, res) => {
    try {
      const { estudianteId, monto, descripcion } = req.body;

      if (!estudianteId || !monto) {
        return res.status(400).json({ error: "Datos incompletos." });
      }

      // Configurar SDK dentro de la función
      mercadopago.configure({
        access_token: MP_ACCESS_TOKEN.value(),
      });

      const preference = await mercadopago.preferences.create({
        items: [
          {
            title: descripcion || "Pago Club Huandoy",
            quantity: 1,
            currency_id: "PEN",
            unit_price: Number(monto),
          },
        ],
        metadata: { estudianteId },
      });

      return res.status(200).json({
        init_point: preference.body.init_point,
        id: preference.body.id,
      });

    } catch (e) {
      console.error("❌ Error creando pago:", e);
      return res.status(500).json({ error: "Error interno" });
    }
  }
);


// =========================================
// 🔵 WEBHOOK MERCADO PAGO
// =========================================
exports.mpWebhook = onRequest(
  {
    secrets: [MP_ACCESS_TOKEN],
  },
  async (req, res) => {
    try {
      const data = req.body;

      console.log("📩 Webhook recibido:", data);

      if (data.type === "payment") {
        console.log("💰 Pago confirmado:", data.data.id);
      }

      return res.status(200).send("OK");

    } catch (e) {
      console.error("❌ Error webhook:", e);
      return res.status(500).send("Error interno");
    }
  }
);
