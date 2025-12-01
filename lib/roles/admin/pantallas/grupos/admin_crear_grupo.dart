// 📁 Ubicación: lib/roles/admin/pantallas/grupos/admin_crear_grupo.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/controladores/grupo_controller.dart';
import 'package:club_huandoy/core/controladores/disciplina_controller.dart';
import 'package:club_huandoy/core/controladores/horario_controller.dart';
import 'package:club_huandoy/core/controladores/entrenador_controller.dart';
import 'package:club_huandoy/core/modelos/grupo_model.dart';
import 'package:club_huandoy/core/modelos/disciplina_model.dart';
import 'package:club_huandoy/core/modelos/horario_model.dart';
import 'package:club_huandoy/core/modelos/entrenador_model.dart';

class AdminCrearGrupo extends StatefulWidget {
  final GrupoModel? grupoExistente;

  const AdminCrearGrupo({this.grupoExistente, super.key});

  @override
  State<AdminCrearGrupo> createState() => _AdminCrearGrupoState();
}

class _AdminCrearGrupoState extends State<AdminCrearGrupo> {
  final _formKey = GlobalKey<FormState>();

  final gruposCtrl = GruposController();
  final disciplinasCtrl = DisciplinasController();
  final horariosCtrl = HorariosController();
  final entrenadoresCtrl = EntrenadoresController();

  String? disciplinaId;
  String? horarioId;
  String? entrenadorId;

  // Categorías dinámicas de la disciplina
  List<String> categorias = [];
  String? categoriaSeleccionada;

  int cupoMaximo = 15;
  DateTime fechaInicio = DateTime.now();

  bool editando = false;

  @override
  void initState() {
    super.initState();

    if (widget.grupoExistente != null) {
      editando = true;
      final g = widget.grupoExistente!;

      disciplinaId = g.disciplinaId;
      horarioId = g.horarioId;
      entrenadorId = g.entrenadorId;
      categoriaSeleccionada = g.categoria;
      cupoMaximo = g.cupoMaximo;
      fechaInicio = g.fechaInicioClases;

      _cargarCategoriasDeDisciplina(g.disciplinaId);
    }
  }

