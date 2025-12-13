import 'package:flutter/material.dart';
import '../theme/colores.dart';

class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonPersonalizado({
    super.key,
    required this.texto,
    required this.onPressed, required bool cargando,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verde,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 16)),
    );
  }
}
