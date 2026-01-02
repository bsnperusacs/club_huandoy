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

  const AdminCrearEntrenador({super.key, this.entrenadorExistente});

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

      _dniCtrl.text = e.id; // 🔥 DNI = ID
      _nombresCtrl.text = e.nombres;
      _apellidosCtrl.text = e.apellidos;
      _telefonoCtrl.text = e.telefono;
      disciplinasSeleccionadas = List<String>.from(e.disciplinas);
    }
  }

  // =============================
  // CONSULTA DNI (RENIEC)
  // =============================
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

  // =============================
  // GUARDAR ENTRENADOR
  // =============================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dniCtrl.text.trim().length != 8) {
      _alerta("DNI inválido");
      return;
    }

    if (disciplinasSeleccionadas.isEmpty) {
      _alerta("Selecciona al menos una disciplina");
      return;
    }

    final dni = _dniCtrl.text.trim();
    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    if (editando) {
      await _controller.editarEntrenador(
        dni, // 🔥 ID = DNI
        {
          'dni': dni,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'disciplinas': disciplinasSeleccionadas,
          'activo': true,
        },
      );
    } else {
      await _controller.crearEntrenador(
        dni: dni, // 🔥 ID = DNI
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        disciplinas: disciplinasSeleccionadas,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _alerta(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // =============================
  // UI
  // =============================
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
                enabled: !editando,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "DNI"),
                onChanged: consultarDniAuto,
                validator: (v) =>
                    v != null && v.length == 8 ? null : "DNI inválido",
              ),

              if (cargandoApi)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),

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

              const SizedBox(height: 24),

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

                  final disciplinas = snapshot.data!.docs
                      .map((d) => DisciplinaModel.fromFirestore(d))
                      .toList();

                  return Column(
                    children: disciplinas.map((d) {
                      final sel = disciplinasSeleccionadas.contains(d.id);
                      return CheckboxListTile(
                        title: Text(d.nombre),
                        value: sel,
                        onChanged: (v) {
                          setState(() {
                            v == true
                                ? disciplinasSeleccionadas.add(d.id)
                                : disciplinasSeleccionadas.remove(d.id);
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child:
                      Text(editando ? "Guardar Cambios" : "Crear Entrenador"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
