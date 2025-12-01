// 📁 Ubicación: lib/roles/padre/modelos/estudiante_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Estudiante {
  final String id;
  final String padreId;

  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final String dni;
  final String fotoUrl;

  // 🔥 NUEVOS CAMPOS DEL OCR
  final String genero;
  final String estadoCivil;
  final String direccion;
  final String celular;

  // 🔥 Datos de entrenamiento
  final String deporteId;     
  final String categoriaId;   
  final String grupoId;
  final String horarioId;    
  final String entrenadorId;

  // 🔥 Estado del proceso
  final String estado; // registrado | asignado | pagado

  // 🔥 Datos económicos
  final double montoCategoria;
  final double montoProrrateo;
  final double montoDescuento;
  final double montoFinal;

  // 🔥 Matrícula
  final bool matriculaPagada;
  final DateTime fechaMatricula;
  final DateTime? fechaMatriculaPagada;

  // 🔥 Fechas del proceso
  final DateTime? fechaAsignacion;
  final DateTime? fechaPago;

  // 🔥 Info de pago externo
  final String? idPagoMp;

  final bool activo;

  Estudiante({
    required this.id,
    required this.padreId,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.dni,
    required this.fotoUrl,

    // ⬇ NUEVOS CAMPOS
    required this.genero,
    required this.estadoCivil,
    required this.direccion,
    required this.celular,

    // ENTRENAMIENTO
    required this.deporteId,
    required this.categoriaId,
    required this.grupoId,
    required this.horarioId,
    required this.entrenadorId,

    // ESTADO
    required this.estado,

    // ECONÓMICOS
    required this.montoCategoria,
    required this.montoProrrateo,
    required this.montoDescuento,
    required this.montoFinal,

    // MATRÍCULA
    required this.matriculaPagada,
    required this.fechaMatricula,
    this.fechaMatriculaPagada,

    // PROCESOS
    this.fechaAsignacion,
    this.fechaPago,

    this.idPagoMp,
    required this.activo,
  });

  factory Estudiante.fromMap(Map<String, dynamic> data, String id) {
    return Estudiante(
      id: id,
      padreId: data['padreId'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      fechaNacimiento: DateTime.parse(data['fechaNacimiento']),
      dni: data['dni'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',

      // ⬇ NUEVOS CAMPOS
      genero: data['genero'] ?? '',
      estadoCivil: data['estadoCivil'] ?? '',
      direccion: data['direccion'] ?? '',
      celular: data['celular'] ?? '',

      // ENTRENAMIENTO
      deporteId: data['deporteId'] ?? '',
      categoriaId: data['categoriaId'] ?? '',
      grupoId: data['grupoId'] ?? '',
      horarioId: data['horarioId'] ?? '',
      entrenadorId: data['entrenadorId'] ?? '',

      estado: data['estado'] ?? 'registrado',

      montoCategoria: (data['montoCategoria'] ?? 0).toDouble(),
      montoProrrateo: (data['montoProrrateo'] ?? 0).toDouble(),
      montoDescuento: (data['montoDescuento'] ?? 0).toDouble(),
      montoFinal: (data['montoFinal'] ?? 0).toDouble(),

      matriculaPagada: data['matriculaPagada'] ?? false,
      fechaMatricula: DateTime.parse(data['fechaMatricula']),
      fechaMatriculaPagada: data['fechaMatriculaPagada'] != null
          ? DateTime.parse(data['fechaMatriculaPagada'])
          : null,

      fechaAsignacion: data['fechaAsignacion'] != null
          ? DateTime.parse(data['fechaAsignacion'])
          : null,
      fechaPago: data['fechaPago'] != null
          ? DateTime.parse(data['fechaPago'])
          : null,

      idPagoMp: data['idPagoMp'],
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'padreId': padreId,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'dni': dni,
      'fotoUrl': fotoUrl,

      // ⬇ NUEVOS CAMPOS
      'genero': genero,
      'estadoCivil': estadoCivil,
      'direccion': direccion,
      'celular': celular,

      // ENTRENAMIENTO
      'deporteId': deporteId,
      'categoriaId': categoriaId,
      'grupoId': grupoId,
      'horarioId': horarioId,
      'entrenadorId': entrenadorId,

      // ESTADO
      'estado': estado,
      'montoCategoria': montoCategoria,
      'montoProrrateo': montoProrrateo,
      'montoDescuento': montoDescuento,
      'montoFinal': montoFinal,

      'matriculaPagada': matriculaPagada,
      'fechaMatricula': fechaMatricula.toIso8601String(),
      'fechaMatriculaPagada': fechaMatriculaPagada?.toIso8601String(),
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
      'fechaPago': fechaPago?.toIso8601String(),

      'idPagoMp': idPagoMp,
      'activo': activo,
    };
  }
}
