// Archivo: lib/core/widgets/paso_contacto_ubicacion.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../controladores/padre_controller.dart';

class PasoContactoUbicacion extends StatefulWidget {
  final PadreController controller;
  final VoidCallback onAtras;
  final VoidCallback onSiguiente;

  const PasoContactoUbicacion({
    super.key,
    required this.controller,
    required this.onAtras,
    required this.onSiguiente,
  });

  @override
  State<PasoContactoUbicacion> createState() => _PasoContactoUbicacionState();
}

class _PasoContactoUbicacionState extends State<PasoContactoUbicacion> {
  final _formKey = GlobalKey<FormState>();

  final celularCtrl = TextEditingController();
  final emergenciaCtrl = TextEditingController();
  final contactoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final referenciaCtrl = TextEditingController();
  final correoCtrl = TextEditingController();

  bool _cargando = false;

  @override
  void initState() {
    super.initState();

    // 🔥 Correos y celulares sí se precargan
    correoCtrl.text = widget.controller.correoActual ?? "";
    celularCtrl.text = widget.controller.celular ?? "";

    // 🔥 SIEMPRE intentar cargar dirección desde el CACHE (Firestore)
      if (widget.controller.direccion != null &&
          widget.controller.direccion!.trim().isNotEmpty) {
        direccionCtrl.text = widget.controller.direccion!;
      }
  }

  @override
  void dispose() {
    celularCtrl.dispose();
    emergenciaCtrl.dispose();
    contactoCtrl.dispose();
    direccionCtrl.dispose();
    referenciaCtrl.dispose();
    correoCtrl.dispose();
    super.dispose();
  }

  bool get mostrarPersonaContacto {
    final cel = celularCtrl.text.trim();
    final emer = emergenciaCtrl.text.trim();
    return emer.isNotEmpty && cel != emer;
  }

  Future<void> _obtenerDireccion() async {
    if (kIsWeb) return;

    setState(() => _cargando = true);

    try {
      // 🔥 OBTENER GPS REAL (latitud + longitud)
      await widget.controller.obtenerUbicacionConDireccion();

      // 🔥 Cargar dirección real obtenida por GPS
      direccionCtrl.text = widget.controller.direccion ?? "";
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _cargando = false);
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    // 🔥 Validar que dirección NO esté vacía
    if ((widget.controller.direccion ?? "").trim().isEmpty &&
        direccionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes ingresar u obtener la dirección.")),
      );
      return;
    }

    widget.controller.correo = correoCtrl.text.trim();
    widget.controller.celular = celularCtrl.text.trim();
    widget.controller.numeroEmergencia = emergenciaCtrl.text.trim();
    widget.controller.personaContacto =
        mostrarPersonaContacto ? contactoCtrl.text.trim() : null;

    widget.controller.referencia = referenciaCtrl.text.trim();

    // 🔥 Dirección ingresada manualmente o por GPS
    widget.controller.direccion = direccionCtrl.text.trim();

    widget.onSiguiente();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: correoCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Correo"),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: celularCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Celular"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Obligatorio" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: emergenciaCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Número de emergencia (opcional)",
                ),
              ),
              const SizedBox(height: 20),

              if (mostrarPersonaContacto)
                TextFormField(
                  controller: contactoCtrl,
                  decoration:
                      const InputDecoration(labelText: "Persona de contacto"),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Obligatorio" : null,
                ),

              if (mostrarPersonaContacto) const SizedBox(height: 20),

              TextFormField(
                controller: direccionCtrl,
                readOnly: false,
                decoration: const InputDecoration(labelText: "Dirección"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Obligatorio" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: referenciaCtrl,
                decoration: const InputDecoration(
                  labelText: "Referencia (opcional)",
                ),
              ),

              const SizedBox(height: 20),

              if (!kIsWeb)
                ElevatedButton.icon(
                  onPressed: _cargando ? null : _obtenerDireccion,
                  icon: _cargando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.location_on),
                  label: const Text("Obtener ubicación y dirección"),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: widget.onAtras,
                    child: const Text("Atrás"),
                  ),
                  ElevatedButton(
                    onPressed: _continuar,
                    child: const Text("Siguiente"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
