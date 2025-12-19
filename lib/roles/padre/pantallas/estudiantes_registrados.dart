// 📁 lib/roles/padre/pantallas/estudiantes_registrados.dart

import 'package:club_huandoy/roles/padre/pantallas/pago/pantalla_pagar_carrito.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';
import 'pantalla_asignar_horario.dart';

const double COSTO_MATRICULA = 50.0;

class EstudiantesRegistrados extends StatefulWidget {
  const EstudiantesRegistrados({super.key});

  @override
  State<EstudiantesRegistrados> createState() =>
      _EstudiantesRegistradosState();
}

class _EstudiantesRegistradosState extends State<EstudiantesRegistrados> {

  // ======================================================
  // POPUP DE PAGO (CORREGIDO – NO ASUME MENSUALIDAD)
  // ======================================================
  void mostrarPopupPago(BuildContext context) {
    final carrito =
        Provider.of<CarritoAsignacionProvider>(context, listen: false);

    final items = carrito.items;

    final matriculas =
        items.where((i) => i["tipoItem"] == "matricula").toList();

    final otros =
        items.where((i) => i["tipoItem"] != "matricula").toList();

    double totalMatriculas = 0;
    double totalMensualidad = 0;
    double totalProrrateo = 0;
    double totalFinal = 0;

    for (final item in matriculas) {
      totalMatriculas += (item["montoFinal"] ?? 0.0);
      totalFinal += (item["montoFinal"] ?? 0.0);
    }

    for (final item in otros) {
      final double montoFinal = (item["montoFinal"] ?? 0.0);
      final double prorrateo = (item["montoProrrateo"] ?? 0.0);
      final double mensualidad = (item["montoCategoria"] ?? 0.0);

      totalFinal += montoFinal;

      if (prorrateo > 0) {
        totalProrrateo += prorrateo;

        // SOLO si el prorrateo es pequeño (<20) se cobra mensualidad
        if (prorrateo < 20) {
          totalMensualidad += mensualidad;
        }
      } else {
        totalMensualidad += mensualidad;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Carrito de Pago"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (totalMatriculas > 0)
              _fila("Matrículas",
                  "S/. ${totalMatriculas.toStringAsFixed(2)}",
                  Colors.green),

            if (totalMensualidad > 0)
              _fila("Mensualidad",
                  "S/. ${totalMensualidad.toStringAsFixed(2)}",
                  Colors.green),

            if (totalProrrateo > 0)
              _fila("Prorrateo",
                  "S/. ${totalProrrateo.toStringAsFixed(2)}",
                  Colors.green),

            const Divider(),
            _fila("TOTAL",
                "S/. ${totalFinal.toStringAsFixed(2)}",
                Colors.black,
                bold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PantallaPagarCarrito(),
                ),
              );
            },
            child: Text(
              "Proceder al Pago | S/. ${totalFinal.toStringAsFixed(2)}"),
          ),
        ],
      ),
    );
  }

  Widget _fila(String titulo, String monto, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
          Text(monto,
              style: TextStyle(
                  color: color,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  // ======================================================
  // MERCADO PAGO (SIN CAMBIOS)
  // ======================================================
  Future<void> procesarPago(
      double total, Map<String, dynamic> primerItem) async {
    final url = Uri.parse(
        "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/crearPago");

    final body = {
      "estudianteId": primerItem["estudianteId"],
      "monto": total,
      "descripcion": "Pago – Club Huandoy"
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (data["init_point"] != null) {
      await launchUrl(
        Uri.parse(data["init_point"]),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ======================================================
  // BUILD ORIGINAL (RESTAURADO COMPLETO)
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final carrito = Provider.of<CarritoAsignacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estudiantes Registrados"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: carrito.items.isEmpty
                    ? null
                    : () => mostrarPopupPago(context),
              ),
              if (carrito.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      carrito.items.length.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
            ],
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("estudiantes")
            .where("padreId", isEqualTo: uid)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
                child: Text("No tienes estudiantes registrados"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final est = Estudiante.fromMap(
                docs[i].data() as Map<String, dynamic>,
                docs[i].id,
              );

              final enCarrito = carrito.contieneEstudiante(est.id);
              final estadoEstudiante = est.estado;

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    "${est.nombre} ${est.apellido}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    estadoEstudiante == "registrado"
                        ? "Sin horario asignado"
                        : estadoEstudiante == "pendiente_pago"
                            ? "Pendiente de pago"
                            : "Horario asignado",
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estadoEstudiante == "registrado"
                          ? Colors.red            // ASIGNAR
                          : enCarrito
                              ? Colors.amber       // EN CARRITO
                              : Colors.green,      // ASIGNADO
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (estadoEstudiante == "registrado") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PantallaAsignarHorario(estudiante: est),
                          ),
                        );
                      } else if (enCarrito) {
                        mostrarPopupPago(context);
                      }
                    },
                    child: Text(
                      estadoEstudiante == "registrado"
                          ? "ASIGNAR"
                          : enCarrito
                              ? "EN CARRITO"
                              : "ASIGNADO",
                    ),
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
