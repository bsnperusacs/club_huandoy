// 📁 Ubicación: lib/roles/admin/pantallas/horarios/admin_crear_horario.dart

import 'package:flutter/material.dart';

import '../../../../core/controladores/horario_controller.dart';
import '../../../../core/controladores/disciplina_controller.dart';

import '../../../../core/modelos/horario_model.dart';
import '../../../../core/modelos/disciplina_model.dart';

class AdminCrearHorario extends StatefulWidget {
  final HorarioModel? horarioExistente;

  const AdminCrearHorario({this.horarioExistente, super.key});

  @override
  State<AdminCrearHorario> createState() => _AdminCrearHorarioState();
}

class _AdminCrearHorarioState extends State<AdminCrearHorario> {
  final HorariosController horariosCtrl = HorariosController();
  final DisciplinasController disciplinaCtrl = DisciplinasController();

  final _formKey = GlobalKey<FormState>();

  String? disciplinaSeleccionada;
  String horaInicio = "";
  String horaFin = "";
  String lugar = "";

  List<String> diasSeleccionados = [];

  final List<String> diasSemana = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
  ];

  bool editando = false;

  @override
  void initState() {
    super.initState();

    if (widget.horarioExistente != null) {
      editando = true;

      final h = widget.horarioExistente!;
      disciplinaSeleccionada = h.disciplinaId;
      horaInicio = h.horaInicio;
      horaFin = h.horaFin;
      lugar = h.lugar;
      diasSeleccionados = List.from(h.dias);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(editando ? "Editar Horario" : "Crear Horario"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                
                _selectorDisciplina(),

                const SizedBox(height: 20),

                _selectorDias(),

                const SizedBox(height: 20),

                TextFormField(
                  initialValue: horaInicio,
                  decoration: const InputDecoration(labelText: "Hora inicio (18:00)"),
                  validator: (v) =>
                      v!.isEmpty ? "Obligatorio" : null,
                  onChanged: (v) => horaInicio = v.trim(),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  initialValue: horaFin,
                  decoration: const InputDecoration(labelText: "Hora fin (20:00)"),
                  validator: (v) =>
                      v!.isEmpty ? "Obligatorio" : null,
                  onChanged: (v) => horaFin = v.trim(),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  initialValue: lugar,
                  decoration: const InputDecoration(labelText: "Lugar / cancha"),
                  validator: (v) =>
                      v!.isEmpty ? "Obligatorio" : null,
                  onChanged: (v) => lugar = v.trim(),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: _guardar,
                  child: Text(editando ? "Guardar Cambios" : "Crear"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectorDisciplina() {
    return StreamBuilder(
      stream: disciplinaCtrl.listarDisciplinas(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        final disciplinas = docs.map((e) => DisciplinaModel.fromFirestore(e)).toList();

        return DropdownButtonFormField<String>(
          initialValue: disciplinaSeleccionada,
          hint: const Text("Seleccione disciplina"),
          items: disciplinas.map((d) {
            return DropdownMenuItem(
              value: d.id,
              child: Text(d.nombre),
            );
          }).toList(),
          onChanged: (value) {
            disciplinaSeleccionada = value;
          },
          validator: (v) => v == null ? "Seleccione disciplina" : null,
        );
      },
    );
  }

  Widget _selectorDias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Días de clase:"),
        ...diasSemana.map((dia) {
          final seleccionado = diasSeleccionados.contains(dia);
          return CheckboxListTile(
            title: Text(dia),
            value: seleccionado,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  diasSeleccionados.add(dia);
                } else {
                  diasSeleccionados.remove(dia);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione al menos un día")),
      );
      return;
    }

    // Validar horas
    if (horaInicio.compareTo(horaFin) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La hora de inicio debe ser antes de la hora fin")),
      );
      return;
    }

    if (editando) {
      await horariosCtrl.editarHorario(
        widget.horarioExistente!.id,
        {
          'disciplinaId': disciplinaSeleccionada,
          'dias': diasSeleccionados,
          'horaInicio': horaInicio,
          'horaFin': horaFin,
          'lugar': lugar,
        },
      );
    } else {
      await horariosCtrl.crearHorario(
        disciplinaId: disciplinaSeleccionada!,
        dias: diasSeleccionados,
        horaInicio: horaInicio,
        horaFin: horaFin,
        lugar: lugar,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
