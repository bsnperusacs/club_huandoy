// Archivo: lib/core/widgets/paso_final.dart

import 'package:flutter/material.dart';
import '../controladores/padre_controller.dart';

class PasoFinal extends StatefulWidget {
  final PadreController controller;
  final VoidCallback onAtras;
  final Future<void> Function() onGuardar;

  const PasoFinal({
    super.key,
    required this.controller,
    required this.onAtras,
    required this.onGuardar,
  });

  @override
  State<PasoFinal> createState() => _PasoFinalState();
}

class _PasoFinalState extends State<PasoFinal> {
  final _formKey = GlobalKey<FormState>();

  String? _estadoCivil;
  final _numHijosCtrl = TextEditingController();
  String? _relacionSeleccionada;
  final _parentescoOtroCtrl = TextEditingController();
  bool _aceptaTerminos = false;

  bool get _mostrarParentescoOtro => _relacionSeleccionada == "Otro";

  @override
  void initState() {
    super.initState();

    // ==========================
    // CARGA DESDE CACHE
    // ==========================
    _estadoCivil = widget.controller.estadoCivil;
    _numHijosCtrl.text = widget.controller.numeroHijos ?? "";
    _relacionSeleccionada = widget.controller.relacion;
    _aceptaTerminos = widget.controller.aceptaTerminos;

    // ==========================
    // NORMALIZAR ESTADO CIVIL
    // ==========================
    if (_estadoCivil != null) {
      _estadoCivil = _estadoCivil!.trim();

      const opcionesValidas = [
        "Soltero",
        "Casado",
        "Divorciado",
        "Viudo"
      ];

      if (!opcionesValidas.contains(_estadoCivil)) {
        _estadoCivil = null;
      }
    }

    // ==========================
    // NORMALIZAR RELACIÓN
    // ==========================
    if (_relacionSeleccionada != null) {
      _relacionSeleccionada = _relacionSeleccionada!.trim();

      const relacionesValidas = [
        "Padre",
        "Madre",
        "Tío",
        "Padrino",
        "Tutor",
        "Otro",
      ];

      if (!relacionesValidas.contains(_relacionSeleccionada)) {
        _relacionSeleccionada = null;
      }

      if (_relacionSeleccionada == "Otro") {
        _parentescoOtroCtrl.text =
            widget.controller.parentescoOtro ?? "";
      }
    }
  }

  @override
  void dispose() {
    _numHijosCtrl.dispose();
    _parentescoOtroCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debes aceptar los términos")));
      return;
    }

    widget.controller.estadoCivil = _estadoCivil;
    widget.controller.numeroHijos = _numHijosCtrl.text.trim();
    widget.controller.relacion = _relacionSeleccionada;
    widget.controller.parentescoOtro =
        _mostrarParentescoOtro ? _parentescoOtroCtrl.text.trim() : null;
    widget.controller.aceptaTerminos = _aceptaTerminos;

    await widget.onGuardar();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ==========================
              // ESTADO CIVIL
              // ==========================
              DropdownButtonFormField<String>(
                value: _estadoCivil,
                decoration: const InputDecoration(labelText: "Estado civil"),
                items: const [
                  DropdownMenuItem(value: "Soltero", child: Text("Soltero")),
                  DropdownMenuItem(value: "Casado", child: Text("Casado")),
                  DropdownMenuItem(value: "Divorciado", child: Text("Divorciado")),
                  DropdownMenuItem(value: "Viudo", child: Text("Viudo")),
                ],
                onChanged: (v) => setState(() => _estadoCivil = v),
                validator: (v) => v == null ? "Obligatorio" : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // NUMERO DE HIJOS
              // ==========================
              TextFormField(
                controller: _numHijosCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Número de hijos"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Obligatorio" : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // RELACIÓN CON EL ALUMNO
              // ==========================
              DropdownButtonFormField<String>(
                value: _relacionSeleccionada,
                decoration:
                    const InputDecoration(labelText: "Relación con el alumno"),
                items: const [
                  DropdownMenuItem(value: "Padre", child: Text("Padre")),
                  DropdownMenuItem(value: "Madre", child: Text("Madre")),
                  DropdownMenuItem(value: "Tío", child: Text("Tío")),
                  DropdownMenuItem(value: "Padrino", child: Text("Padrino")),
                  DropdownMenuItem(value: "Tutor", child: Text("Tutor")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
                onChanged: (v) {
                  setState(() {
                    _relacionSeleccionada = v;
                    if (v != "Otro") {
                      _parentescoOtroCtrl.clear();
                    }
                  });
                },
                validator: (v) => v == null ? "Obligatorio" : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // OTRO PARENTESCO
              // ==========================
              if (_mostrarParentescoOtro)
                TextFormField(
                  controller: _parentescoOtroCtrl,
                  decoration: const InputDecoration(labelText: "Otro parentesco"),
                  validator: (v) {
                    if (_mostrarParentescoOtro &&
                        (v == null || v.trim().isEmpty)) {
                      return "Obligatorio";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "TÉRMINOS Y CONDICIONES:\n\n"
                  "La información brindada tiene carácter de DECLARACIÓN JURADA "
                  "y es responsabilidad del padre/tutor.",
                ),
              ),

              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (v) =>
                        setState(() => _aceptaTerminos = v ?? false),
                  ),
                  const Expanded(
                    child: Text("He leído y acepto los términos."),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                      onPressed: widget.onAtras, child: const Text("Atrás")),
                  ElevatedButton(
                    onPressed: _guardar,
                    child: const Text("Guardar"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
