// Archivo: lib/core/widgets/paso_identificacion.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../controladores/padre_controller.dart';
import '../servicios/ocr_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasoIdentificacion extends StatefulWidget {
  final PadreController controller;
  final VoidCallback onSiguiente;

  const PasoIdentificacion({
    super.key,
    required this.controller,
    required this.onSiguiente,
  });

  @override
  State<PasoIdentificacion> createState() => _PasoIdentificacionState();
}

class _PasoIdentificacionState extends State<PasoIdentificacion> {
  
  bool generoBloqueado = false;
  
  final _formKey = GlobalKey<FormState>();
  final numeroCtrl = TextEditingController();
  final nombresCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final fechaNacimientoCtrl = TextEditingController();
  final generoCtrl = TextEditingController();
  final convenioCtrl = TextEditingController();

  Timer? _timerBusqueda;
  bool _dniNoEncontrado = false;

  String tipoDoc = "DNI";
  final OCRService ocr = OCRService();

  @override
  void initState() {
    super.initState();

    // CARGAR CACHE
    numeroCtrl.text = widget.controller.numeroDocumento ?? "";
    nombresCtrl.text = widget.controller.nombres ?? "";
    apellidosCtrl.text = widget.controller.apellidos ?? "";
    generoCtrl.text = widget.controller.genero ?? "";
      if (generoCtrl.text.isNotEmpty) {
       generoBloqueado = true; // ← BLOQUEA SOLO SI VIENE DEL CACHE
      }
    convenioCtrl.text = widget.controller.codigoConvenio ?? "";

    if (widget.controller.fechaNacimiento != null) {
      final f = widget.controller.fechaNacimiento!;
      fechaNacimientoCtrl.text =
          "${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}";
    }

    // ⚠ SI YA HAY DNI EN CACHE → VOLVER A BUSCAR AUTOMÁTICAMENTE
    if ((widget.controller.numeroDocumento ?? "").length == 8) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buscarDatosAPI(widget.controller.numeroDocumento!);
      });
    }
  }

  @override
  void dispose() {
    numeroCtrl.dispose();
    nombresCtrl.dispose();
    apellidosCtrl.dispose();
    fechaNacimientoCtrl.dispose();
    generoCtrl.dispose();
    convenioCtrl.dispose();
    _timerBusqueda?.cancel();
    super.dispose();
  }

  // ================================
  // CONSULTA API
  // ================================
  Future<bool> _buscarDatosAPI(String numero) async {
    final ok = await widget.controller.consultarDocumentoAuto("DNI", numero);

    if (!ok) {
  _dniNoEncontrado = true;
  setState(() {});
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("DNI no se encuentra. Por favor verificar o contactar con soporte."),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );

  return false;
}


    _dniNoEncontrado = false;

    nombresCtrl.text = widget.controller.nombres ?? "";
    apellidosCtrl.text = widget.controller.apellidos ?? "";

    if (widget.controller.fechaNacimiento != null) {
      final f = widget.controller.fechaNacimiento!;
      fechaNacimientoCtrl.text =
          "${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}";
    }

    generoCtrl.text = widget.controller.genero ?? "";

    setState(() {});
    return true;
  }

 void _onNumeroChange(String numero) {
  if (numero.length < 8) {
    nombresCtrl.clear();
    apellidosCtrl.clear();
    fechaNacimientoCtrl.clear();
    generoCtrl.clear();

    widget.controller.nombres = null;
    widget.controller.apellidos = null;
    widget.controller.fechaNacimiento = null;
    widget.controller.genero = null;

    setState(() {});
    return;
  }

  // ⚠ SOLO consultar API cuando tenga los 8 dígitos exactos
  if (numero.length == 8) {
    _timerBusqueda?.cancel();
    _timerBusqueda = Timer(const Duration(milliseconds: 500), () async {
      await _buscarDatosAPI(numero);
    });
  }
}

  // ================================
  // PICK FECHA MANUAL
  // ================================
  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      initialDate: widget.controller.fechaNacimiento ?? DateTime(2000),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      widget.controller.fechaNacimiento = picked;
      fechaNacimientoCtrl.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {});
    }
  }

  // ================================
  // OCR
  // ================================
  Future<void> _procesarOCRForce() async {
    if (kIsWeb) return;

    if (tipoDoc != "DNI") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OCR solo para DNI."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ingresado = numeroCtrl.text.trim();
    if (ingresado.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingrese DNI válido."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final frontal = await picker.pickImage(source: ImageSource.camera);
    if (frontal == null) return;

    final dataF = await ocr.procesarFrontal(File(frontal.path));
    final dniOCR = dataF["dni"];

    if (dniOCR == null || dniOCR != ingresado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("DNI escaneado no coincide."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    nombresCtrl.text = dataF["nombres"] ?? "";
    apellidosCtrl.text = dataF["apellidos"] ?? "";

    widget.controller.numeroDocumento = dniOCR;
    widget.controller.nombres = dataF["nombres"];
    widget.controller.apellidos = dataF["apellidos"];

    setState(() {});
  }

  // ================================
  // VALIDAR CONVENIO
  // ================================
  Future<bool> _validarConvenio(String codigo) async {
    if (codigo.trim().isEmpty) return true;

    final snap = await FirebaseFirestore.instance
        .collection("convenios")
        .doc(codigo.trim())
        .get();
    return snap.exists;
  }

  // ================================
  // SIGUIENTE
  // ================================
  Future<void> _continuar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await _validarConvenio(convenioCtrl.text);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código de convenio inválido.")),
      );
      return;
    }

    widget.controller.tipoDocumento = tipoDoc;
    widget.controller.numeroDocumento = numeroCtrl.text.trim();
    widget.controller.codigoConvenio = convenioCtrl.text.trim();

    widget.controller.nombres = nombresCtrl.text.trim();
    widget.controller.apellidos = apellidosCtrl.text.trim();
    widget.controller.genero = generoCtrl.text.trim();

    // ❗ YA NO BORRO FECHA NACIMIENTO
    // widget.controller.fechaNacimiento = null;

    widget.onSiguiente();
  }

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const Center(child: Text("Solo móvil."));

    final bool esDni = tipoDoc == "DNI";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Tipo de documento"),
                value: tipoDoc,
                items: const [
                  DropdownMenuItem(value: "DNI", child: Text("DNI")),
                  DropdownMenuItem(value: "CE", child: Text("Carnet de Extranjería")),
                  DropdownMenuItem(value: "PASAPORTE", child: Text("Pasaporte")),
                  DropdownMenuItem(value: "PTP", child: Text("PTP")),
                ],
                onChanged: (v) {
                  setState(() {
                    tipoDoc = v!;
                    numeroCtrl.clear();
                    nombresCtrl.clear();
                    apellidosCtrl.clear();
                    fechaNacimientoCtrl.clear();
                    generoCtrl.clear();
                    _dniNoEncontrado = false;
                  });
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: numeroCtrl,
                      decoration: InputDecoration(
                        labelText: "Número de documento",
                        errorText: _dniNoEncontrado ? "DNI no encontrado" : null,
                      ),
                      onChanged: _onNumeroChange,
                      validator: (v) => (v == null || v.isEmpty) ? "Obligatorio" : null,
                    ),
                  ),
                  const SizedBox(width: 10),

                  if (esDni)
                    IconButton(
                      tooltip: "Escanear DNI",
                      icon: const Icon(Icons.document_scanner, size: 32),
                      onPressed: _procesarOCRForce,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nombresCtrl,
                readOnly: esDni,
                decoration: InputDecoration(
                  labelText: "Nombres",
                  suffixIcon: esDni ? const Icon(Icons.lock) : null,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: apellidosCtrl,
                readOnly: esDni,
                decoration: InputDecoration(
                  labelText: "Apellidos",
                  suffixIcon: esDni ? const Icon(Icons.lock) : null,
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: _seleccionarFecha,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: fechaNacimientoCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: "Fecha de nacimiento"),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
  value: generoCtrl.text.isNotEmpty ? generoCtrl.text : null,
  decoration: InputDecoration(
    labelText: "Género",
    suffixIcon: generoBloqueado ? const Icon(Icons.lock) : null,
  ),
  items: const [
    DropdownMenuItem(value: "MASCULINO", child: Text("Masculino")),
    DropdownMenuItem(value: "FEMENINO", child: Text("Femenino")),
  ],
  onChanged: generoBloqueado
      ? null
      : (v) {
          generoCtrl.text = v!;
          widget.controller.genero = v;
          generoBloqueado = false;
          setState(() {});
        },
  validator: (v) => (v == null || v.isEmpty) ? "Obligatorio" : null,
),


              const SizedBox(height: 16),

              TextFormField(
                controller: convenioCtrl,
                decoration:
                    const InputDecoration(labelText: "Código de convenio (opcional)"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _continuar,
                child: const Text("Siguiente"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
