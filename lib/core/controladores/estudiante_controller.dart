// ===============================================
// 📁 FILE: lib/core/controladores/estudiante_controller.dart
// ===============================================

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EstudianteController {
  final picker = ImagePicker();
  String fotoUrl = "";
  File? imagenSeleccionada;

  final String apiBase =
      "https://api-central-bsn-470844029832.us-central1.run.app";

  // ==========================================================
  // LIMPIAR CACHE LOCAL (foto + url)
  // ==========================================================
  void limpiarCacheLocal() {
    imagenSeleccionada = null;
    fotoUrl = "";
  }

  // ==========================================================
  // SELECCIONAR IMAGEN
  // ==========================================================
  Future<void> seleccionarImagen() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      imagenSeleccionada = File(picked.path);
    }
  }

  // ==========================================================
  // TOMAR FOTO
  // ==========================================================
  Future<void> tomarFoto() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (picked != null) {
      imagenSeleccionada = File(picked.path);
    }
  }

  // ==========================================================
  // SUBIR FOTO A STORAGE
  // ==========================================================
  Future<String> subirFoto(String estudianteId) async {
    if (imagenSeleccionada == null) return "";

    final padreId = FirebaseAuth.instance.currentUser!.uid;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child("estudiantes/$padreId/$estudianteId/foto.jpg");

    await storageRef.putFile(imagenSeleccionada!);

    fotoUrl = await storageRef.getDownloadURL();
    return fotoUrl;
  }

  // ==========================================================
  // CONSULTAR CACHE (API CENTRAL BSN)
  // ==========================================================
  Future<Map<String, dynamic>> consultarCacheEstudiante(String dni) async {
    final url = Uri.parse("$apiBase/?tipo=dni&numero=$dni");

    final res = await http.get(url);

    if (res.statusCode != 200) return {};

    final body = jsonDecode(res.body);

    if (body["data"] == null) return {};

    return body["data"];
  }

  // ==========================================================
  // CONSULTAR SHEET
  // ==========================================================
  Future<Map<String, dynamic>> consultarSheetEstudiante(String dni) async {
    final url = Uri.parse("$apiBase/?tipo=estudiante&numero=$dni");

    final res = await http.get(url);

    if (res.statusCode != 200) return {};

    final body = jsonDecode(res.body);

    if (body["data"] == null) return {};

    return body["data"];
  }

  // ==========================================================
  // GUARDAR SHEET (CORREGIDO para usar la ruta /guardar y tipo estudiante)
  // ==========================================================
  Future<void> guardarSheetEstudiante({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String genero,
    required String estadoCivil,
    required String direccion,
    required String celular,
  }) async {
    final url = Uri.parse("$apiBase/guardar"); // RUTA CORRECTA

    final body = {
      "tipo": "estudiante", // TIPO CORRECTO
      "dni": dni,
      "nombre": nombre,
      "apellido": apellido,
      "fechaNacimiento": fechaNacimiento,
      "genero": genero,
      "estadoCivil": estadoCivil,
      "direccion": direccion,
      "celular": celular,
    };

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  // ==========================================================
  // GUARDAR EN CACHE (Esta función usa la ruta /actualizar y tipo dni)
  // ==========================================================
  Future<void> guardarDatosEstudianteEnCache({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String genero,
    required String estadoCivil,
    required String direccion,
    required String celular,
  }) async {
    final url = Uri.parse("$apiBase/actualizar");

    final partes = apellido.trim().split(" ");
    final paterno = partes.isNotEmpty ? partes[0] : "";
    final materno = partes.length > 1 ? partes.sublist(1).join(" ") : "";

    final body = {
      "pk": dni,
      "tipo": "dni",
      "data": {
        "document_number": dni,
        "first_name": nombre,
        "first_last_name": paterno,
        "second_last_name": materno,
        "full_name": "$paterno $materno $nombre".trim(),
        "fecha_nacimiento":
            DateTime.parse(fechaNacimiento).toIso8601String(),
        "genero": genero,
        "estado_civil": estadoCivil,
        "direccion": direccion,
        "celular": celular,
        "es_estudiante": true,
      }
    };

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  // ==========================================================
  // GUARDAR OCR (llama a guardarDatosEstudianteEnCache)
  // ==========================================================
  Future<void> guardarDatosOcrEnApi({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String genero,
    required String estadoCivil,
    required String direccion,
    String? celular,
  }) async {
    return guardarDatosEstudianteEnCache(
      dni: dni,
      nombre: nombre,
      apellido: apellido,
      fechaNacimiento: fechaNacimiento,
      genero: genero,
      estadoCivil: estadoCivil,
      direccion: direccion,
      celular: celular ?? "",
    );
  }

  // ==========================================================
  // 📌 NUEVO — ENVIAR A CACHE + SHEET (IGUAL QUE PADRE)
  // ==========================================================
  Future<void> enviarDatosAlCacheEstudiante({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String genero,
    required String estadoCivil,
    required String direccion,
    required String celular,
  }) async {
    // → 1. Guardar en CACHE (API BSN)
    await guardarDatosEstudianteEnCache(
      dni: dni,
      nombre: nombre,
      apellido: apellido,
      fechaNacimiento: fechaNacimiento,
      genero: genero,
      estadoCivil: estadoCivil,
      direccion: direccion,
      celular: celular,
    );

    // → 2. Guardar en Google Sheet si no existe
    await consultarYGestionarEstudianteSheet(
      dni: dni,
      nombre: nombre,
      apellido: apellido,
      fechaNacimiento: fechaNacimiento,
      genero: genero,
      estadoCivil: estadoCivil,
      direccion: direccion,
      celular: celular,
    );
  }

  // ==========================================================
  // SHEET: SI NO EXISTE → GUARDAR
  // ==========================================================
  Future<void> consultarYGestionarEstudianteSheet({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String genero,
    required String estadoCivil,
    required String direccion,
    required String celular,
  }) async {
    final existe = await consultarSheetEstudiante(dni);

    if (existe.isEmpty) {
      await guardarSheetEstudiante(
        dni: dni,
        nombre: nombre,
        apellido: apellido,
        fechaNacimiento: fechaNacimiento,
        genero: genero,
        estadoCivil: estadoCivil,
        direccion: direccion,
        celular: celular,
      );
    }
  }

  // ==========================================================
  // REGISTRAR FIRESTORE
  // ==========================================================
  Future<void> registrarEstudiante(Estudiante estudiante) async {
    await FirebaseFirestore.instance
        .collection("estudiantes")
        .doc(estudiante.id)
        .set(estudiante.toMap());
  }
}