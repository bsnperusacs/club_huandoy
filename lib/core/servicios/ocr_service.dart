// Archivo: /lib/core/servicios/ocr_service.dart


import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OCRService {
  
  // ============================================================
  // EXPRESIONES REGULARES ESTATICAS (CORRECCIÓN: DEFINICIÓN)
  // ESTA ES LA UBICACIÓN CORRECTA PARA 'static final'.
  // ============================================================
  // ignore: deprecated_member_use
  static final _dniPattern = RegExp(r'\b\d{8}\b');
  // ignore: deprecated_member_use
  static final _fechaPattern = RegExp(r'\d{2}/\d{2}/\d{4}');
  // ignore: deprecated_member_use
  static final _multipleSpacePattern = RegExp(r'\s+');

  // ============================================================
  // PREPROCESAMIENTO ROBUSTO
  // ============================================================
  Future<File> preprocessImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return file;

    // 1. Aumentar resolución (solo si es necesario)
    img.Image enlarged;
    if (original.width < 2200) {
      enlarged = img.copyResize(original, width: 2200);
    } else {
      enlarged = original;
    }

    // 2. Pasar a blanco y negro
    img.Image grayscale = img.grayscale(enlarged);

    // 3. Aumentar contraste y brillo
    img.Image highContrast = img.adjustColor(
      grayscale,
      contrast: 1.5,
      brightness: 0.1,
    );

    // 4. Desenfoque ligero para eliminar ruido
    img.Image denoised = img.gaussianBlur(highContrast, radius: 1);

    // 5. Guardar imagen procesada en un archivo temporal
    final ext = file.path.toLowerCase().endsWith(".png") ? ".png" : ".jpg";
    final resultPath = file.path.replaceAll(ext, "_proc$ext");
    final result = File(resultPath);

    await result.writeAsBytes(
      img.encodeJpg(denoised, quality: 95),
    );

    return result;
  }

  // Utilidad para limpiar el texto extraído
  String _cleanText(String raw) {
    String text = raw.toUpperCase()
        .replaceAll(":", " ")
        .replaceAll(";", " ")
        .replaceAll("\n\n", "\n")
        .replaceAll(_multipleSpacePattern, ' ') // Usando el patrón estático
        .trim();
    return text;
  }
  
  // ============================================================
  // PROCESAR PARTE FRONTAL DEL DNI PERUANO
  // ============================================================
  Future<Map<String, String>> procesarFrontal(File imagen) async {
    final cleanedFile = await preprocessImage(imagen);
    String raw = "";
    try {
      raw = await FlutterTesseractOcr.extractText(
        cleanedFile.path,
        language: 'spa+eng',
        args: { "psm": "6", "oem": "1" },
      );
    } finally {
      // Optimización: Asegurar la eliminación del archivo temporal
      if (await cleanedFile.exists()) {
        await cleanedFile.delete(); 
      }
    }

    String text = _cleanText(raw);

    // Campos detectados: USANDO LOS PATRONES ESTÁTICOS Y ASIGNANDO A VARIABLES LOCALES
    String dni = _dniPattern.stringMatch(text) ?? "";
    String fecha = _fechaPattern.stringMatch(text) ?? "";

    // APELLIDOS
    String apellidos = "";
    if (text.contains("APELLIDOS")) {
      apellidos = _lineAfter(text, "APELLIDOS");
    } else {
      String p = _lineAfter(text, "PRIMER APELLIDO");
      String s = _lineAfter(text, "SEGUNDO APELLIDO");
      apellidos = "$p $s".trim();
    }

    // NOMBRES
    String nombres = "";
    if (text.contains("NOMBRES")) {
      nombres = _lineAfter(text, "NOMBRES");
    }

    // GENERO
    String genero = "";
    if (text.contains("SEXO M")) genero = "Masculino";
    if (text.contains("SEXO F")) genero = "Femenino";

    return {
      "dni": dni,
      "nombres": nombres,
      "apellidos": apellidos,
      "fechaNacimiento": fecha,
      "genero": genero,
    };
  }

  // ============================================================
  // PROCESAR PARTE POSTERIOR DEL DNI PERUANO
  // ============================================================
  Future<Map<String, String>> procesarPosterior(File imagen) async {
    final cleanedFile = await preprocessImage(imagen);
    String raw = "";
    try {
      raw = await FlutterTesseractOcr.extractText(
        cleanedFile.path,
        language: 'spa+eng',
      );
    } finally {
      // Optimización: Asegurar la eliminación del archivo temporal
      if (await cleanedFile.exists()) {
        await cleanedFile.delete(); 
      }
    }

    String txt = _cleanText(raw);
    String direccion = "";

    for (final linea in txt.split("\n")) {
      if (linea.contains("JR") ||
          linea.contains("AV") ||
          linea.contains("CALLE") ||
          linea.contains("MZ") ||
          linea.contains("LOTE") ||
          linea.contains("URB") ||
          linea.contains("PSJE")) {
        direccion = linea.trim();
        break;
      }
    }

    return {
      "direccion": direccion,
    };
  }

  // ============================================================
  // UTILIDADES
  // ============================================================
  String _lineAfter(String full, String key) {
    int index = full.indexOf(key);
    if (index == -1) return "";
    String sub = full.substring(index + key.length).trim();
    return sub.split("\n").first.trim();
  }
}