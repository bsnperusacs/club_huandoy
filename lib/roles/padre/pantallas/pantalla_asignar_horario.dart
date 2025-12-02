// UBICACIÓN: lib/roles/padre/pantallas/pantalla_asignar_horario.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../core/modelos/estudiante_model.dart';
import '../../../core/controladores/prorrateo_controller.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';

class PantallaAsignarHorario extends StatefulWidget {
  final Estudiante estudiante;

  const PantallaAsignarHorario({
    super.key,
    required this.estudiante,
  });

  @override
  State<PantallaAsignarHorario> createState() =>
      _PantallaAsignarHorarioState();
}

class _PantallaAsignarHorarioState extends State<PantallaAsignarHorario> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final prorrateoController = ProrrateoController();

  // ---------------- VARIABLES ----------------
  String? disciplinaId;
  String? disciplinaNombre;

  List<String> categorias = [];
  String? categoriaSeleccionada;

  List<QueryDocumentSnapshot> grupos = [];
  QueryDocumentSnapshot? grupoSel;

  DocumentSnapshot? horarioSel;
  DocumentSnapshot? entrenadorSel;

  bool listoProrrateo = false;

  double montoCategoria = 0;
  double montoProrrateo = 0;
  double montoDescuento = 0;
  double montoFinal = 0;

  DateTime? fechaInicioClases;

  // ==========================================================
  // CARGAR CATEGORÍAS DE DISCIPLINA
  // ==========================================================
  Future<void> cargarCategorias(String idDisciplina) async {
    final doc = await db.collection("disciplinas").doc(idDisciplina).get();

    categorias = List<String>.from(doc["categorias"] ?? []);

    disciplinaId = idDisciplina;
    categoriaSeleccionada = null;

    grupos = [];
    grupoSel = null;
    horarioSel = null;
    entrenadorSel = null;
    listoProrrateo = false;

    setState(() {});
  }

  // ==========================================================
  // CARGAR GRUPOS DISPONIBLES
  // ==========================================================
  Future<void> cargarGrupos() async {
    grupos = [];

    final snap = await db
        .collection("grupos")
        .where("disciplinaId", isEqualTo: disciplinaId)
        .where("categoria", isEqualTo: categoriaSeleccionada)
        .where("activo", isEqualTo: true)
        .get();

    for (var g in snap.docs) {
      final inscritos = g["inscritos"] ?? 0;
      final cupo = g["cupoMaximo"] ?? 0;

      if (inscritos < cupo) {
        grupos.add(g);
      }
    }

    grupoSel = null;
    horarioSel = null;
    entrenadorSel = null;
    listoProrrateo = false;

    setState(() {});
  }

  // ==========================================================
  // CARGAR HORARIO + ENTRENADOR
  // ==========================================================
  Future<void> cargarHorarioYEntrenador() async {
    if (grupoSel == null) return;

    final horarioId = grupoSel!["horarioId"];
    final entrenadorId = grupoSel!["entrenadorId"];

    horarioSel = await db.collection("horarios").doc(horarioId).get();
    entrenadorSel =
        await db.collection("entrenadores").doc(entrenadorId).get();

    fechaInicioClases =
        (grupoSel!["fechaInicioClases"] as Timestamp).toDate();

    await calcularProrrateo();
  }

  // ==========================================================
  // CALCULAR PRORRATEO
  // ==========================================================
  Future<void> calcularProrrateo() async {
    if (disciplinaId == null ||
        categoriaSeleccionada == null ||
        grupoSel == null ||
        fechaInicioClases == null) return;

    final datos = await prorrateoController.calcular(
      disciplinaId: disciplinaId!,
      categoria: categoriaSeleccionada!,
      fechaInicioClases: fechaInicioClases!,
    );

    montoCategoria = datos["montoCategoria"];
    montoProrrateo = datos["montoProrrateo"];
    montoDescuento = datos["montoDescuento"];
    montoFinal = datos["montoFinal"];

    listoProrrateo = true;
    setState(() {});
  }

  // ==========================================================
  // AGREGAR AL CARRITO
  // ==========================================================
  void agregarAlCarrito() {
    if (!listoProrrateo || grupoSel == null || horarioSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todas las selecciones.")),
      );
      return;
    }

    final carrito =
        Provider.of<CarritoAsignacionProvider>(context, listen: false);

    carrito.agregar({
      "estudianteId": widget.estudiante.id,
      "nombreCompleto":
          "${widget.estudiante.nombre} ${widget.estudiante.apellido}",

      "disciplinaId": disciplinaId,
      "disciplinaNombre": disciplinaNombre, // AHORA CORRECTO

      "categoria": categoriaSeleccionada,
      "grupoId": grupoSel!.id,
      "horarioId": horarioSel!.id,
      "entrenadorId": entrenadorSel?.id,

      "horarioTexto":
          "${horarioSel!["dias"].join(" - ")}  ${horarioSel!["horaInicio"]} - ${horarioSel!["horaFin"]}",

      "montoCategoria": montoCategoria,
      "montoProrrateo": montoProrrateo,
      "montoDescuento": montoDescuento,
      "montoFinal": montoFinal,
    });

    Navigator.pop(context, true);
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asignar Horario – ${widget.estudiante.nombre}"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- DISCIPLINA ----------------
            const Text("Disciplina",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            StreamBuilder<QuerySnapshot>(
              stream: db.collection("disciplinas").snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField(
                  value: disciplinaId,
                  hint: const Text("Selecciona disciplina..."),
                  items: snap.data!.docs
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d["nombre"]),
                          ))
                      .toList(),
                  onChanged: (v) {
                    final doc = snap.data!.docs.firstWhere((d) => d.id == v);
                    disciplinaNombre = doc["nombre"]; // GUARDAR NOMBRE REAL

                    cargarCategorias(v.toString());
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // ---------------- CATEGORÍA ----------------
            if (categorias.isNotEmpty) ...[
              const Text("Categoría",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              DropdownButtonFormField(
                value: categoriaSeleccionada,
                hint: const Text("Selecciona categoría..."),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  categoriaSeleccionada = v.toString();
                  cargarGrupos();
                },
              ),
            ],

            const SizedBox(height: 20),

            // ---------------- GRUPOS ----------------
            if (grupos.isNotEmpty) ...[
              const Text("Grupo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              DropdownButtonFormField(
                value: grupoSel?.id,
                hint: const Text("Selecciona grupo"),
                items: grupos.map((g) {
                  final seccion = g["seccion"] ?? "?";
                  final categoria = g["categoria"];

                  return DropdownMenuItem(
                    value: g.id,
                    child: Text(
                        "$disciplinaNombre – $categoria – Sección $seccion"),
                  );
                }).toList(),
                onChanged: (v) {
                  grupoSel = grupos.firstWhere((e) => e.id == v);
                  cargarHorarioYEntrenador();
                },
              ),
            ],

            const SizedBox(height: 25),

            // ---------------- HORARIO ----------------
            if (horarioSel != null) ...[
              const Divider(),
              const Text("Horario seleccionado:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                "${horarioSel!["dias"].join(" - ")} | "
                "${horarioSel!["horaInicio"]} - ${horarioSel!["horaFin"]}",
              ),
            ],

            const SizedBox(height: 25),

            // ---------------- RESUMEN DE PAGO ----------------
            if (listoProrrateo) ...[
              const Divider(),
              const Text("Resumen de Pago",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Text("Categoría: S/ $montoCategoria"),
              Text("Prorrateo: S/ ${montoProrrateo.toStringAsFixed(2)}"),
              Text("Descuento: S/ ${montoDescuento.toStringAsFixed(2)}"),

              const SizedBox(height: 15),

              const Text("TOTAL A PAGAR:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              Text("S/ ${montoFinal.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ],
        ),
      ),

      floatingActionButton: listoProrrateo
          ? FloatingActionButton.extended(
              onPressed: agregarAlCarrito,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Agregar al carrito"),
            )
          : null,
    );
  }
}
