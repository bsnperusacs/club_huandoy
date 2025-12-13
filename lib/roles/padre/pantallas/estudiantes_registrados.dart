// 📁 lib/roles/padre/pantallas/estudiantes_registrados.dart

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
 // POPUP DE PAGO – SOLO MENSUALIDAD/PRORRATEO SI NO ES MATRÍCULA
 // ======================================================
 void mostrarPopupPago(BuildContext context) {
  final carrito =
    Provider.of<CarritoAsignacionProvider>(context, listen: false);

  final items = carrito.items;

  // Solo matriculas
  final matriculas =
    items.where((item) => item["tipoItem"] == "matricula").toList();

  // Todo lo demás (asignaciones de horario, productos, etc.)
  final otros =
    items.where((item) => item["tipoItem"] != "matricula").toList();

  // MATRÍCULAS - CORRECCIÓN APLICADA: SUMAR montoFinal
  final double totalMatriculas = matriculas.fold<double>(
   0.0,
   (acum, item) => acum + (item["montoFinal"] ?? 0.0), 
  );

  // MENSUALIDAD (solo de otros items, NO de matrícula)
  final double totalMensualidad = otros.fold<double>(
   0.0,
   (acum, item) => acum + (item["montoCategoria"] ?? 0.0),
  );

  // PRORRATEO (solo de otros)
  final double totalProrrateo = otros.fold<double>(
   0.0,
   (acum, item) => acum + (item["montoProrrateo"] ?? 0.0),
  );

  // DESCUENTOS (solo de otros)
  final double totalDescuentos = otros.fold<double>(
   0.0,
   (acum, item) => acum + (item["montoDescuento"] ?? 0.0),
  );

  // TOTAL FINAL
  final double totalFinal =
    totalMatriculas + totalMensualidad + totalProrrateo - totalDescuentos;

  showDialog(
   context: context,
   barrierDismissible: true,
   builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    title: const Text("Carrito de Pago"),
    content: Column(
     mainAxisSize: MainAxisSize.min,
     children: [
      _fila("Matrículas", "S/. ${totalMatriculas.toStringAsFixed(2)}",
        Colors.green),
      _fila("Mensualidad", "S/. ${totalMensualidad.toStringAsFixed(2)}",
        Colors.green),
      _fila("Prorrateo", "S/. ${totalProrrateo.toStringAsFixed(2)}",
        Colors.green),
      _fila("Descuentos", "- S/. ${totalDescuentos.toStringAsFixed(2)}",
        Colors.red),
      const Divider(),
      _fila("TOTAL", "S/. ${totalFinal.toStringAsFixed(2)}",
        Colors.black,
        bold: true),
     ],
    ),
    actions: [
     ElevatedButton(
      onPressed: () {
       Navigator.pop(context);
       if (carrito.items.isNotEmpty) {
        procesarPago(totalFinal, carrito.items.first);
       }
      },
      child:
        Text("Proceder al Pago | S/. ${totalFinal.toStringAsFixed(2)}"),
     )
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
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
       )),
     Text(
      monto,
      style: TextStyle(
       color: color,
       fontWeight: bold ? FontWeight.bold : FontWeight.w600,
      ),
     ),
    ],
   ),
  );
 }

 // ======================================================
 // MERCADO PAGO
 // ======================================================
 Future<void> procesarPago(
   double total, Map<String, dynamic> primerItem) async {
  final url = Uri.parse(
    "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/crearPago");

  final body = {
   "estudianteId": primerItem["estudianteId"],
   "monto": total,
   "descripcion": "Matrícula + Mensualidad – Club Huandoy"
  };

  try {
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
  } catch (e) {
   print("ERROR procesando pago: $e");
  }
 }

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
           style:
             const TextStyle(color: Colors.white, fontSize: 12),
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
              final estadoEstudiante = est.estado; // Obtener el estado para simplificar la lógica

       return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        child: ListTile(
         contentPadding: const EdgeInsets.all(12),

         leading: CircleAvatar(
          radius: 26,
          backgroundImage: est.fotoUrl.isNotEmpty
            ? NetworkImage(est.fotoUrl)
            : null,
          child: est.fotoUrl.isEmpty
            ? const Icon(Icons.person)
            : null,
         ),

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
                    // ---------------- LÓGICA DE ACCIÓN (onPressed) ----------------
          onPressed: () {
                        if (estadoEstudiante == "registrado") {
                            // Acción para asignar horario
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PantallaAsignarHorario(
                                        estudiante: est),
                                ),
                            ).then((res) {
                                // Forzar la actualización cuando regrese
                                if (res == true) setState(() {});
                            });
                        } else if (enCarrito) {
                            // Acción para ir a pagar (si ya está asignado o pendiente y en carrito)
                            mostrarPopupPago(context);
                        } else {
                            // Si está asignado y NO está en el carrito (ya pagó), no hace nada
                            return; 
                        }
                    },
                    
                    // ---------------- LÓGICA VISUAL (Estilo y Texto) ----------------
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                                if (estadoEstudiante == "registrado") {
                                    return Colors.green; // ASIGNAR es activo
                                }
                                if (enCarrito) {
                                    return Colors.blue; // EN CARRITO es activo
                                }
                                // ASIGNADO (Deshabilitado, gris)
                                return Colors.grey.shade400; 
                            },
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),

          child: Text(
           estadoEstudiante == "registrado"
             ? "ASIGNAR"
                            : enCarrito 
                                ? "EN CARRITO"
                : "ASIGNADO", // ASIGNADO queda en gris por el style
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