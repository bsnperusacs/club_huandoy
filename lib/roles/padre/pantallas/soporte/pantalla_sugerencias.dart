import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaSugerencias extends StatefulWidget {
  const PantallaSugerencias({super.key});

  @override
  State<PantallaSugerencias> createState() => _PantallaSugerenciasState();
}

class _PantallaSugerenciasState extends State<PantallaSugerencias> {
  final formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final mensajeCtrl = TextEditingController();

  Future<void> _enviar() async {
    if (!formKey.currentState!.validate()) return;

    final texto =
        "Hola, soy ${nombreCtrl.text}. Mi sugerencia es: ${mensajeCtrl.text}";
    final uri = Uri.parse(
      "https://wa.me/51924188958?text=${Uri.encodeComponent(texto)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sugerencias")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Queremos mejorar para ti",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tu opinión es muy importante para nosotros. "
              "Creemos que la mejor forma de mejorar es escuchándote.\n\n"
              "Por favor, déjanos tus sugerencias llenando el siguiente formulario. "
              "Esto nos ayudará a mejorar la comunicación, los servicios y la experiencia dentro del club.",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),

            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Tu nombre",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Campo obligatorio" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mensajeCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Escribe tu sugerencia",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Campo obligatorio" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _enviar,
                    icon: const Icon(Icons.send),
                    label: const Text("Enviar sugerencia"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
