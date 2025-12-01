// 📁 lib/roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:club_huandoy/core/controladores/estudiante_controller.dart';
import 'package:club_huandoy/core/modelos/estudiante_model.dart';
// ¡IMPORTANTE! Asegúrate de que esta línea esté presente en tu archivo:
import 'package:intl/intl.dart'; 

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// Definimos la constante del costo de matrícula por estudiante
const double COSTO_MATRICULA_BASE = 50.00;

class PantallaMatriculaEstudiante extends StatefulWidget {
  const PantallaMatriculaEstudiante({super.key});

  @override
  State<PantallaMatriculaEstudiante> createState() =>
      _PantallaMatriculaEstudianteState();
}

class _PantallaMatriculaEstudianteState
    extends State<PantallaMatriculaEstudiante> {
  final controller = EstudianteController();

  // Lista para almacenar los datos de los estudiantes temporales
  List<Map<String, dynamic>> estudiantesPendientes = [];

  // Controlador para el campo de Código de Convenio
  final codigoConvenioCtrl = TextEditingController();

  // Variables de estado para el convenio y descuento
  double descuentoPorEstudiante = 0.0;
  bool convenioAplicado = false;
  String mensajeConvenio = "";

  // 🔥 SOLUCIÓN DEL ERROR: Declaramos el formateador de moneda a nivel de clase
  final formatoMoneda = NumberFormat.currency(locale: 'es_PE', symbol: 'S/. '); 

  // ============================================================
  // LÓGICA DE VALIDACIÓN DE CONVENIO
  // ============================================================

  void _validarCodigoConvenio() {
    setState(() {
      final codigoIngresado = codigoConvenioCtrl.text.trim().toUpperCase();
      
      // Lógica de validación: Usamos un código de ejemplo
      if (codigoIngresado == "MUNICARAZ") {
        // Ejemplo: Convenio "MUNICARAZ" da S/. 10.00 de descuento por estudiante
        descuentoPorEstudiante = 10.00;
        convenioAplicado = true;
        mensajeConvenio = "✅ Convenio 'MUNICARAZ' aplicado: S/. ${descuentoPorEstudiante.toStringAsFixed(2)} de descuento por estudiante.";
      } else if (codigoIngresado.isEmpty) {
        descuentoPorEstudiante = 0.0;
        convenioAplicado = false;
        mensajeConvenio = "Ingrese un código de convenio.";
      } else {
        descuentoPorEstudiante = 0.0;
        convenioAplicado = false;
        mensajeConvenio = "❌ Código de convenio no válido.";
      }
      
      mostrarMsg(mensajeConvenio);
    });
  }

  // ============================================================
  // UI PRINCIPAL (GESTIÓN DE LISTA)
  // ============================================================

  @override
  void dispose() {
    codigoConvenioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calcular el costo base total
    final costoBaseTotal = estudiantesPendientes.length * COSTO_MATRICULA_BASE;
    // 2. Calcular el descuento total
    final descuentoTotal = estudiantesPendientes.length * descuentoPorEstudiante;
    // 3. Calcular el total a pagar
    final totalPagar = costoBaseTotal - descuentoTotal;
    
    // NOTA: formatoMoneda se usa directamente ya que fue declarada a nivel de clase.

    return Scaffold(
      appBar: AppBar(title: const Text("Matricular Estudiantes")),
      
      // Botón Flotante para AÑADIR UN NUEVO ESTUDIANTE
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

            // Muestra la lista de estudiantes añadidos
            _buildListaEstudiantes(),

            const SizedBox(height: 30),

            // Sección de Total y Código de Convenio
            if (estudiantesPendientes.isNotEmpty) ...[
              // Campo para el Código de Convenio
              TextFormField(
                controller: codigoConvenioCtrl,
                decoration: InputDecoration(
                  labelText: "Código de Convenio (Opcional)",
                  border: const OutlineInputBorder(),
                  // Se agrega el botón de validación
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.check_circle, 
                      color: convenioAplicado ? Colors.green : Colors.grey
                    ),
                    onPressed: _validarCodigoConvenio,
                    tooltip: "Validar código de convenio",
                  ),
                ),
                onChanged: (value) {
                    // Si el usuario cambia el texto, reseteamos el estado de convenio
                    if (convenioAplicado) {
                        setState(() {
                            convenioAplicado = false;
                            descuentoPorEstudiante = 0.0;
                            mensajeConvenio = "";
                        });
                    }
                },
              ),
              const SizedBox(height: 20),
              
              // Mostrar el descuento si aplica
              if (convenioAplicado && descuentoTotal > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Descuento por Convenio:",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      Text(
                        "- ${formatoMoneda.format(descuentoTotal)}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ),
                
              // Mostrar Total a Pagar
              Card(
                color: Colors.lightGreen.shade50,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total a Pagar:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        // Usa formatoMoneda declarado en la clase
                        formatoMoneda.format(totalPagar),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón FINAL para procesar la matrícula de todos
              ElevatedButton(
                onPressed: () => _procesarMatriculaLote(context, descuentoPorEstudiante),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                    "Finalizar Matrícula (${estudiantesPendientes.length} Estudiante(s))"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MATRÍCULA EN LOTE (ACTUALIZADA PARA RECIBIR DESCUENTO)
  // ============================================================

  Future<void> _procesarMatriculaLote(BuildContext context, double descuentoPorEstudiante) async {
    if (estudiantesPendientes.isEmpty) {
      mostrarMsg("No hay estudiantes para matricular.");
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Calculamos los montos finales por estudiante
    final montoFinalEstudiante = COSTO_MATRICULA_BASE - descuentoPorEstudiante;
    // final codigoConvenio = codigoConvenioCtrl.text.trim(); // No se usa si no lo guardas

    // Aquí deberías mostrar un indicador de carga (loading spinner)

    for (var data in estudiantesPendientes) {
      final id = const Uuid().v4();

      // 1. Subir la foto si existe (omito la subida real por ser código simulado)
      String foto = data['imagenFile'] != null ? "url_de_foto_$id" : "";
      
      // 2. Crear el objeto Estudiante
      final estudiante = Estudiante(
        id: id,
        padreId: uid,
        nombre: data['nombre'],
        apellido: data['apellido'],
        dni: data['dni'],
        fechaNacimiento: data['fechaNacimiento'],
        genero: data['genero'],
        celular: data['celular'],
        fotoUrl: foto,

        estadoCivil: "NO REGISTRADO", 
        direccion: "NO REGISTRADO", 
        
        // Asignación de ocupación y detalles 
        // Nota: Debes verificar si tu modelo Estudiante tiene campos para 'ocupacion', 'institucion', 'grado'. 
        // Si no los tiene, descomentar estas líneas causará un error de compilación.
        // ocupacion: data['ocupacion'], 
        // institucion: data['institucion'],
        // grado: data['grado'], 
        
        deporteId: "", categoriaId: "", grupoId: "", 
        horarioId: "", entrenadorId: "",
        estado: "registrado",

        // MONTO ACTUALIZADO
        montoCategoria: COSTO_MATRICULA_BASE,
        montoProrrateo: 0.0,
        montoDescuento: descuentoPorEstudiante, // El descuento aplicado
        montoFinal: montoFinalEstudiante, // El total a pagar

        matriculaPagada: false,
        fechaMatricula: DateTime.now(),
        fechaMatriculaPagada: null,

        fechaAsignacion: null,
        fechaPago: null,
        idPagoMp: null,

        activo: true,
      );
      
      await controller.registrarEstudiante(estudiante);
    }
    
    // Aquí deberías cerrar el indicador de carga

    // 🔥 LÍNEA CORREGIDA: Usa formatoMoneda correctamente
    mostrarMsg(
        "Se han matriculado ${estudiantesPendientes.length} estudiantes con éxito y se procesará el pago de ${formatoMoneda.format(estudiantesPendientes.length * montoFinalEstudiante)}.");

    // Limpieza y cierre
    setState(() {
      estudiantesPendientes.clear();
      codigoConvenioCtrl.clear();
      descuentoPorEstudiante = 0.0;
      convenioAplicado = false;
      mensajeConvenio = "";
    });
    
    // Navegar a la pantalla de éxito/pago
    // Navigator.of(context).pop(); 
  }


  // ============================================================
  // RESTO DE WIDGETS Y MÉTODOS
  // ============================================================

  Widget _buildListaEstudiantes() {
    if (estudiantesPendientes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
              "Pulsa el botón '+' para registrar los datos del primer estudiante.",
              textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      children: estudiantesPendientes.asMap().entries.map((entry) {
        int index = entry.key;
        var estudiante = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: estudiante['imagenFile'] != null
                  ? FileImage(estudiante['imagenFile'] as File)
                  : null,
              child: estudiante['imagenFile'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text("${estudiante['nombre']} ${estudiante['apellido']}"),
            subtitle: Text("DNI: ${estudiante['dni']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Al eliminar, forzamos la recalculación de descuentos
                setState(() {
                  estudiantesPendientes.removeAt(index);
                  // Reseteamos el descuento si la lista queda vacía
                  if (estudiantesPendientes.isEmpty) {
                     descuentoPorEstudiante = 0.0;
                     convenioAplicado = false;
                     codigoConvenioCtrl.clear();
                  }
                });
                mostrarMsg("Estudiante eliminado de la lista.");
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _mostrarFormularioNuevoEstudiante(BuildContext context) async {
    // Necesitamos TextControllers y variables de estado temporales para el diálogo
    final formKey = GlobalKey<FormState>();
    String tipoDoc = "DNI";
    final dniCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final celularCtrl = TextEditingController();
    DateTime? fechaNacimiento;
    String genero = "";
    String ocupacion = "Estudiante";
    String institucion = "Colegio Micelino Sandoval Torres";
    final institucionNuevaCtrl = TextEditingController();
    final gradoCtrl = TextEditingController();
    final trabajoCtrl = TextEditingController();
    // File de la imagen seleccionada para este estudiante
    File? imagenSeleccionada;
    
    // Función para mostrar las opciones de foto dentro del diálogo
    Future<void> mostrarOpcionesFotoLocal(StateSetter setStateLocal) async {
        showModalBottomSheet(
            context: context,
            builder: (c) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Tomar foto"),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await controller.picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setStateLocal(() {
                        imagenSeleccionada = File(pickedFile.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Elegir de galería"),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await controller.picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setStateLocal(() {
                        imagenSeleccionada = File(pickedFile.path);
                      });
                    }
                  },
                )
              ],
            ),
          );
    }
    
    // Función para seleccionar fecha (adaptada para StateSetter)
    Future<void> seleccionarFechaLocal(StateSetter setStateLocal) async {
      final hoy = DateTime.now();
      final fecha = await showDatePicker(
        context: context,
        locale: const Locale('es', 'ES'),
        initialDate: DateTime(hoy.year - 10),
        firstDate: DateTime(hoy.year - 50),
        lastDate: DateTime(hoy.year - 3),
      );

      if (fecha != null) {
        setStateLocal(() => fechaNacimiento = fecha);
      }
    }


    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              title: const Text("Datos del Nuevo Estudiante"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- FOTO ---
                      GestureDetector(
                        onTap: () async {
                          await mostrarOpcionesFotoLocal(setStateLocal);
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: imagenSeleccionada != null
                              ? FileImage(imagenSeleccionada!)
                              : null,
                          child: imagenSeleccionada == null
                              ? const Icon(Icons.camera_alt, size: 25)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- TIPO DOC ---
                      DropdownButtonFormField(
                        value: tipoDoc,
                        items: const [
                          DropdownMenuItem(value: "DNI", child: Text("DNI")),
                          DropdownMenuItem(value: "PASAPORTE", child: Text("Pasaporte")),
                          DropdownMenuItem(
                              value: "CE", child: Text("Carnet Extranjería")),
                        ],
                        onChanged: (v) {
                          setStateLocal(() {
                            tipoDoc = v!;
                            dniCtrl.clear();
                            nombreCtrl.clear();
                            apellidoCtrl.clear();
                          });
                        },
                        decoration: const InputDecoration(labelText: "Tipo de documento"),
                      ),
                      const SizedBox(height: 12),

                      // --- DNI ---
                      TextFormField(
                        controller: dniCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: const InputDecoration(
                          labelText: "Número de DNI",
                        ),
                        validator: (v) => v!.isEmpty || v.length != 8 ? "El DNI debe tener 8 dígitos" : null,
                      ),
                      const SizedBox(height: 20),

                      // --- NOMBRES ---
                      TextFormField(
                        controller: nombreCtrl,
                        decoration: const InputDecoration(labelText: "Nombres"),
                        validator: (v) => v!.isEmpty ? "Ingresa los nombres" : null,
                      ),
                      const SizedBox(height: 12),

                      // --- APELLIDOS ---
                      TextFormField(
                        controller: apellidoCtrl,
                        decoration: const InputDecoration(labelText: "Apellidos"),
                        validator: (v) => v!.isEmpty ? "Ingresa los apellidos" : null,
                      ),
                      const SizedBox(height: 12),

                      // --- GÉNERO ---
                      DropdownButtonFormField<String>(
                        value: genero.isEmpty ? null : genero,
                        decoration: const InputDecoration(labelText: "Género"),
                        items: const [
                          DropdownMenuItem(value: "MASCULINO", child: Text("Masculino")),
                          DropdownMenuItem(value: "FEMENINO", child: Text("Femenino")),
                        ],
                        onChanged: (v) {
                          setStateLocal(() {
                            genero = v!;
                          });
                        },
                        validator: (v) => v == null ? "Selecciona el género" : null,
                      ),
                      const SizedBox(height: 12),

                      // --- CELULAR ---
                      TextFormField(
                        controller: celularCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "Celular"),
                        validator: (v) => v!.isEmpty ? "Ingresa el celular" : null,
                      ),
                      const SizedBox(height: 20),

                      // --- FECHA NACIMIENTO ---
                      ListTile(
                        title: Text(
                          fechaNacimiento == null
                              ? "Seleccionar fecha de nacimiento"
                              : "Fecha: ${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}",
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () => seleccionarFechaLocal(setStateLocal),
                      ),
                      const SizedBox(height: 20),
                      
                      // --- OCUPACIÓN ---
                      DropdownButtonFormField(
                        value: ocupacion,
                        items: const [
                          DropdownMenuItem(value: "Estudiante", child: Text("Estudiante")),
                          DropdownMenuItem(value: "Trabajador", child: Text("Trabajador")),
                        ],
                        onChanged: (v) {
                          setStateLocal(() {
                            ocupacion = v!;
                          });
                        },
                        decoration: const InputDecoration(labelText: "Ocupación"),
                      ),
                      const SizedBox(height: 20),

                      // --- DETALLE OCUPACIÓN ---
                      if (ocupacion == "Estudiante") ...[
                        DropdownButtonFormField(
                          value: institucion,
                          items: const [
                            DropdownMenuItem(
                                value: "Colegio Micelino Sandoval Torres",
                                child: Text("Colegio Micelino Sandoval Torres")),
                            DropdownMenuItem(
                                value: "Colegio 2 de Mayo",
                                child: Text("Colegio 2 de Mayo")),
                            DropdownMenuItem(
                                value: "OTRO",
                                child: Text("Agregar institución educativa")),
                          ],
                          onChanged: (v) {
                            setStateLocal(() {
                              institucion = v!;
                            });
                          },
                          decoration:
                              const InputDecoration(labelText: "Institución educativa"),
                        ),
                        if (institucion == "OTRO")
                          TextFormField(
                            controller: institucionNuevaCtrl,
                            decoration: const InputDecoration(labelText: "Nueva institución"),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: gradoCtrl,
                          decoration: const InputDecoration(labelText: "Grado / Ciclo"),
                        ),
                      ],
                      if (ocupacion == "Trabajador")
                        TextFormField(
                          controller: trabajoCtrl,
                          decoration: const InputDecoration(labelText: "Trabajo actual"),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() && fechaNacimiento != null) {
                      final nuevoEstudianteData = {
                        'nombre': nombreCtrl.text.trim(),
                        'apellido': apellidoCtrl.text.trim(),
                        'dni': dniCtrl.text.trim(),
                        'fechaNacimiento': fechaNacimiento,
                        'genero': genero,
                        'celular': celularCtrl.text.trim(),
                        'imagenFile': imagenSeleccionada,
                        'ocupacion': ocupacion, // Guardamos la ocupación
                        'institucion': ocupacion == "Estudiante" 
                                       ? (institucion == "OTRO" ? institucionNuevaCtrl.text.trim() : institucion) 
                                       : trabajoCtrl.text.trim(),
                        'grado': ocupacion == "Estudiante" ? gradoCtrl.text.trim() : null,
                      };
                      // Retorna el Map de datos
                      Navigator.of(context).pop(nuevoEstudianteData);
                    } else if (fechaNacimiento == null) {
                        mostrarMsg("Selecciona la fecha de nacimiento");
                    }
                  },
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      // Se ejecuta al cerrar el diálogo
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          estudiantesPendientes.add(result);
        });
        mostrarMsg("Estudiante ${result['nombre']} añadido para matricular.");
        // Si se añade un nuevo estudiante, forzamos una re-validación del código
        _validarCodigoConvenio(); 
      }
    });
  }

  void mostrarMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}