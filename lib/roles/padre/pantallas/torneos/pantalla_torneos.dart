import 'package:flutter/material.dart';
import 'package:club_huandoy/core/widgets/en_desarrollo_widget.dart';

class PantallaTorneos extends StatelessWidget {
  const PantallaTorneos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torneos')),
      body: const EnDesarrolloWidget(),
    );
  }
}
