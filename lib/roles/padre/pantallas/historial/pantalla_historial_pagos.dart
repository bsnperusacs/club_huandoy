import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';

class PantallaHistorialPagos extends StatelessWidget {
  const PantallaHistorialPagos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pagos')),
      body: const EnDesarrolloWidget(),
    );
  }
}
