import 'dart:convert';
import 'dart:io';

class ServicioPago {
  /// ======================================================
  /// 🔥 LLAMAR A CLOUD FUNCTION crearPago
  /// ======================================================
  static Future<Map<String, dynamic>> crearPago({
    required String estudianteId,
    required double monto,
    required String descripcion,
  }) async {
    final url = Uri.parse(
      "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/crearPago",
    );

    final payload = jsonEncode({
      "estudianteId": estudianteId,
      "monto": monto,
      "descripcion": descripcion,
    });

    final http = HttpClient();
    final req = await http.postUrl(url);

    req.headers.set("Content-Type", "application/json");
    req.write(payload);

    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();

    return jsonDecode(body);
  }
}
