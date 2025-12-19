// 📁 lib/roles/padre/pantallas/matricula/pantalla_formulario_estudiante.dart


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:club_huandoy/core/theme/app_theme.dart';

class PantallaFormularioEstudiante extends StatefulWidget {
  final Map<String, dynamic>? datosEditar;

  const PantallaFormularioEstudiante({super.key, this.datosEditar});

  @override
  State<PantallaFormularioEstudiante> createState() =>
      _PantallaFormularioEstudianteState();
}

class _PantallaFormularioEstudianteState
    extends State<PantallaFormularioEstudiante> {
  final formKey = GlobalKey<FormState>();

  // Controladores
  final dniCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final celularCtrl = TextEditingController();
  final institucionNuevaCtrl = TextEditingController();
  final gradoCtrl = TextEditingController();
  final trabajoCtrl = TextEditingController();

  // Estados
  String tipoDoc = "DNI";
  DateTime? fechaNacimiento;
  String genero = "";
  String ocupacion = "Estudiante";
  String institucion = "Colegio Micelino Sandoval Torres";

  File? foto;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.datosEditar != null) {
      final d = widget.datosEditar!;

      dniCtrl.text = d["dni"] ?? "";
      nombreCtrl.text = d["nombre"] ?? "";
      apellidoCtrl.text = d["apellido"] ?? "";
      celularCtrl.text = d["celular"] ?? "";
      fechaNacimiento = d["fechaNacimiento"];
      genero = d["genero"] ?? "";
      ocupacion = d["ocupacion"] ?? "Estudiante";
      institucion = d["institucion"] ?? "Colegio Micelino Sandoval Torres";
      gradoCtrl.text = d["grado"] ?? "";
      trabajoCtrl.text = d["centroTrabajo"] ?? "";
      foto = d["imagenFile"];

      if (institucion != "Colegio Micelino Sandoval Torres" &&
          institucion != "Colegio 2 de Mayo") {
        institucion = "OTRO";
        institucionNuevaCtrl.text = d["institucion"] ?? "";
      }
    }
  }

  // ============================================================
  // SELECTOR DE FOTO
  // ============================================================
  Future<void> seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Tomar foto"),
              onTap: () async {
                Navigator.pop(context);
                final img = await picker.pickImage(source: ImageSource.camera);
                if (img != null) setState(() => foto = File(img.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Elegir de galería"),
              onTap: () async {
                Navigator.pop(context);
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => foto = File(img.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECTOR DE FECHA
  // ============================================================
  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime(hoy.year - 10),
      firstDate: DateTime(hoy.year - 70),
      lastDate: hoy,
      locale: const Locale("es", "ES"),
    );

    if (fecha != null) {
      setState(() => fechaNacimiento = fecha);
    }
  }

  // ============================================================
  // VALIDADOR EDAD
  // ============================================================
  bool edadValida(DateTime nac) {
    final hoy = DateTime.now();
    int edad = hoy.year - nac.year;
    if (nac.month > hoy.month ||
        (nac.month == hoy.month && nac.day > hoy.day)) {
      edad--;
    }
    return edad >= 3 && edad <= 65;
  }

  // ============================================================
  // TITLE CASE
  // ============================================================
  String toTitleCase(String text) {
    return text
        .trim()
        .toLowerCase()
        .split(" ")
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ""))
        .join(" ");
  }

  // ============================================================
  // GUARDAR
  // ============================================================
  void guardar() {
    if (!formKey.currentState!.validate()) return;

    if (fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione fecha de nacimiento.")),
      );
      return;
    }

    if (!edadValida(fechaNacimiento!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La edad debe estar entre 3 y 65 años.")),
      );
      return;
    }

    final data = {
      "dni": dniCtrl.text.trim(),
      "nombre": toTitleCase(nombreCtrl.text.trim()),
      "apellido": apellidoCtrl.text.trim().toUpperCase(),
      "celular": celularCtrl.text.trim(),
      "genero": genero,
      "fechaNacimiento": fechaNacimiento,
      "imagenFile": foto,
      "ocupacion": ocupacion,
      "institucion": ocupacion == "Estudiante"
          ? (institucion == "OTRO"
              ? institucionNuevaCtrl.text.trim()
              : institucion)
          : null,
      "grado": ocupacion == "Estudiante"
          ? gradoCtrl.text.trim()
          : null,
      "centroTrabajo": ocupacion == "Trabajador"
          ? trabajoCtrl.text.trim()
          : null,
    };

    Navigator.pop(context, data);
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final modoEditar = widget.datosEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(modoEditar ? "Editar Estudiante" : "Nuevo Estudiante"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: seleccionarFoto,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor:
                      theme.colorScheme.secondary.withOpacity(0.2),
                  backgroundImage: foto != null ? FileImage(foto!) : null,
                  child: foto == null
                      ? Icon(Icons.camera_alt,
                          size: 32, color: theme.colorScheme.primary)
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              // TIPO DOCUMENTO
              DropdownButtonFormField(
                value: tipoDoc,
                decoration:
                    const InputDecoration(labelText: "Tipo de documento"),
                items: const [
                  DropdownMenuItem(value: "DNI", child: Text("DNI")),
                  DropdownMenuItem(
                      value: "PASAPORTE", child: Text("Pasaporte")),
                  DropdownMenuItem(value: "CE", child: Text("Carnet Extranjería")),
                ],
                onChanged: (v) => setState(() => tipoDoc = v!),
              ),

              const SizedBox(height: 15),

              // DNI
              TextFormField(
                controller: dniCtrl,
                decoration:
                    const InputDecoration(labelText: "Número de documento"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Campo obligatorio";
                  if (tipoDoc == "DNI" && v.length != 8) {
                    return "Debe tener 8 dígitos";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // NOMBRES
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombres"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Campo obligatorio";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // APELLIDOS
              TextFormField(
                controller: apellidoCtrl,
                decoration: const InputDecoration(labelText: "Apellidos"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Campo obligatorio";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // GÉNERO
              DropdownButtonFormField(
                value: genero.isEmpty ? null : genero,
                decoration: const InputDecoration(labelText: "Género"),
                items: const [
                  DropdownMenuItem(
                      value: "MASCULINO", child: Text("Masculino")),
                  DropdownMenuItem(
                      value: "FEMENINO", child: Text("Femenino")),
                ],
                onChanged: (v) => setState(() => genero = v!),
                validator: (v) => v == null ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 15),

              // CELULAR
              TextFormField(
                controller: celularCtrl,
                decoration: const InputDecoration(labelText: "Celular"),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Campo obligatorio";
                  if (v.length != 9) return "Debe tener 9 dígitos";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // FECHA NACIMIENTO
              ListTile(
                tileColor: theme.colorScheme.secondary.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(
                  fechaNacimiento == null
                      ? "Seleccionar fecha de nacimiento"
                      : "${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}",
                ),
                trailing: Icon(Icons.calendar_month,
                    color: theme.colorScheme.primary),
                onTap: seleccionarFecha,
              ),

              const SizedBox(height: 25),

              // OCUPACIÓN
              DropdownButtonFormField(
                value: ocupacion,
                decoration: const InputDecoration(labelText: "Ocupación"),
                items: const [
                  DropdownMenuItem(
                      value: "Estudiante", child: Text("Estudiante")),
                  DropdownMenuItem(
                      value: "Trabajador", child: Text("Trabajador")),
                ],
                onChanged: (v) => setState(() => ocupacion = v!),
              ),

              const SizedBox(height: 20),

              if (ocupacion == "Estudiante") ...[
                DropdownButtonFormField(
                  isExpanded: true, // 🔥 CLAVE
                  value: institucion,
                  decoration: const InputDecoration(
                      labelText: "Institución educativa"),
                  items: const [
                    DropdownMenuItem(
                        value: "Colegio Micelino Sandoval Torres",
                        child: Text("Colegio Micelino Sandoval Torres")),
                    DropdownMenuItem(
                        value: "Colegio 2 de Mayo",
                        child: Text("Colegio 2 de Mayo")),
                    DropdownMenuItem(
                        value: "OTRO", child: Text("Agregar institución")),
                  ],
                  onChanged: (v) => setState(() => institucion = v!),
                ),

                if (institucion == "OTRO")
                  TextFormField(
                    controller: institucionNuevaCtrl,
                    decoration:
                        const InputDecoration(labelText: "Nueva institución"),
                    validator: (v) {
                      if (institucion == "OTRO" && (v == null || v.isEmpty)) {
                        return "Campo obligatorio";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: gradoCtrl,
                  decoration: const InputDecoration(labelText: "Grado / Ciclo"),
                  validator: (v) {
                    if (ocupacion == "Estudiante" &&
                        (v == null || v.isEmpty)) {
                      return "Campo obligatorio";
                    }
                    return null;
                  },
                ),
              ],

              if (ocupacion == "Trabajador")
                TextFormField(
                  controller: trabajoCtrl,
                  decoration:
                      const InputDecoration(labelText: "Centro de trabajo"),
                  validator: (v) {
                    if (ocupacion == "Trabajador" &&
                        (v == null || v.isEmpty)) {
                      return "Campo obligatorio";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: guardar,
                child: Text(modoEditar ? "Actualizar" : "Agregar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
