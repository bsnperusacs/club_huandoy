// 📁 Ubicación: lib/roles/padre/pantallas/asistencia/pantalla_marcar_asistencia.dart

import 'package:flutter/material.dart';
import 'package:club_huandoy/core/controladores/asistencias_controller.dart';

class PantallaMarcarAsistencia extends StatefulWidget {
  final String estudianteId;
  final String grupoId;
  final double latCentro;
  final double lngCentro;

  const PantallaMarcarAsistencia({
    super.key,
    required this.estudianteId,
    required this.grupoId,
    required this.latCentro,
    required this.lngCentro,
  });

  @override
  State<PantallaMarcarAsistencia> createState() =>
      _PantallaMarcarAsistenciaState();
}

class _PantallaMarcarAsistenciaState
    extends State<PantallaMarcarAsistencia> {
  bool cargando = false;
  String? mensaje;

  Future<void> marcar() async {
    setState(() {
      cargando = true;
      mensaje = null;
    });

    try {
      await AsistenciasController().registrarPorGeocerca(
        estudianteId: widget.estudianteId,
        grupoId: widget.grupoId,
        latCentro: widget.latCentro,
        lngCentro: widget.lngCentro,
      );

      setState(() {
        mensaje = '✅ Asistencia registrada correctamente';
      });
    } catch (e) {
      setState(() {
        mensaje = e.toString();
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marcar asistencia')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Debes estar dentro del área del centro deportivo (±10 m).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (cargando)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Marcar asistencia'),
                onPressed: marcar,
              ),

            const SizedBox(height: 20),

            if (mensaje != null)
              Text(
                mensaje!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mensaje!.startsWith('✅')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
