// lib/core/modelos/estudiante_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Estudiante {
  // ================= IDENTIDAD =================
  String id;
  String padreId;
  String nombre;
  String apellido;
  String dni;

  // ================= DATOS PERSONALES =================
  DateTime? fechaNacimiento;
  String genero;
  String celular;
  String fotoUrl;

  // ================= ESTADO / MATRÍCULA =================
  String estado;
  bool matriculaPagada;
  DateTime? fechaMatricula;
  DateTime? fechaPago;
  bool activo;

  // ================= ASIGNACIÓN =================
  String disciplinaId;
  String disciplinaNombre;
  String categoria;

  String grupoId;
  String grupoNombre;

  String horarioId;
  String horarioNombre;

  String entrenadorId;
  String entrenadorNombre;

  // ================= MONTOS =================
  double montoCategoria;
  double montoProrrateo;
  double montoDescuento;
  double montoFinal;

  Estudiante({
    required this.id,
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
    required this.activo,

    required this.disciplinaId,
    required this.disciplinaNombre,
    required this.categoria,

    required this.grupoId,
    required this.grupoNombre,

    required this.horarioId,
    required this.horarioNombre,

    required this.entrenadorId,
    required this.entrenadorNombre,

    required this.montoCategoria,
    required this.montoProrrateo,
    required this.montoDescuento,
    required this.montoFinal,
  });

  factory Estudiante.fromMap(Map<String, dynamic> map, String idDocumento) {
    final dniLeido = map["dni"]?.toString().trim() ?? idDocumento;

    return Estudiante(
      id: dniLeido,
      padreId: map["padreId"] ?? "",
      nombre: map["nombre"] ?? "",
      apellido: map["apellido"] ?? "",
      dni: dniLeido,

      fechaNacimiento: map["fechaNacimiento"] is Timestamp
          ? (map["fechaNacimiento"] as Timestamp).toDate()
          : null,

      genero: map["genero"] ?? "",
      celular: map["celular"] ?? "",
      fotoUrl: map["fotoUrl"] ?? "",

      estado: map["estado"] ?? "",
      matriculaPagada: map["matriculaPagada"] ?? false,

      fechaMatricula: map["fechaMatricula"] is Timestamp
          ? (map["fechaMatricula"] as Timestamp).toDate()
          : null,

      fechaPago: map["fechaPago"] is Timestamp
          ? (map["fechaPago"] as Timestamp).toDate()
          : null,

      activo: map["activo"] ?? true,

      disciplinaId: map["disciplinaId"] ?? "",
      disciplinaNombre: map["disciplinaNombre"] ?? "",
      categoria: map["categoria"] ?? "",

      grupoId: map["grupoId"] ?? "",
      grupoNombre: map["grupoNombre"] ?? "",

      horarioId: map["horarioId"] ?? "",
      horarioNombre: map["horarioNombre"] ?? "",

      entrenadorId: map["entrenadorId"] ?? "",
      entrenadorNombre: map["entrenadorNombre"] ?? "",

      montoCategoria: (map["montoCategoria"] ?? 0).toDouble(),
      montoProrrateo: (map["montoProrrateo"] ?? 0).toDouble(),
      montoDescuento: (map["montoDescuento"] ?? 0).toDouble(),
      montoFinal: (map["montoFinal"] ?? 0).toDouble(),
    );
  }

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
      "activo": activo,

      "disciplinaId": disciplinaId,
      "disciplinaNombre": disciplinaNombre,
      "categoria": categoria,

      "grupoId": grupoId,
      "grupoNombre": grupoNombre,

      "horarioId": horarioId,
      "horarioNombre": horarioNombre,

      "entrenadorId": entrenadorId,
      "entrenadorNombre": entrenadorNombre,

      "montoCategoria": montoCategoria,
      "montoProrrateo": montoProrrateo,
      "montoDescuento": montoDescuento,
      "montoFinal": montoFinal,
    };
  }
}
