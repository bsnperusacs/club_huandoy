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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Sugerencias")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Queremos escucharte",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Tu opinión es importante para mejorar los servicios "
                "y la experiencia dentro del club.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: "Tu nombre",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: mensajeCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Escribe tu sugerencia",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _enviar,
                  icon: const Icon(Icons.send),
                  label: const Text("Enviar sugerencia"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
