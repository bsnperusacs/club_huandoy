// 📁 lib/roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'pantalla_formulario_estudiante.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';

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

  Future<void> mostrarAlerta(String titulo, String mensaje,
      {bool error = true}) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              error ? Icons.error : Icons.check_circle,
              color:
                  error ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(titulo),
          ],
        ),
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
    final ref = FirebaseStorage.instance
        .ref()
        .child("estudiantes")
        .child("$dni.jpg");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ============================================================
  // GUARDAR ESTUDIANTE + AGREGAR A CARRITO EN FIRESTORE
  // ============================================================
  Future<void> guardarEnFirestore(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dni = data["dni"];

    final existe = await FirebaseFirestore.instance
        .collection("estudiantes")
        .doc(dni)
        .get();

    if (existe.exists) {
      await mostrarAlerta(
        "DNI ya registrado",
        "El estudiante con DNI $dni ya existe.",
      );
      throw "duplicado";
    }

    String fotoUrl = "";

    if (data["imagenFile"] != null) {
      fotoUrl = await subirFoto(dni, data["imagenFile"]);
    }

    // ===== GUARDAR ESTUDIANTE =====
    await FirebaseFirestore.instance.collection("estudiantes").doc(dni).set({
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

      "montoCategoria": COSTO_MATRICULA_BASE,
      "montoDescuento": 0.0,
      "montoFinal": COSTO_MATRICULA_BASE,

      "activo": true,
    });

    // ===== CREAR ITEM CARRITO EN FIRESTORE =====
    final docRef = FirebaseFirestore.instance
        .collection("carritos")
        .doc(uid)
        .collection("items")
        .doc();

    await docRef.set({
      "itemId": docRef.id,
      "padreId": uid,
      "tipoItem": "matricula", // 🔴 IMPORTANTE

      "estudianteId": dni,
      "nombreCompleto": "${data["nombre"]} ${data["apellido"]}",

      "montoCategoria": COSTO_MATRICULA_BASE,
      "montoProrrateo": 0,
      "montoDescuento": 0,
      "montoFinal": COSTO_MATRICULA_BASE,

      "disciplinaNombre": "",
      "categoria": "",
      "horarioTexto": "",
      "grupoId": "",

      "fechaCreacion": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carrito = Provider.of<CarritoAsignacionProvider>(context);

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

              if (result != null) {
                if (estudiantesPendientes
                    .any((e) => e["dni"] == result["dni"])) {
                  mostrarAlerta("Duplicado",
                      "Ya agregaste un estudiante con ese DNI.");
                  return;
                }

                setState(() => estudiantesPendientes.add(result));
              }
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLista(),
            const SizedBox(height: 25),

            if (estudiantesPendientes.isNotEmpty) ...[
              Card(
                child: ListTile(
                  title: const Text("Total a Pagar"),
                  trailing: Text(
                    formatoMoneda.format(total),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final carritoProvider =
                        Provider.of<CarritoAsignacionProvider>(context,
                            listen: false);

                    for (final est in estudiantesPendientes) {
                      try {
                        await guardarEnFirestore(est);

                        // Agregar también al provider
                        carritoProvider.agregar({
                          "tipoItem": "matricula", // 🔴 IMPORTANTE
                          "estudianteId": est["dni"],
                          "nombreCompleto":
                              "${est["nombre"]} ${est["apellido"]}",
                          "montoCategoria": COSTO_MATRICULA_BASE,
                          "montoProrrateo": 0,
                          "montoDescuento": 0,
                          "montoFinal": COSTO_MATRICULA_BASE,
                          "disciplinaNombre": "",
                          "categoria": "",
                          "horarioTexto": "",
                          "grupoId": "",
                        });
                      } catch (_) {
                        continue;
                      }
                    }

                    Navigator.pushNamed(context, "/estudiantesRegistrados");
                  },
                  child: const Text("Matricular y Elegir Horario"),
                ),
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
          child: Text(
            "Aún no has agregado estudiantes.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: estudiantesPendientes.map((est) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: est["imagenFile"] != null
                  ? FileImage(est["imagenFile"])
                  : null,
              child: est["imagenFile"] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text("${est["nombre"]} ${est["apellido"]}"),
            subtitle: Text("DNI: ${est["dni"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final actualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PantallaFormularioEstudiante(datosEditar: est),
                      ),
                    );

                    if (actualizado != null) {
                      setState(() {
                        estudiantesPendientes[
                            estudiantesPendientes.indexOf(est)] = actualizado;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => estudiantesPendientes.remove(est));
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
