// 📁 lib/roles/padre/pantallas/pago/pantalla_pagar_carrito.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';

class PantallaPagarCarrito extends StatefulWidget {
  const PantallaPagarCarrito({super.key});

  @override
  State<PantallaPagarCarrito> createState() => _PantallaPagarCarritoState();
}

class _PantallaPagarCarritoState extends State<PantallaPagarCarrito> {
  final TextEditingController _codigoController = TextEditingController();

  bool _cargando = false;
  bool _convenioAplicado = false;
  double _descuento = 0.0;

  Map<String, String> _nombresEstudiantes = {};

  StreamSubscription<QuerySnapshot>? _pagoSub;
  bool _pagoProcesado = false;

  @override
  void initState() {
    super.initState();
    _cargarNombresEstudiantes();
    // ❌ NO escuchar pagos aquí
  }

  @override
  void dispose() {
    _pagoSub?.cancel();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _cargarNombresEstudiantes() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection("estudiantes")
        .where("padreId", isEqualTo: uid)
        .get();

    final Map<String, String> map = {};
    for (final doc in snap.docs) {
      final d = doc.data();
      map[d["id"]] = "${d["nombre"]} ${d["apellido"]}";
    }
    if (mounted) setState(() => _nombresEstudiantes = map);
  }

  // =============================
  // ESCUCHAR PAGO APROBADO (SE ACTIVA DESPUÉS DE PAGAR)
  // =============================
  void _escucharPagoAprobado() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _pagoSub?.cancel();
    _pagoProcesado = false;

    _pagoSub = FirebaseFirestore.instance
        .collection("pagos")
        .where("uid", isEqualTo: uid)
        .where("estado", isEqualTo: "aprobado")
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      if (snap.docs.isEmpty || _pagoProcesado) return;

      _pagoProcesado = true;

      final carrito =
          Provider.of<CarritoAsignacionProvider>(context, listen: false);
      carrito.limpiar();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("PAGO EXITOSO"),
            content: const Text(
              "Gracias por su preferencia!!!\n\nBienvenido al Club Integral Huandoy",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: const Text("Aceptar"),
              ),
            ],
          );
        },
      );
    });
  }

  // =============================
  // INICIAR PAGO (MERCADO PAGO)
  // =============================
  Future<void> _iniciarPago(
    double total,
    CarritoAsignacionProvider carrito,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final url = Uri.parse(
      "https://us-central1-clubdeportivohuandoy.cloudfunctions.net/crearPago",
    );

    final estudianteId = carrito.items.first["estudianteId"];

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "uid": uid,
      },
      body: jsonEncode({
        "estudianteId": estudianteId,
        "monto": total,
        "descripcion": "Pago Club Huandoy",
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error backend: ${res.body}");
    }

    final data = jsonDecode(res.body);
    if (data["init_point"] == null) {
      throw Exception("Respuesta inválida: ${res.body}");
    }

    final ok = await launchUrl(
      Uri.parse(data["init_point"]),
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      throw Exception("No se pudo abrir Mercado Pago");
    }
  }

  // =============================
  // APLICAR CONVENIO
  // =============================
  Future<void> _aplicarConvenio(CarritoAsignacionProvider carrito) async {
    final codigo = _codigoController.text.trim().toUpperCase();
    _codigoController.text = codigo;
    if (codigo.isEmpty) return;

    final snap = await FirebaseFirestore.instance
        .collection("convenios")
        .where("codigo", isEqualTo: codigo)
        .where("activo", isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Código inválido")));
      return;
    }

    final data = snap.docs.first.data();
    final tipo = data["tipoDescuento"];
    final valor = (data["valorDescuento"] ?? 0).toDouble();
    final aplicaEn = data["aplicaEn"] ?? "ambos";

    double descuento = 0.0;
    for (final item in carrito.items) {
      final concepto = item["tipoItem"];
      final monto = (item["montoFinal"] ?? 0).toDouble();

      final aplica = aplicaEn == "ambos" ||
          (aplicaEn == "mensualidad" && concepto == "mensualidad") ||
          (aplicaEn == "matricula" && concepto == "matricula");

      if (aplica && tipo == "porcentaje") {
        descuento += monto * (valor / 100);
      }
    }

    if (!mounted) return;
    setState(() {
      _descuento = descuento;
      _convenioAplicado = true;
    });
  }

  // =============================
  // PAGAR (ABRE MP Y LUEGO ESCUCHA)
  // =============================
  Future<void> _pagar(CarritoAsignacionProvider carrito) async {
    if (carrito.items.isEmpty) return;

    setState(() => _cargando = true);
    try {
      final totalFinal = carrito.totalGlobal - _descuento;

      // 1) Abre Mercado Pago
      await _iniciarPago(totalFinal, carrito);

      // 2) Recién ahora escucha el pago
      _escucharPagoAprobado();
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorEstudiante(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (final item in items) {
      map.putIfAbsent(item["estudianteId"], () => []);
      map[item["estudianteId"]]!.add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carrito = Provider.of<CarritoAsignacionProvider>(context);

    final subtotal = carrito.totalGlobal;
    final totalFinal = subtotal - _descuento;
    final grupos = _agruparPorEstudiante(carrito.items);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Pago")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: grupos.entries.map((entry) {
                final nombre =
                    _nombresEstudiantes[entry.key] ?? "ESTUDIANTE";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      nombre.toUpperCase(),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DataTable(
                      columnSpacing: 32,
                      headingRowHeight: 36,
                      dataRowHeight: 36,
                      columns: const [
                        DataColumn(label: Text("Concepto")),
                        DataColumn(label: Text("Monto")),
                      ],
                      rows: entry.value.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item["tipoItem"] ?? "")),
                          DataCell(Text(
                            "S/. ${(item["montoFinal"] ?? 0).toStringAsFixed(2)}",
                          )),
                        ]);
                      }).toList(),
                    ),
                    const Divider(height: 32),
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text("S/. ${subtotal.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Descuento"),
                    Text("- S/. ${_descuento.toStringAsFixed(2)}"),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL A PAGAR",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "S/. ${totalFinal.toStringAsFixed(2)}",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codigoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "Código de descuento",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      _convenioAplicado ? null : () => _aplicarConvenio(carrito),
                  child: const Text("Aplicar descuento"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _cargando ? null : () => _pagar(carrito),
                  child: const Text("PAGAR"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
