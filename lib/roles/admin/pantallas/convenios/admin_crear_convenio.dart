//📁 lib/roles/admin/pantallas/convenios/admin_crear_convenio.dart

import 'package:flutter/material.dart';
import '../../../../core/controladores/convenios_controller.dart';
import '../../../../core/modelos/convenio_model.dart';

class AdminCrearConvenio extends StatefulWidget {
  final ConvenioModel? convenioExistente;

  const AdminCrearConvenio({this.convenioExistente, super.key});

  @override
  State<AdminCrearConvenio> createState() => _AdminCrearConvenioState();
}

class _AdminCrearConvenioState extends State<AdminCrearConvenio> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ConveniosController();

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();

  String tipoDescuento = "porcentaje";
  String aplicaEn = "mensualidad";

  bool requiereAsistencia = false;
  bool recuperaDescuento = false;
  bool acumulableConOtros = false;
  bool aplicaUnaVez = false;
  bool permanente = false;

  int asistenciaMinima = 75;
  String penalidadSiFalla = "normal";

  bool editando = false;
  bool cargando = false;

  @override
  void initState() {
    super.initState();

    if (widget.convenioExistente != null) {
      editando = true;
      final c = widget.convenioExistente!;

      _tituloCtrl.text = c.titulo;
      _descripcionCtrl.text = c.descripcion;
      _codigoCtrl.text = c.codigo;
      _valorCtrl.text = c.valorDescuento.toString();

      tipoDescuento = c.tipoDescuento;
      aplicaEn = c.aplicaEn;
      requiereAsistencia = c.requiereAsistencia;
      asistenciaMinima = c.asistenciaMinima;
      penalidadSiFalla = c.penalidadSiFalla;
      recuperaDescuento = c.recuperaDescuentoSiCumple;
      acumulableConOtros = c.acumulableConOtros;
      aplicaUnaVez = c.aplicaUnaVez;
      permanente = c.permanente;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    final data = {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'codigo': _codigoCtrl.text.trim().toUpperCase(),
      'tipoDescuento': tipoDescuento,
      'valorDescuento': double.tryParse(_valorCtrl.text.trim()) ?? 0,
      'aplicaEn': aplicaEn,
      'requiereAsistencia': requiereAsistencia,
      'asistenciaMinima': asistenciaMinima,
      'penalidadSiFalla': penalidadSiFalla,
      'recuperaDescuentoSiCumple': recuperaDescuento,
      'acumulableConOtros': acumulableConOtros,
      'aplicaUnaVez': aplicaUnaVez,
      'permanente': permanente,
      'activo': true,
      'imagenUrl': null,
      'fechaCreacion': DateTime.now(),
    };

    try {
      if (editando) {
        await _controller.editarConvenio(widget.convenioExistente!.id, data);
      } else {
        await _controller.crearConvenio(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(editando ? "Convenio actualizado" : "Convenio creado"),
            backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Convenio" : "Crear Convenio"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (v) => v!.isEmpty ? "Obligatorio" : null,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (v) => v!.isEmpty ? "Obligatorio" : null,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: "Código"),
                validator: (v) => v!.isEmpty ? "Obligatorio" : null,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                initialValue: tipoDescuento,
                decoration:
                    const InputDecoration(labelText: "Tipo de descuento"),
                items: const [
                  DropdownMenuItem(
                      value: "porcentaje", child: Text("Porcentaje (%)")),
                  DropdownMenuItem(
                      value: "monto", child: Text("Monto (S/.)")),
                ],
                onChanged: (v) => setState(() => tipoDescuento = v!),
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _valorCtrl,
                decoration:
                    const InputDecoration(labelText: "Valor del descuento"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Obligatorio" : null,
              ),

              const SizedBox(height: 20),
              DropdownButtonFormField(
                initialValue: aplicaEn,
                decoration:
                    const InputDecoration(labelText: "Aplica en"),
                items: const [
                  DropdownMenuItem(
                      value: "mensualidad", child: Text("Mensualidad")),
                  DropdownMenuItem(
                      value: "matricula", child: Text("Matrícula")),
                  DropdownMenuItem(value: "ambos", child: Text("Ambos")),
                ],
                onChanged: (v) => setState(() => aplicaEn = v!),
              ),

              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text("Acumulable con otros códigos"),
                value: acumulableConOtros,
                onChanged: (v) => setState(() => acumulableConOtros = v),
              ),

              SwitchListTile(
                title: const Text("Requiere asistencia mínima"),
                value: requiereAsistencia,
                onChanged: (v) => setState(() => requiereAsistencia = v),
              ),

              if (requiereAsistencia)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text("Asistencia mínima: $asistenciaMinima%"),
                    Slider(
                      value: asistenciaMinima.toDouble(),
                      min: 50,
                      max: 100,
                      divisions: 50,
                      label: "$asistenciaMinima%",
                      onChanged: (v) =>
                          setState(() => asistenciaMinima = v.toInt()),
                    ),
                  ],
                ),

              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Recupera descuento si vuelve a cumplir"),
                value: recuperaDescuento,
                onChanged: (v) => setState(() => recuperaDescuento = v),
              ),

              SwitchListTile(
                title: const Text("Se aplica solo una vez"),
                value: aplicaUnaVez,
                onChanged: (v) => setState(() => aplicaUnaVez = v),
              ),

              SwitchListTile(
                title: const Text("Convenio permanente"),
                value: permanente,
                onChanged: (v) => setState(() => permanente = v),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: cargando ? null : _guardar,
                child: cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
