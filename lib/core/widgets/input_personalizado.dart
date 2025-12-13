//lib/core/widgets/input_personalizado.dart

import 'package:flutter/material.dart';
import '../theme/colores.dart';

class InputPersonalizado extends StatelessWidget {
  final String label;
  final IconData icono;
  final TextEditingController controller;
  final TextInputType tipo;

  const InputPersonalizado({
    super.key,
    required this.label,
    required this.icono,
    required this.controller,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono, color: AppColors.verde),
        ),
      ),
    );
  }
}
