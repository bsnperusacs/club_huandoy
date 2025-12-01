// 📁 lib/roles/admin/pantallas/entrenadores/admin_crear_entrenador.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:club_huandoy/core/controladores/entrenador_controller.dart';
import 'package:club_huandoy/core/controladores/disciplina_controller.dart';
import 'package:club_huandoy/core/modelos/entrenador_model.dart';
import '../../../../core/modelos/disciplina_model.dart';

class AdminCrearEntrenador extends StatefulWidget {
  final EntrenadorModel? entrenadorExistente;

  const AdminCrearEntrenador({this.entrenadorExistente, super.key});

  @override
  State<AdminCrearEntrenador> createState() => _AdminCrearEntrenadorState();
}

class _AdminCrearEntrenadorState extends State<AdminCrearEntrenador> {
  final _formKey = GlobalKey<FormState>();

  final _dniCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  final _controller = EntrenadoresController();
  final _disciplinaController = DisciplinasController();

  List<String> disciplinasSeleccionadas = [];
  bool editando = false;
  bool cargandoApi = false;

  @override
  void initState() {
    super.initState();

    if (widget.entrenadorExistente != null) {
      editando = true;
      final e = widget.entrenadorExistente!;

      _nombresCtrl.text = e.nombres;
      _apellidosCtrl.text = e.apellidos;
      _telefonoCtrl.text = e.telefono;

      disciplinasSeleccionadas = List<String>.from(e.disciplinas);
    }
  }

  // 🔥 Consulta DNI automática
  Future<void> consultarDniAuto(String numero) async {
    if (numero.length != 8) return;

    setState(() => cargandoApi = true);

    final url = Uri.parse(
      "https://script.google.com/macros/s/AKfycbwW1V4T4SG42wZjgZ9UHamz6RT3gUZAgfOIZZOtR4JQuDUo702oO4G7WBMpkDvKhopc/exec"
      "?tipo=dni&numero=$numero",
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final data = jsonData["data"] ?? {};

      _nombresCtrl.text = data["first_name"] ?? "";
      _apellidosCtrl.text =
          "${data["first_last_name"] ?? ""} ${data["second_last_name"] ?? ""}";
    }

    setState(() => cargandoApi = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Entrenador" : "Crear Entrenador"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // DNI
              TextFormField(
                controller: _dniCtrl,
                maxLength: 8,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "DNI"),
                onChanged: consultarDniAuto,
              ),

              if (cargandoApi)
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 12),

              TextFormField(
                controller: _nombresCtrl,
                decoration: const InputDecoration(labelText: "Nombres"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _apellidosCtrl,
                decoration: const InputDecoration(labelText: "Apellidos"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Teléfono"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 25),

              // 🔥 LISTA DE DISCIPLINAS (checkbox)
              const Text(
                "Disciplinas",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              StreamBuilder(
                stream: _disciplinaController.listarDisciplinas(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final disciplinas = docs
                      .map((d) => DisciplinaModel.fromFirestore(d))
                      .toList();

                  return Column(
                    children: disciplinas.map((d) {
                      final seleccionado =
                          disciplinasSeleccionadas.contains(d.id);

                      return CheckboxListTile(
                        title: Text(d.nombre),
                        value: seleccionado,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              disciplinasSeleccionadas.add(d.id);
                            } else {
                              disciplinasSeleccionadas.remove(d.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _guardar,
                child: Text(editando ? "Guardar Cambios" : "Crear Entrenador"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (disciplinasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos una disciplina")),
      );
      return;
    }

    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    if (editando) {
      await _controller.editarEntrenador(
        widget.entrenadorExistente!.id,
        {
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'disciplinas': disciplinasSeleccionadas,
        },
      );
    } else {
      await _controller.crearEntrenador(
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        disciplinas: disciplinasSeleccionadas,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
