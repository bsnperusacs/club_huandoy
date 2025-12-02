// UBICACIÓN: lib/roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:club_huandoy/core/controladores/estudiante_controller.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

const double COSTO_MATRICULA_BASE = 50.00;

const String URL_VALIDAR_CONVENIO =
    "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/validarConvenio";

class PantallaMatriculaEstudiante extends StatefulWidget {
  const PantallaMatriculaEstudiante({super.key});

  @override
  State<PantallaMatriculaEstudiante> createState() =>
      _PantallaMatriculaEstudianteState();
}

class _PantallaMatriculaEstudianteState
    extends State<PantallaMatriculaEstudiante> {
  final controller = EstudianteController();

  List<Map<String, dynamic>> estudiantesPendientes = [];

  final codigoConvenioCtrl = TextEditingController();

  double descuentoPorEstudiante = 0.0;
  bool convenioAplicado = false;
  String mensajeConvenio = "";

  final formatoMoneda =
      NumberFormat.currency(locale: 'es_PE', symbol: 'S/. ');

  Future<void> mostrarAlerta({
    required String titulo,
    required String mensaje,
    bool error = true,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                color: error ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 10),
              Text(titulo),
            ],
          ),
          content: Text(
            mensaje,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _validarCodigoConvenio() async {
    final cod = codigoConvenioCtrl.text.trim().toUpperCase();

    if (cod.isEmpty) {
      await mostrarAlerta(
        titulo: "Código vacío",
        mensaje: "Ingrese un código de convenio.",
        error: true,
      );
      return;
    }

    try {
      setState(() {
        convenioAplicado = false;
        descuentoPorEstudiante = 0.0;
      });

      final r = await http.post(
        Uri.parse(URL_VALIDAR_CONVENIO),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"codigo": cod}),
      );

      if (r.statusCode != 200) {
        await mostrarAlerta(
          titulo: "Error",
          mensaje: "Error en servidor.",
          error: true,
        );
        return;
      }

      final data = jsonDecode(r.body);

      if (data["valido"] != true) {
        await mostrarAlerta(
          titulo: "Inválido",
          mensaje: data["mensaje"] ?? "Código no válido.",
          error: true,
        );
        return;
      }

      final tipo = data["tipoDescuento"];
      final aplicaEn = data["aplicaEn"];
      final valor = (data["valorDescuento"] ?? 0).toDouble();

      if (aplicaEn != "matricula" && aplicaEn != "ambos") {
        await mostrarAlerta(
          titulo: "No aplica",
          mensaje: "Este convenio no aplica a matrícula.",
          error: true,
        );
        return;
      }

      double desc = 0;

      if (tipo == "porcentaje") {
        desc = COSTO_MATRICULA_BASE * (valor / 100);
      } else {
        desc = valor;
      }

      setState(() {
        convenioAplicado = true;
        descuentoPorEstudiante = desc;

        mensajeConvenio = tipo == "porcentaje"
            ? "Convenio: $valor% por estudiante."
            : "Convenio: S/. $valor por estudiante.";
      });

      await mostrarAlerta(
        titulo: "Convenio aplicado",
        mensaje: mensajeConvenio,
        error: false,
      );
    } catch (e) {
      await mostrarAlerta(
        titulo: "Error",
        mensaje: "Error: $e",
        error: true,
      );
    }
  }

  @override
  void dispose() {
    codigoConvenioCtrl.dispose();
    super.dispose();
  }

  Future<String> subirFoto(String dni, File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("estudiantes")
        .child("$dni.jpg");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> _guardarEstudianteEnFirestore(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dni = data["dni"].toString().trim();

    String fotoUrl = "";
    if (data["imagenFile"] != null) {
      fotoUrl = await subirFoto(dni, data["imagenFile"]);
    }

    final double montoFinal =
        COSTO_MATRICULA_BASE - descuentoPorEstudiante;

    await FirebaseFirestore.instance
        .collection("estudiantes")
        .doc(dni)
        .set({
      "id": dni,
      "padreId": uid,

      "nombre": data["nombre"],
      "apellido": data["apellido"],
      "dni": dni,
      "fechaNacimiento": data["fechaNacimiento"],
      "genero": data["genero"] ?? "",
      "celular": data["celular"],
      "fotoUrl": fotoUrl,

      "estado": "registrado",
      "matriculaPagada": false,
      "fechaMatricula": DateTime.now(),
      "fechaPago": null,

      "disciplinaId": "",
      "categoriaId": "",
      "grupoId": "",
      "horarioId": "",
      "entrenadorId": "",

      "montoCategoria": COSTO_MATRICULA_BASE,
      "montoProrrateo": 0.0,
      "montoDescuento": descuentoPorEstudiante,
      "montoFinal": montoFinal,

      "activo": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final costoBase =
        estudiantesPendientes.length * COSTO_MATRICULA_BASE;
    final descuentoTotal =
        estudiantesPendientes.length * descuentoPorEstudiante;
    final total = costoBase - descuentoTotal;

    return Scaffold(
      appBar: AppBar(title: const Text("Matricular Estudiantes")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioNuevoEstudiante(context),
        icon: const Icon(Icons.person_add),
        label: const Text("Añadir Estudiante"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Estudiantes a matricular:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            _buildListaEstudiantes(),
            const SizedBox(height: 30),

            if (estudiantesPendientes.isNotEmpty) ...[
              TextFormField(
                controller: codigoConvenioCtrl,
                decoration: InputDecoration(
                  labelText: "Código de Convenio (Opcional)",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: convenioAplicado ? Colors.green : Colors.grey,
                    ),
                    onPressed: _validarCodigoConvenio,
                  ),
                ),
                onChanged: (_) {
                  if (convenioAplicado) {
                    setState(() {
                      convenioAplicado = false;
                      descuentoPorEstudiante = 0.0;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              if (convenioAplicado)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Descuento:",
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                    Text(
                      "- ${formatoMoneda.format(descuentoTotal)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              Card(
                color: Colors.lightGreen.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total a Pagar:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        formatoMoneda.format(total),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  for (var est in estudiantesPendientes) {
                    await _guardarEstudianteEnFirestore(est);
                  }
                  Navigator.pushNamed(context, "/estudiantesRegistrados");
                },
                child: const Text("Matricular y Elegir Horario"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListaEstudiantes() {
    if (estudiantesPendientes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          "Pulsa el botón '+' para registrar al primer estudiante.",
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: estudiantesPendientes.asMap().entries.map((entry) {
        int index = entry.key;
        var est = entry.value;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: est['imagenFile'] != null
                  ? FileImage(est['imagenFile'])
                  : null,
              child: est['imagenFile'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text("${est['nombre']} ${est['apellido']}"),
            subtitle: Text("DNI: ${est['dni']}"),

            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  estudiantesPendientes.removeAt(index);
                });
                mostrarAlerta(
                  titulo: "Eliminado",
                  mensaje: "Estudiante eliminado.",
                  error: false,
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _mostrarFormularioNuevoEstudiante(context) async {
    final dniCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final celularCtrl = TextEditingController();

    DateTime? fechaNacimiento;
    File? foto;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return StatefulBuilder(
          builder: (c, setLocal) {
            return AlertDialog(
              title: const Text("Nuevo Estudiante"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final p = await controller.picker
                            .pickImage(source: ImageSource.camera);
                        if (p != null) {
                          setLocal(() => foto = File(p.path));
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: foto != null ? FileImage(foto!) : null,
                        child: foto == null
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: dniCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "DNI (8 dígitos)"),
                    ),
                    TextField(
                      controller: nombreCtrl,
                      decoration:
                          const InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: apellidoCtrl,
                      decoration:
                          const InputDecoration(labelText: "Apellido"),
                    ),
                    TextField(
                      controller: celularCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Celular (9 dígitos)"),
                    ),

                    const SizedBox(height: 10),

                    ListTile(
                      title: Text(
                        fechaNacimiento == null
                            ? "Fecha de nacimiento"
                            : "Fecha: ${DateFormat("dd/MM/yyyy").format(fechaNacimiento!)}",
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final hoy = DateTime.now();
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2010),
                          firstDate: DateTime(1950),
                          lastDate: hoy,
                        );

                        if (fecha != null) {
                          final edad = hoy.year - fecha.year -
                              ((hoy.month < fecha.month ||
                                      (hoy.month == fecha.month &&
                                          hoy.day < fecha.day))
                                  ? 1
                                  : 0);

                          if (edad < 3 || edad > 65) {
                            await mostrarAlerta(
                              titulo: "Edad inválida",
                              mensaje:
                                  "La edad debe estar entre 3 y 65 años.",
                              error: true,
                            );
                            return;
                          }

                          setLocal(() => fechaNacimiento = fecha);
                        }
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final dni = dniCtrl.text.trim();
                    final nombre = nombreCtrl.text.trim();
                    final apellido = apellidoCtrl.text.trim();
                    final celular = celularCtrl.text.trim();

                    if (dni.length != 8 ||
                        !RegExp(r'^[0-9]+$').hasMatch(dni)) {
                      await mostrarAlerta(
                        titulo: "DNI inválido",
                        mensaje: "El DNI debe tener exactamente 8 dígitos.",
                        error: true,
                      );
                      return;
                    }

                    final existe = await FirebaseFirestore.instance
                        .collection("estudiantes")
                        .doc(dni)
                        .get();

                    if (existe.exists) {
                      await mostrarAlerta(
                        titulo: "DNI duplicado",
                        mensaje: "Este DNI ya está registrado.",
                        error: true,
                      );
                      return;
                    }

                    if (nombre.isEmpty) {
                      await mostrarAlerta(
                        titulo: "Nombre requerido",
                        mensaje: "Ingrese un nombre válido.",
                        error: true,
                      );
                      return;
                    }

                    if (apellido.isEmpty) {
                      await mostrarAlerta(
                        titulo: "Apellido requerido",
                        mensaje: "Ingrese un apellido válido.",
                        error: true,
                      );
                      return;
                    }

                    if (celular.length != 9 ||
                        !RegExp(r'^[0-9]+$').hasMatch(celular)) {
                      await mostrarAlerta(
                        titulo: "Celular inválido",
                        mensaje: "El celular debe tener 9 dígitos.",
                        error: true,
                      );
                      return;
                    }

                    if (fechaNacimiento == null) {
                      await mostrarAlerta(
                        titulo: "Fecha requerida",
                        mensaje:
                            "Seleccione una fecha de nacimiento válida.",
                        error: true,
                      );
                      return;
                    }

                    final hoy = DateTime.now();
                    final edad = hoy.year -
                        fechaNacimiento!.year -
                        ((hoy.month < fechaNacimiento!.month ||
                                (hoy.month == fechaNacimiento!.month &&
                                    hoy.day <
                                        fechaNacimiento!.day))
                            ? 1
                            : 0);

                    if (edad < 3 || edad > 65) {
                      await mostrarAlerta(
                        titulo: "Edad inválida",
                        mensaje:
                            "La edad debe estar entre 3 y 65 años.",
                        error: true,
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      "dni": dni,
                      "nombre": nombre,
                      "apellido": apellido,
                      "celular": celular,
                      "fechaNacimiento": fechaNacimiento,
                      "genero": "",
                      "imagenFile": foto,
                    });
                  },
                  child: const Text("Agregar"),
                ),
              ],
            );
          },
        );
      },
    ).then((res) {
      if (res != null) {
        setState(() => estudiantesPendientes.add(res));
      }
    });
  }
}
