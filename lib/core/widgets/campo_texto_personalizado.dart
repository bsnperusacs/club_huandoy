import 'package:flutter/material.dart';

class CampoTextoPersonalizado extends StatelessWidget {
  final String label;
  final IconData icono;
  final TextEditingController controlador;
  final TextInputType tipo;
  final String? Function(String?)? validador;
  final bool esPassword;
  final bool mostrarPassword;
  final VoidCallback? onTogglePassword;

  const CampoTextoPersonalizado({
    super.key,
    required this.label,
    required this.icono,
    required this.controlador,
    required this.tipo,
    this.validador,
    this.esPassword = false,
    this.mostrarPassword = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo,
      obscureText: esPassword ? !mostrarPassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        suffixIcon: esPassword
            ? IconButton(
                icon: Icon(
                    mostrarPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePassword,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      validator: validador,
    );
  }
}
