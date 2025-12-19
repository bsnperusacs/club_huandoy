import 'package:flutter/material.dart';

class PantallaSoporte extends StatelessWidget {
  const PantallaSoporte({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte y Ayuda"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Estamos para ayudarte",
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "En esta sección puedes enviarnos sugerencias, "
            "registrar un reclamo formal o contactarte directamente con el club. "
            "Queremos escucharte y seguir mejorando para ti y tu familia.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          _item(
            context,
            icon: Icons.lightbulb_outline,
            title: "Enviar sugerencias",
            subtitle:
                "Ayúdanos a mejorar nuestros servicios y la experiencia en el club.",
            route: '/soporteSugerencias',
          ),

          _item(
            context,
            icon: Icons.menu_book_outlined,
            title: "Libro de reclamaciones",
            subtitle:
                "Registra un reclamo o queja de manera formal y segura.",
            route: '/soporteReclamaciones',
          ),

          _item(
            context,
            icon: Icons.support_agent,
            title: "Contacto directo",
            subtitle:
                "Comunícate con nosotros por WhatsApp o correo electrónico.",
            route: '/soporteContacto',
          ),

          _item(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Política de privacidad",
            subtitle:
                "Consulta cómo protegemos y utilizamos tu información.",
            route: '/politica',
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
