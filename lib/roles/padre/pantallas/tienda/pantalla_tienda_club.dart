import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';

class PantallaTiendaClub extends StatelessWidget {
  const PantallaTiendaClub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tienda del Club')),
      body: const EnDesarrolloWidget(),
    );
  }
}