  // ============================================================
  // CARGAR CATEGORÍAS
  // ============================================================
  Future<void> _cargarCategoriasDeDisciplina(String? idDisciplina) async {
    if (idDisciplina == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("disciplinas")
        .doc(idDisciplina)
        .get();

    if (snap.exists && snap.data()!["categorias"] != null) {
      setState(() {
        categorias = List<String>.from(snap["categorias"]);
      });
    }
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Grupo" : "Crear Grupo"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _selectorDisciplina(),
              const SizedBox(height: 20),

              _selectorHorario(),
              const SizedBox(height: 20),

              _selectorEntrenador(),
              const SizedBox(height: 20),

              _selectorCategoria(),
              const SizedBox(height: 20),

              _inputCupos(),
              const SizedBox(height: 20),

              _selectorFecha(),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _guardar,
                child: Text(editando ? "Guardar Cambios" : "Crear"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTOR DISCIPLINA
  // ============================================================
  Widget _selectorDisciplina() {
    return StreamBuilder(
      stream: disciplinasCtrl.listarDisciplinas(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final lista = snapshot.data!.docs
            .map((d) => DisciplinaModel.fromFirestore(d))
            .toList();

        return DropdownButtonFormField<String>(
          initialValue: disciplinaId,
          hint: const Text("Seleccione disciplina"),
          items: lista.map((disc) {
            return DropdownMenuItem(
              value: disc.id,
              child: Text(disc.nombre),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              disciplinaId = v;
              horarioId = null;
              entrenadorId = null;
              categoriaSeleccionada = null;
              categorias = [];
            });
            _cargarCategoriasDeDisciplina(v);
          },
          validator: (v) => v == null ? "Seleccione disciplina" : null,
        );
      },
    );
  }

  // ============================================================
  // SELECTOR HORARIO
  // ============================================================
  Widget _selectorHorario() {
    if (disciplinaId == null) {
      return const Text("Seleccione disciplina primero");
    }

    return StreamBuilder(
      stream: horariosCtrl.listarHorarios(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final lista = snapshot.data!.docs
            .map((d) => HorarioModel.fromFirestore(d))
            .where((h) => h.disciplinaId == disciplinaId)
            .toList();

        if (lista.isEmpty) {
          return const Text("No hay horarios para esta disciplina");
        }

        return DropdownButtonFormField<String>(
          initialValue: horarioId,
          hint: const Text("Seleccione horario"),
          items: lista.map((h) {
            return DropdownMenuItem(
              value: h.id,
              child: Text(
                  "${h.lugar} | ${h.horaInicio}-${h.horaFin} | ${h.dias.join(', ')}"),
            );
          }).toList(),
          onChanged: (v) => setState(() => horarioId = v),
          validator: (v) => v == null ? "Seleccione horario" : null,
        );
      },
    );
  }

  // ============================================================
  // SELECTOR ENTRENADOR
  // ============================================================
  Widget _selectorEntrenador() {
    if (disciplinaId == null) {
      return const Text("Seleccione disciplina primero");
    }

    return StreamBuilder(
      stream: entrenadoresCtrl.listarEntrenadores(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final lista = snapshot.data!.docs
            .map((d) => EntrenadorModel.fromFirestore(d))
            .where((e) => e.disciplinas.contains(disciplinaId))
            .toList();

        if (lista.isEmpty) {
          return const Text("No hay entrenadores para esta disciplina");
        }

        return DropdownButtonFormField<String>(
          initialValue: entrenadorId,
          hint: const Text("Seleccione entrenador"),
          items: lista.map((e) {
            return DropdownMenuItem(
              value: e.id,
              child: Text("${e.nombres} ${e.apellidos}"),
            );
          }).toList(),
          onChanged: (v) => setState(() => entrenadorId = v),
          validator: (v) => v == null ? "Seleccione entrenador" : null,
        );
      },
    );
  }

  // ============================================================
  // SELECTOR CATEGORÍA
  // ============================================================
  Widget _selectorCategoria() {
    if (categorias.isEmpty) {
      return const Text("Agregue categorías en la disciplina primero");
    }

    return DropdownButtonFormField<String>(
      initialValue: categoriaSeleccionada,
      decoration: const InputDecoration(labelText: "Categoría"),
      items: categorias.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Text(c),
        );
      }).toList(),
      onChanged: (v) => setState(() => categoriaSeleccionada = v),
      validator: (v) => v == null ? "Seleccione una categoría" : null,
    );
  }

  // ============================================================
  // CUPO
  // ============================================================
  Widget _inputCupos() {
    return TextFormField(
      initialValue: cupoMaximo.toString(),
      decoration: const InputDecoration(labelText: "Cupo máximo"),
      keyboardType: TextInputType.number,
      validator: (v) =>
          v!.isEmpty ? "Obligatorio" : (int.tryParse(v) == null ? "Número inválido" : null),
      onChanged: (v) => cupoMaximo = int.tryParse(v) ?? 15,
    );
  }

  // ============================================================
  // FECHA
  // ============================================================
  Widget _selectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha inicio de clases:"),
        TextButton(
          child: Text("${"${fechaInicio.toLocal()}".split(' ')[0]} (Cambiar)"),
          onPressed: () async {
            final pick = await showDatePicker(
              context: context,
              initialDate: fechaInicio,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            if (pick != null) {
              setState(() => fechaInicio = pick);
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // GUARDAR
  // ============================================================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (editando) {
      await gruposCtrl.editarGrupo(
        widget.grupoExistente!.id,
        {
          'disciplinaId': disciplinaId,
          'horarioId': horarioId,
          'entrenadorId': entrenadorId,
          'categoria': categoriaSeleccionada,
          'cupoMaximo': cupoMaximo,
          'fechaInicioClases': fechaInicio,
        },
      );
    } else {
      await gruposCtrl.crearGrupo(
        disciplinaId: disciplinaId!,
        horarioId: horarioId!,
        entrenadorId: entrenadorId!,
        categoria: categoriaSeleccionada!,
        cupoMaximo: cupoMaximo,
        fechaInicioClases: fechaInicio,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
