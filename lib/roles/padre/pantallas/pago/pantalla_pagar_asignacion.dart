// UBICACIÓN: lib/roles/padre/pantallas/pago/pantalla_pagar_asignacion.dart


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:club_huandoy/core/controladores/pago_controller.dart';

class PantallaPagarAsignacion extends StatefulWidget {
  final Estudiante estudiante;
  final Map datosPago;

  const PantallaPagarAsignacion({
    super.key,
    required this.estudiante,
    required this.datosPago,
  });

  @override
  State<PantallaPagarAsignacion> createState() =>
      _PantallaPagarAsignacionState();
}

class _PantallaPagarAsignacionState extends State<PantallaPagarAsignacion> {
  late final WebViewController controller;
  final PagoController pagoController = PagoController();

  bool cargando = true;
  String? initPoint;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            // Detectamos confirmación de pago
            if (url.contains("approved") || url.contains("success")) {
              _registrarPagoFinal();
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    generarPago();
  }

  // 🔵 Crear link de pago en la Cloud Function
  Future<void> generarPago() async {
    initPoint = await pagoController.generarInitPoint(
      estudianteId: widget.estudiante.id,
      montoFinal: widget.datosPago["montoFinal"],
      descripcion:
          "Pago de inscripción – ${widget.estudiante.nombre} ${widget.estudiante.apellido}",
    );

    if (initPoint != null) {
      await controller.loadRequest(Uri.parse(initPoint!));
    }

    setState(() => cargando = false);
  }

  // 🔵 Registrar pago en Firestore cuando MercadoPago confirma
  Future<void> _registrarPagoFinal() async {
    await pagoController.registrarPago(
      estudianteId: widget.estudiante.id,
      grupoId: widget.datosPago["grupoId"],
      datos: widget.datosPago,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Procesar Pago")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: controller),
    );
  }
}
