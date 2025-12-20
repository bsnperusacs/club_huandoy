import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';

class PantallaHistorialCompras extends StatelessWidget {
  const PantallaHistorialCompras({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de compras')),
      body: const EnDesarrolloWidget(),
    );
  }
}
