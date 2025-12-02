//lib/core/modelos/estudiante_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Estudiante {
  String id;            // 🔥 AHORA ESTE ID = DNI
  String padreId;
  String nombre;
  String apellido;
  String dni;

  DateTime? fechaNacimiento;
  String genero;
  String celular;

  String fotoUrl;

  // ESTADO DE MATRÍCULA
  String estado;               
  bool matriculaPagada;        

  DateTime? fechaMatricula;
  DateTime? fechaPago;

  // ASIGNACIÓN (se completará DESPUÉS de pagar)
  String disciplinaId;
  String categoriaId;
  String grupoId;
  String horarioId;
  String entrenadorId;

  // MONTOS
  double montoCategoria;
  double montoProrrateo;
  double montoDescuento;
  double montoFinal;

  bool activo;

  Estudiante({
    required this.id,              // 🔥 Se usará como DNI
    required this.padreId,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.fechaNacimiento,
    required this.genero,
    required this.celular,
    required this.fotoUrl,

    required this.estado,
    required this.matriculaPagada,
    required this.fechaMatricula,
    required this.fechaPago,

    required this.disciplinaId,
    required this.categoriaId,
    required this.grupoId,
    required this.horarioId,
    required this.entrenadorId,

    required this.montoCategoria,
    required this.montoProrrateo,
    required this.montoDescuento,
    required this.montoFinal,

    required this.activo,
  });

  // ===================================================
  // 🔥 CONVERTIR DESDE FIRESTORE HACIA EL MODELO
  //    AQUÍ ES DONDE id = DNI
  // ===================================================
  factory Estudiante.fromMap(Map<String, dynamic> map, String idDocumento) {
    
    // 🔥 idDocumento = DNI porque tú guardas doc(dni)
    final dniLeido = map["dni"]?.toString().trim() ?? idDocumento;

    return Estudiante(
      id: dniLeido,                   // 🔥 ID DEL MODELO = DNI
      padreId: map["padreId"] ?? "",
      nombre: map["nombre"] ?? "",
      apellido: map["apellido"] ?? "",
      dni: dniLeido,                 // 🔥 DNI siempre consistente

      fechaNacimiento: map["fechaNacimiento"] is Timestamp
          ? (map["fechaNacimiento"] as Timestamp).toDate()
          : null,

      genero: map["genero"] ?? "",
      celular: map["celular"] ?? "",
      fotoUrl: map["fotoUrl"] ?? "",

      estado: map["estado"] ?? "registrado",
      matriculaPagada: map["matriculaPagada"] ?? false,

      fechaMatricula: map["fechaMatricula"] is Timestamp
          ? (map["fechaMatricula"] as Timestamp).toDate()
          : null,

      fechaPago: map["fechaPago"] is Timestamp
          ? (map["fechaPago"] as Timestamp).toDate()
          : null,

      disciplinaId: map["disciplinaId"] ?? "",
      categoriaId: map["categoriaId"] ?? "",
      grupoId: map["grupoId"] ?? "",
      horarioId: map["horarioId"] ?? "",
      entrenadorId: map["entrenadorId"] ?? "",

      montoCategoria: (map["montoCategoria"] ?? 0).toDouble(),
      montoProrrateo: (map["montoProrrateo"] ?? 0).toDouble(),
      montoDescuento: (map["montoDescuento"] ?? 0).toDouble(),
      montoFinal: (map["montoFinal"] ?? 0).toDouble(),

      activo: map["activo"] ?? true,
    );
  }

  // ===================================================
  // 🔥 CONVERTIR HACIA FIRESTORE
  // ===================================================
  Map<String, dynamic> toMap() {
    return {
      "padreId": padreId,
      "nombre": nombre,
      "apellido": apellido,
      "dni": dni,

      "fechaNacimiento": fechaNacimiento,
      "genero": genero,
      "celular": celular,
      "fotoUrl": fotoUrl,

      "estado": estado,
      "matriculaPagada": matriculaPagada,
      "fechaMatricula": fechaMatricula,
      "fechaPago": fechaPago,

      "disciplinaId": disciplinaId,
      "categoriaId": categoriaId,
      "grupoId": grupoId,
      "horarioId": horarioId,
      "entrenadorId": entrenadorId,

      "montoCategoria": montoCategoria,
      "montoProrrateo": montoProrrateo,
      "montoDescuento": montoDescuento,
      "montoFinal": montoFinal,

      "activo": activo,
    };
  }
}
