// 📁 Ubicación: lib/roles/admin/pantallas/disciplinas/admin_crear_disciplina.dart

import 'package:flutter/material.dart';
import 'package:club_huandoy/core/controladores/disciplina_controller.dart';
import 'package:club_huandoy/core/modelos/disciplina_model.dart';

class AdminCrearDisciplina extends StatefulWidget {
  final DisciplinaModel? disciplinaExistente;

  const AdminCrearDisciplina({this.disciplinaExistente, super.key});

  @override
  State<AdminCrearDisciplina> createState() => _AdminCrearDisciplinaState();
}

class _AdminCrearDisciplinaState extends State<AdminCrearDisciplina> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  final _controller = DisciplinasController();

  bool editando = false;
  bool cargando = false;

  // Lista dinámica de categorías
  List<String> categoriasSeleccionadas = [];

  /// 🔥 NUEVO: controladores de precio por categoría
  Map<String, TextEditingController> preciosCtrls = {};

  @override
  void initState() {
    super.initState();

    if (widget.disciplinaExistente != null) {
      editando = true;
      _nombreCtrl.text = widget.disciplinaExistente!.nombre;
      _descripcionCtrl.text = widget.disciplinaExistente!.descripcion;

      categoriasSeleccionadas =
          List<String>.from(widget.disciplinaExistente!.categorias);

      // Cargar precios existentes
      for (var cat in categoriasSeleccionadas) {
        preciosCtrls[cat] = TextEditingController(
          text: widget.disciplinaExistente!.precios[cat]?.toString() ?? "",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Disciplina" : "Crear Disciplina"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------------- NOMBRE ----------------
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 16),

              // ---------------- DESCRIPCIÓN ----------------
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              // ---------------- CATEGORÍAS DINÁMICAS ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoriaCtrl,
                      decoration: const InputDecoration(
                        labelText: "Agregar categoría",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final texto = _categoriaCtrl.text.trim();
                      if (texto.isEmpty) return;

                      setState(() {
                        categoriasSeleccionadas.add(texto);

                        // Crear controlador de precio
                        preciosCtrls[texto] = TextEditingController();
                      });

                      _categoriaCtrl.clear();
                    },
                    child: const Text("Agregar"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mostrar chips de categorías
              Wrap(
                spacing: 8,
                children: categoriasSeleccionadas.map((cat) {
                  return Chip(
                    label: Text(cat),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        categoriasSeleccionadas.remove(cat);
                        preciosCtrls.remove(cat);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 🔥 NUEVO: PRECIOS POR CATEGORÍA
              if (categoriasSeleccionadas.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Precios por categoría",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children: categoriasSeleccionadas.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            controller: preciosCtrls[cat],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Precio para $cat",
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Precio obligatorio";
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return "Debe ser un número";
                              }
                              return null;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // ---------------- BOTÓN GUARDAR ----------------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          editando ? "Guardar Cambios" : "Crear",
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (categoriasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agrega al menos una categoría")),
      );
      return;
    }

    setState(() => cargando = true);

    final nombre = _nombreCtrl.text.trim();
    final desc = _descripcionCtrl.text.trim();

    // 🔥 Crear mapa de precios
    final Map<String, dynamic> precios = {};
    for (var cat in categoriasSeleccionadas) {
      final ctrl = preciosCtrls[cat];
      precios[cat] = double.tryParse(ctrl?.text.trim() ?? "0") ?? 0;
    }

    try {
      if (editando) {
        await _controller.editarDisciplina(
          widget.disciplinaExistente!.id,
          {
            'nombre': nombre,
            'descripcion': desc,
            'categorias': categoriasSeleccionadas,
            'precios': precios, // ← NUEVO
          },
        );
      } else {
        await _controller.crearDisciplina(
          nombre: nombre,
          descripcion: desc,
          categorias: categoriasSeleccionadas,
          precios: precios, // ← NUEVO
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              editando ? "Disciplina actualizada" : "Disciplina creada"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }
}
