import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';
class PantallaPerfilEstudiante extends StatelessWidget {
  const PantallaPerfilEstudiante({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del estudiante')),
      body: const EnDesarrolloWidget(),
    );
  }
}
