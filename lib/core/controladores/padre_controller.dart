// Archivo: lib/core/controladores/padre_controller.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class PadreController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String apiBase =
      "https://api-central-bsn-470844029832.us-central1.run.app";

  // ============================================================
  // CAMPOS
  // ============================================================
  String? tipoDocumento;
  String? numeroDocumento;
  String? nombres;
  String? apellidos;
  DateTime? fechaNacimiento;
  String? genero;

  String? correo;
  String? celular;
  String? numeroEmergencia;
  String? personaContacto;

  // DIRECCIONES
  String? direccion;            // Dirección REAL (GPS/manual)
  String? direccionDocumento;   // Dirección del DNI / CACHE
  String? referencia;

  double? latitud;
  double? longitud;

  String? estadoCivil;
  String? numeroHijos;
  String? relacion;
  String? parentescoOtro;

  String? codigoConvenio;
  bool aceptaTerminos = false;

  // FLAGS
  bool existeDatos = false;
  bool mostrarOCR = false;

  // ============================================================
  // CARGAR DESDE FIRESTORE SI EXISTE
  // ============================================================
  Future<void> cargarPadreSiExiste(String numero) async {
    try {
      final snap = await _db
          .collection("padres")
          .where("numeroDocumento", isEqualTo: numero)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return;

      final data = snap.docs.first.data();

      direccion = data["direccion"];
      referencia = data["referencia"];
      celular = data["celular"];
      numeroEmergencia = data["numeroEmergencia"];
      personaContacto = data["personaContacto"];
      estadoCivil = data["estadoCivil"];
      numeroHijos = data["numeroHijos"];
      relacion = data["relacion"];
      parentescoOtro = data["parentescoOtro"];
      latitud = data["latitud"];
      longitud = data["longitud"];

    } catch (_) {}
  }

  // ============================================================
  // CONSULTA API + CACHE
  // ============================================================
  Future<bool> consultarDocumentoAuto(String tipoDoc, String numero) async {
    // PRIMERO cargar desde Firestore si existe
    await cargarPadreSiExiste(numero);

    final url = Uri.parse(
        "$apiBase/?tipo=${tipoDoc.toLowerCase()}&numero=$numero");

    final res = await http.get(url);

    if (res.statusCode != 200) {
      existeDatos = false;
      mostrarOCR = true;
      return false;
    }

    final jsonData = jsonDecode(res.body);
    final data = jsonData["data"];

    if (data == null || data.isEmpty) {
      existeDatos = false;
      mostrarOCR = true;
      return false;
    }

    existeDatos = true;
    mostrarOCR = false;

    // MAPEO
    if (tipoDoc == "DNI") {
      numeroDocumento = data["document_number"] ?? numero;

      nombres = data["first_name"] ?? "";
      final ape1 = data["first_last_name"] ?? "";
      final ape2 = data["second_last_name"] ?? "";
      apellidos = "$ape1 $ape2".trim();

      // Fecha nacimiento
      if (data["fecha_nacimiento"] != null &&
          data["fecha_nacimiento"].toString().trim().isNotEmpty) {
        final raw = data["fecha_nacimiento"];
        String fix = raw;

        if (raw.contains(" 0:")) {
          fix = raw.replaceAll(" 0:", " 00:");
        }

        fix = fix.replaceAll(" ", "T");
        fechaNacimiento = DateTime.tryParse(fix);
      }

      genero = data["genero"] ?? "";

      // 🔥 DIRECCIÓN DEL CACHE/API
      final dirCache = data["direccion"] ?? "";
      direccionDocumento = dirCache;

      // SI viene dirección del cache → usarla directamente
      if (dirCache.trim().isNotEmpty) {
        direccion = dirCache;
      }

      celular = data["celular"] ?? "";
      estadoCivil = data["estado_civil"] ?? "";

    } else {
      numeroDocumento = data["numero_documento"] ?? numero;
      nombres = data["razon_social"] ?? "";
      apellidos = "";
      direccionDocumento = data["direccion"] ?? "";
    }

    return true;
  }

  // ============================================================
  // UBICACIÓN + DIRECCIÓN GPS
  // ============================================================
  Future<void> obtenerUbicacionConDireccion() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw "El GPS está desactivado.";

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw "Permiso de ubicación denegado";
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw "No tienes permisos de ubicación.";
    }

    direccion = null;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitud = pos.latitude;
    longitud = pos.longitude;

    await _asignarDireccion();
  }

  Future<void> _asignarDireccion() async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latitud!, longitud!);
      if (placemarks.isEmpty) return;

      final p = placemarks.first;

      direccion = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea
      ]
          .where((e) => e != null && e.trim().isNotEmpty)
          .join(", ");

    } catch (_) {
      direccion = "Dirección no encontrada";
    }
  }

  // ============================================================
  // GUARDAR EN FIRESTORE
  // ============================================================
  Future<void> guardarEnFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw "Usuario no autenticado";

    await _db.collection("padres").doc(uid).set({
      "uid": uid,
      "correo": correoActual,

      "tipoDocumento": tipoDocumento,
      "numeroDocumento": numeroDocumento,
      "nombres": nombres,
      "apellidos": apellidos,
      "fechaNacimiento": fechaNacimiento?.toIso8601String(),
      "genero": genero,

      "direccion": direccion,
      "direccionDocumento": direccionDocumento,

      "latitud": latitud,
      "longitud": longitud,
      "referencia": referencia,
      "celular": celular,
      "numeroEmergencia": numeroEmergencia,
      "personaContacto": personaContacto,
      "estadoCivil": estadoCivil,
      "numeroHijos": numeroHijos,
      "relacion": relacion,
      "parentescoOtro": parentescoOtro,
      "aceptaTerminos": aceptaTerminos,

      "fechaRegistro": FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // CACHE
  // ============================================================
  Future<void> enviarDatosAlCache() async {
    if (numeroDocumento == null || numeroDocumento!.isEmpty) return;

    final url = Uri.parse("$apiBase/actualizar");

    final direccionFinal =
        (direccion != null && direccion!.trim().isNotEmpty)
            ? direccion!.trim()
            : (direccionDocumento ?? "");

    final body = {
      "pk": numeroDocumento!,
      "tipo": tipoDocumento?.toLowerCase(),
      "data": {
        "fecha_nacimiento": fechaNacimiento?.toIso8601String() ?? "",
        "genero": genero ?? "",
        "direccion": direccionFinal,
        "celular": celular ?? "",
        "estado_civil": estadoCivil ?? "",
      }
    };

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  // GETTERS
  String? get uidActual => _auth.currentUser?.uid;
  String? get correoActual => _auth.currentUser?.email;
}
