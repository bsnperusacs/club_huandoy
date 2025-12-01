class Padre {
  final String uid;
  final String nombres;
  final String apellidos;
  final String correo;
  final String tipoDocumento;
  final String numeroDocumento;
  final DateTime fechaNacimiento;
  final String genero;
  final String celular;
  final String? numeroEmergencia;
  final String? contactoEmergencia;
  final String direccion;
  final String? referencia;
  final double latitud;
  final double longitud;
  final String estadoCivil;
  final String numeroHijos;
  final String relacion;
  final String? parentescoOtro;
  final String? codigoConvenio;
  final bool aceptaTerminos;
  final bool registroCompleto;

  Padre({
    required this.uid,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.fechaNacimiento,
    required this.genero,
    required this.celular,
    this.numeroEmergencia,
    this.contactoEmergencia,
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    required this.estadoCivil,
    required this.numeroHijos,
    required this.relacion,
    this.parentescoOtro,
    this.codigoConvenio,
    required this.aceptaTerminos,
    required this.registroCompleto,
  });

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "nombres": nombres,
        "apellidos": apellidos,
        "correo": correo,
        "tipoDocumento": tipoDocumento,
        "numeroDocumento": numeroDocumento,
        "fechaNacimiento": fechaNacimiento.toIso8601String(),
        "genero": genero,
        "celular": celular,
        "numeroEmergencia": numeroEmergencia,
        "contactoEmergencia": contactoEmergencia,
        "direccion": direccion,
        "referencia": referencia,
        "latitud": latitud,
        "longitud": longitud,
        "estadoCivil": estadoCivil,
        "numeroHijos": numeroHijos,
        "relacion": relacion,
        "parentescoOtro": parentescoOtro,
        "codigoConvenio": codigoConvenio,
        "aceptaTerminos": aceptaTerminos,
        "registroCompleto": registroCompleto,
      };
}
