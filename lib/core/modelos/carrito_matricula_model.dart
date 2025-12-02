class CarritoMatricula {
  final List<Map<String, dynamic>> estudiantes;
  final double descuentoPorEstudiante;
  final String? codigoConvenio;

  CarritoMatricula({
    required this.estudiantes,
    required this.descuentoPorEstudiante,
    this.codigoConvenio,
  });
}
