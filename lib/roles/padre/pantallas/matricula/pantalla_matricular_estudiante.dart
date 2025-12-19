// 📁 lib/roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'pantalla_formulario_estudiante.dart';

const double COSTO_MATRICULA_BASE = 50.00;

class PantallaMatriculaEstudiante extends StatefulWidget {
  const PantallaMatriculaEstudiante({super.key});

  @override
  State<PantallaMatriculaEstudiante> createState() =>
      _PantallaMatriculaEstudianteState();
}

class _PantallaMatriculaEstudianteState
    extends State<PantallaMatriculaEstudiante> {
  List<Map<String, dynamic>> estudiantesPendientes = [];

  final formatoMoneda =
      NumberFormat.currency(locale: 'es_PE', symbol: 'S/. ');

  Future<void> mostrarAlerta(String titulo, String mensaje) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<String> subirFoto(String dni, File file) async {
    final ref =
        FirebaseStorage.instance.ref().child("estudiantes/$dni.jpg");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ============================================================
  // SOLO GUARDA ESTUDIANTE (NO CARRITO, NO MATRÍCULA)
  // ============================================================
  Future<void> guardarEstudiante(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dni = data["dni"];
    final firestore = FirebaseFirestore.instance;

    final existe =
        await firestore.collection("estudiantes").doc(dni).get();

    if (existe.exists) return;

    String fotoUrl = "";
    if (data["imagenFile"] != null) {
      fotoUrl = await subirFoto(dni, data["imagenFile"]);
    }

    await firestore.collection("estudiantes").doc(dni).set({
      "id": dni,
      "padreId": uid,
      "nombre": data["nombre"],
      "apellido": data["apellido"],
      "dni": dni,
      "fechaNacimiento": data["fechaNacimiento"],
      "genero": data["genero"],
      "celular": data["celular"],
      "fotoUrl": fotoUrl,
      "ocupacion": data["ocupacion"],
      "institucion": data["institucion"],
      "grado": data["grado"],
      "centroTrabajo": data["centroTrabajo"],
      "estado": "registrado",
      "matriculaPagada": false,
      "fechaMatricula": DateTime.now(),
      "activo": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = estudiantesPendientes.length * COSTO_MATRICULA_BASE;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Matricular Estudiantes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PantallaFormularioEstudiante(),
                ),
              );

              if (result != null &&
                  !estudiantesPendientes
                      .any((e) => e["dni"] == result["dni"])) {
                setState(() => estudiantesPendientes.add(result));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLista(),
            const SizedBox(height: 20),
            if (estudiantesPendientes.isNotEmpty) ...[
              Card(
                child: ListTile(
                  title: const Text("Total a Pagar"),
                  trailing: Text(
                    formatoMoneda.format(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final firestore = FirebaseFirestore.instance;
                    final carritoRef = firestore.collection("carritos").doc(uid);

                    // Crear / asegurar carrito
                    await carritoRef.set({
                      "padreId": uid,
                      "estado": "abierto",
                      "fechaActualizacion": FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    for (final est in estudiantesPendientes) {
                      final dni = est["dni"];

                      // Guardar estudiante (si no existe)
                      await guardarEstudiante(est);

                      // Verificar si YA existe matrícula
                      final existeMatricula = await carritoRef
                          .collection("items")
                          .where("tipoItem", isEqualTo: "matricula")
                          .where("estudianteId", isEqualTo: dni)
                          .limit(1)
                          .get();

                      // Crear matrícula SOLO si no existe
                      if (existeMatricula.docs.isEmpty) {
                        await carritoRef.collection("items").add({
                          "tipoItem": "matricula",
                          "padreId": uid,
                          "estudianteId": dni,
                          "nombreCompleto":
                              "${est["nombre"]} ${est["apellido"]}",
                          "montoCategoria": COSTO_MATRICULA_BASE,
                          "montoProrrateo": 0,
                          "montoDescuento": 0,
                          "montoFinal": COSTO_MATRICULA_BASE,
                          "fechaCreacion": FieldValue.serverTimestamp(),
                        });
                      }
                    }

                    setState(() => estudiantesPendientes.clear());

                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                        context, "/estudiantesRegistrados");
                  },
                  child: const Text("Matricular y Elegir Horario"),
                ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (estudiantesPendientes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text("Aún no has agregado estudiantes."),
        ),
      );
    }

    return Column(
      children: estudiantesPendientes.map((est) {
        return Card(
          child: ListTile(
            title: Text("${est["nombre"]} ${est["apellido"]}"),
            subtitle: Text("DNI: ${est["dni"]}"),
          ),
        );
      }).toList(),
    );
  }
}
