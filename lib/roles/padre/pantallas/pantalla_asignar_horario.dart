import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/modelos/estudiante_model.dart';
import '../../../core/controladores/prorrateo_controller.dart';
import 'pantalla_pagar_asignacion.dart';

class AsignarHorario extends StatefulWidget {
  final Estudiante estudiante;

  const AsignarHorario({super.key, required this.estudiante});

  @override
  State<AsignarHorario> createState() => _AsignarHorarioState();
}

class _AsignarHorarioState extends State<AsignarHorario> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final prorrateoController = ProrrateoController();

  // ---------------- VARIABLES ----------------
  String? disciplinaId;
  List<String> categorias = [];
  String? categoriaSeleccionada;

  List<QueryDocumentSnapshot> grupos = [];
  DocumentSnapshot? grupoSel;

  DocumentSnapshot? horarioSel;
  DocumentSnapshot? entrenadorSel;

  double montoCategoria = 0;
  double montoProrrateo = 0;
  double montoDescuento = 0;
  double montoFinal = 0;

  bool listoProrrateo = false;
  DateTime? fechaInicioClases;

  // ==========================================================
  // CARGAR CATEGORÍAS
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
  // CARGAR GRUPOS POSIBLES
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
      if ((g["inscritos"] ?? 0) < (g["cupoMaximo"] ?? 0)) {
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
    entrenadorSel = await db.collection("entrenadores").doc(entrenadorId).get();

    fechaInicioClases = (grupoSel!["fechaInicioClases"] as Timestamp).toDate();

    await calcularProrrateo();
  }

  // ==========================================================
  // PRORRATEO CORREGIDO
  // ==========================================================
  Future<void> calcularProrrateo() async {
    if (disciplinaId == null ||
        categoriaSeleccionada == null ||
        grupoSel == null ||
        fechaInicioClases == null) {
      return;
    }

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
  // IR A PANTALLA DE PAGO
  // ==========================================================
  void pagar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaPagarAsignacion(
          estudiante: widget.estudiante,
          datosPago: {
            "disciplinaId": disciplinaId,
            "categoriaId": categoriaSeleccionada,
            "grupoId": grupoSel!.id,
            "horarioId": horarioSel!.id,
            "entrenadorId": entrenadorSel!.id,
            "montoCategoria": montoCategoria,
            "montoProrrateo": montoProrrateo,
            "montoDescuento": montoDescuento,
            "montoFinal": montoFinal,
          },
        ),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asignar Horario")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- DISCIPLINA ----------------
            Text("Disciplina",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            StreamBuilder<QuerySnapshot>(
              stream: db.collection("disciplinas").snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return CircularProgressIndicator();

                return DropdownButtonFormField(
                  initialValue: disciplinaId,
                  hint: Text("Selecciona..."),
                  items: snap.data!.docs
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d["nombre"]),
                          ))
                      .toList(),
                  onChanged: (v) => cargarCategorias(v.toString()),
                );
              },
            ),

            SizedBox(height: 20),

            // ---------------- CATEGORÍA ----------------
            if (categorias.isNotEmpty) ...[
              Text("Categoría",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              DropdownButtonFormField(
                initialValue: categoriaSeleccionada,
                hint: Text("Selecciona..."),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  categoriaSeleccionada = v.toString();
                  cargarGrupos();
                },
              ),
            ],

            SizedBox(height: 20),

            // ---------------- GRUPOS ----------------
            if (grupos.isNotEmpty) ...[
              Text("Grupo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              DropdownButtonFormField(
                initialValue: grupoSel?.id,
                hint: Text("Selecciona grupo"),
                items: grupos.map((g) {
                  final seccion = g["seccion"] ?? "?";
                  final categoria = g["categoria"];

                  return DropdownMenuItem(
                    value: g.id,
                    child:
                        Text("Grupo $categoria – Sección $seccion"), // 🔥 NUEVO
                  );
                }).toList(),
                onChanged: (v) {
                  grupoSel = grupos.firstWhere((e) => e.id == v);
                  cargarHorarioYEntrenador();
                },
              ),
            ],

            SizedBox(height: 25),

            // ---------------- HORARIO RESUMEN ----------------
            if (horarioSel != null) ...[
              Divider(),
              Text("Horario seleccionado:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(
                  "${horarioSel!["dias"].join(" - ")} | ${horarioSel!["horaInicio"]} - ${horarioSel!["horaFin"]}"),
            ],

            SizedBox(height: 25),

            // ---------------- RESUMEN DE PAGO ----------------
            if (listoProrrateo) ...[
              Divider(),
              Text("Resumen de Pago",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              SizedBox(height: 10),
              Text("Categoría: S/ $montoCategoria"),
              Text("Prorrateo: S/ ${montoProrrateo.toStringAsFixed(2)}"),
              Text("Descuento: S/ ${montoDescuento.toStringAsFixed(2)}"),

              SizedBox(height: 15),
              Text("TOTAL A PAGAR:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              Text("S/ ${montoFinal.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ],
        ),
      ),

      floatingActionButton: listoProrrateo
          ? FloatingActionButton.extended(
              onPressed: pagar,
              label: Text("PAGAR"),
              icon: Icon(Icons.payment),
            )
          : null,
    );
  }
}
