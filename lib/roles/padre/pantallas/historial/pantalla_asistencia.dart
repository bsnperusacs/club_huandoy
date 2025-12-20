import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';

class PantallaAsistencia extends StatelessWidget {
  const PantallaAsistencia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: const EnDesarrolloWidget(),
    );
  }
}
