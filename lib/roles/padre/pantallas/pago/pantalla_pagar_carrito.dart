import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/modelos/estudiante_model.dart';

import 'pantalla_pagar_asignacion.dart';

class PantallaPagarCarrito extends StatelessWidget {
  const PantallaPagarCarrito({super.key});

  Future<Estudiante> cargarEstudiante(String id) async {
    final snap = await FirebaseFirestore.instance
        .collection("estudiantes")
        .doc(id)
        .get();

    return Estudiante.fromMap(snap.data()!, snap.id);
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoAsignacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de Matrícula"),
      ),

      body: carrito.items.isEmpty
          ? const Center(
              child: Text(
                "Tu carrito está vacío.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Asignaciones:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...carrito.items.map((item) {
                  return Card(
                    child: ListTile(
                      title: Text(item["nombreCompleto"]),
                      subtitle: Text(
                        "Disciplina: ${item["disciplinaNombre"]}\n"
                        "Categoría: ${item["categoria"]}\n"
                        "Horario: ${item["horarioTexto"]}\n"
                        "Monto: S/. ${item["montoFinal"].toStringAsFixed(2)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          carrito.eliminar(item["estudianteId"]);
                        },
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "S/. ${carrito.totalGlobal.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

      bottomNavigationBar: carrito.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final item = carrito.items.first;

                  final estudiante =
                      await cargarEstudiante(item["estudianteId"]);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaPagarAsignacion(
                        estudiante: estudiante,
                        datosPago: item,
                      ),
                    ),
                  );
                },
                child: const Text("Proceder al Pago"),
              ),
            ),
    );
  }
}
