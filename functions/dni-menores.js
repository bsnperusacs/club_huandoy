// ================================
// 📁 dni-menores.js (ARREGLADO)
// ================================

const { onRequest } = require("firebase-functions/v2/https");

exports.guardarEstudianteEnSheet = onRequest(async (req, res) => {
  try {
    const { google } = require("googleapis");   // ✔ cargar adentro

    // ID del sheet
    const SPREADSHEET_ID = "1K2NA1NTdwtLN_wobT6Lz8rPrzpJNj4m89pWvi4nnOzxM";

    const {
      dni, nombre, apellido, fechaNacimiento,
      genero, estadoCivil, direccion, celular,
    } = req.body;

    if (!dni) return res.status(400).json({ error: "Falta DNI" });

    // auth dentro
    const auth = new google.auth.GoogleAuth({
      scopes: ["https://www.googleapis.com/auth/spreadsheets"],
    });

    const sheets = google.sheets({
      version: "v4",
      auth: await auth.getClient(),
    });

    const parts = (apellido || "").split(" ");
    const paterno = parts[0] || "";
    const materno = parts.slice(1).join(" ");

    const row = [
      dni,
      nombre ?? "",
      paterno,
      materno,
      `${paterno} ${materno} ${nombre ?? ""}`.trim(),
      fechaNacimiento ?? "",
      estadoCivil ?? "",
      genero ?? "",
      direccion ?? "",
      celular ?? "",
      new Date().toISOString(),
    ];

    await sheets.spreadsheets.values.append({
      spreadsheetId: SPREADSHEET_ID,
      range: "Cache!A:K",
      valueInputOption: "USER_ENTERED",
      requestBody: { values: [row] },
    });

    return res.json({ success: true });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error interno" });
  }
});
